`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Zach Gray
// 
// Create Date: 06/01/2023 08:48:43 PM
// Design Name: Clock Divider for 7-segment display
// Module Name: clkdiv
// Project Name: Slot Machine Game
// Target Devices: Basys 3
// Description: Convert the clock from 100MHz to 12.5hz
//              to drive the 7-segment display with desired
//              speed. Uses a counter to count to 200000 
//              before alowing output clk2 to tick once. 
//              input clock: mclk (expecting 100MHz)
//              output clock: clk2 (12.5hz)
//
//////////////////////////////////////////////////////////////////////////////////

module clkdiv(
    input mclk, //input clock from Basys board
    output logic clk2 //output clock to 7-segment display
    );
    logic [25:0] count; 
    always @ (posedge mclk) begin //counts to 200000 before ticking once
        count <= count + 1;
        if (count == 2000000)begin
            clk2 <= ~clk2;
            count <= 0;
            end
    end
endmodule
