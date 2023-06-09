`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Zach Gray
// 
// Create Date: 06/06/2023 10:29:02 AM
// Design Name: 16-bit XNOR Fibonacci Pseudo Random Generator
// Module Name: RandGen
// Project Name: Slot Machine Game
// Target Devices: Basys 3
// Description: 16-bit rising-edge triggered random
//              number generator utilizing a XNOR
//              adapted Fibonacci LSFR (Linear Feedback
//              Shift Register)
//              input clk: a clock (expecting 100MHz)
//              input REIN: enable in
//              output rout: the 16-bit random number output
//      
//////////////////////////////////////////////////////////////////////////////////


module RandGen(
    input clk,
    input REIN,
    output logic [15:0] rout
    );
    logic [15:0]nextrout;
    
    always_ff @ (posedge clk) begin //pauses the RNG if EIN is low, and changes on the rising edge of clk 
        if(~REIN) 
            rout <= rout;
        else
            rout <= nextrout;
    
        end
    always_comb begin
    
        nextrout = {rout[14:0], ~(~(~(rout[15] ^ rout[13]) ^ rout[12]) ^ rout[10])};    //XNOR fibonnaci RNG
    
        end
    
endmodule
