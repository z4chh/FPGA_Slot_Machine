`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Zach Gray
// 
// Create Date: 06/06/2023 10:22:16 AM
// Design Name: Slot Machine Top Level Module
// Module Name: toplevel
// Project Name: Slot Machine Game
// Target Devices: Basys 3
// Description: Slot machine using:
//                -7-segment display of the basys board as the slots
//                -16-bit XNOR Fibonacci LSFR to randomize the output
//                -Submit button on BTNL(W19), Reset button on BTNR(T17)
//                -EIN on SW0(V17), rigged win on SW15(R2), rigged lose on SW14(T1)
//////////////////////////////////////////////////////////////////////////////////

typedef enum {OFF, Spinning, Winning, Losing, Random} states;   //enumerates states in the top-level FSM

//-----------------------------Top Level Module I/O Defintions--------------------------//
module Toplevel(input EIN,
                input RST,
                input Submit,
                input Clk,
                input rigged_win,
                input rigged_lose,
                output logic [7:0] num,
                output logic [3:0] anodes
               );
               
//------------------------------logic definitions------------------------------------------------------------------------------------------------------------//
                      logic oclk;   //divided clock for the seven segment display
                      
                      logic [15:0] random;  //random logic to port map to Random Generator module
                      logic [7:0] cathout;  //output for random situation to port map from CathodeDriver
                      logic [3:0] anout;    //output for anodes to port map from CathodeDriver
                      
                      logic [15:0] winslice = {random[15:12], random[15:12], random[15:12], random[15:12]}; //rigged win slice of random number
                      logic [7:0] cathoutwin;  //output for win situation to port map to CathodeDriver
                      logic [3:0] anoutwin;    //output for anodes to port map to CathodeDriver
                      
                      logic [15:0] lslice = {random[13:10], random[13:10], random[13:10], ~random[13:10]};  //rigged lose 1 slice of random number
                      logic [7:0] cathoutlose1;     //output for lose situation #1 to port map to CathodeDriver
                      logic [3:0] anoutl;           //output for anodes to port map to CathodeDriver
                      
                      logic [15:0] lslice2 = {~random[5:2], random[5:2], ~random[5:2], ~random[5:2]};   //rigged lose 2 slice of random number
                      logic [7:0] cathoutlose2;     //output for lose situation #2 to port map to CathodeDriver
                      logic[3:0] anout2;            //output for anodes to port map to CathodeDriver
                      
                      logic [15:0] lslice3 = {~random[7:4], random[7:4], random[7:4], random[7:4]};     //rigged lose 3 of slice of random number
                      logic [7:0] cathoutlose3;     //output for lose situation #3 to port map to CathodeDriver
                      logic[3:0] anout3;            //output for anodes to port map to CathodeDriver
                      
                      logic mREIN;  //logic to control the EIN from the Random Generator FSM to drive EIN value

//--------------------------------------Port Mapping---------------------------------------------------------------------------------------------------------------//             
    clkdiv first(.mclk(Clk), .clk2(oclk));  //port mapping to clock divider for 7-segment display
    RandGen only(.clk(oclk), .rout(random), .REIN(mREIN));  //port mapping to random generator
    CathodeDriver bink(.CLK(Clk), .HEX(random), .CATHODES(cathout), .ANODES(anout));    //port mapping to CathodeDriver for random situation
    CathodeDriver W(.CLK(Clk), .HEX(winslice), .CATHODES(cathoutwin), .ANODES(anoutwin));   //port mapping to CathodeDriver for win situation
    CathodeDriver L(.CLK(Clk), .HEX(lslice), .CATHODES(cathoutlose1), .ANODES(anoutl));     //port mapping to CathodeDriver for lose situation #1
    CathodeDriver L2(.CLK(Clk), .HEX(lslice2), .CATHODES(cathoutlose2), .ANODES(anout2));   //port mapping to CathodeDriver for lose situation #2
    CathodeDriver L3(.CLK(Clk), .HEX(lslice3), .CATHODES(cathoutlose3), .ANODES(anout3));   //port mapping to CathodeDriver for lose situation #3

//--------------------------------------FSM------------------------------------------------------------------------------------------------------------------------//
    states NS, PS; //creates instance(not software, I know) of states type
    
    always_ff @ (posedge oclk) begin    //flip flop for FSM
        if (~EIN)
            PS <= OFF;
        else if (RST)
            PS <= Spinning;
        else
            PS <= NS;
           
    end
     
    always_comb begin //combinational logic
        case (PS)
            OFF: begin //OFF, 7-segment display off(exactly how it sounds)
                mREIN = 1'b1;
                anodes = 4'b1111;
                num = 8'b11111111;
                
                if (EIN)
                    NS = Spinning;
                else
                    NS = PS;
                end  
           
            Spinning: begin //7-segment display'spinning' like a slot machine
                anodes = anout;
                num = cathout;
                mREIN = 1'b1;
                
                if (~EIN)
                    NS = OFF;
                else if (Submit && rigged_win && ~rigged_lose && ~RST)
                    NS = Winning;
                else if (Submit && ~rigged_win && rigged_lose && ~RST)
                    NS = Losing;
                else if ((~rigged_win && ~rigged_lose && Submit) || (rigged_win && rigged_lose && Submit))
                    NS = Random;
                else
                    NS = PS;
                end  
               
            Winning: begin //All the digits on the 7-segment display have settled to the same value (WIN!)
              //defining outputs
                anodes = anout;    
                num = cathoutwin;
                mREIN = 1'b0;
              // defining next state
                if (~EIN)
                    NS = OFF;
                else if (RST && EIN)
                    NS = Spinning;
                else
                    NS = PS;
                 end
           
            Losing: begin //3 out of 4 digits have settled to the same value (LOSS!, but you were so close so keep gambling!)
              //defining outputs
                if (random[12] == 1'b1 && random[2] == 1'b1)
                    num = cathoutlose1;
                else if(random[3] == 1'b0 && random[8] == 1'b0)
                    num = cathoutlose2;
                else
                    num = cathoutlose3;
                anodes = anout;
                mREIN = 1'b0;
              //defining next state
                if (~EIN)
                    NS = OFF;
                else if (RST && EIN)
                    NS = Spinning;  
                else
                    NS = PS;
                 end
                 
            Random: begin //Digits settle randomly (LOSS, with a small chance of a WIN)
              //defining outputs
                if (random[12] == 1'b1 && random[2] == 1'b1 && random[15] == 1'b0)//allows for ~20% win rate in random mode
                    num = cathoutwin;
                else 
                    num = cathout;
                anodes = anout;
                mREIN = 1'b0;
              //defining next state
                if (~EIN)
                    NS = OFF;
                else if (RST && EIN)
                    NS = Spinning;  
                else
                    NS = PS;
                 end    
                 
            default: begin //For Illegal State Recovery
              //defining outputs
                mREIN = 1'b1;
                num = 8'b00000000;
                anodes = 4'b1111;
              //defining next state
                NS = OFF;
                end      
        endcase
    end                    
endmodule
