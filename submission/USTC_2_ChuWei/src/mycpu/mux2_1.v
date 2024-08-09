`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 00:03:56
// Design Name: 
// Module Name: mux2_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2_1(
    input       [31:0]      din1,
    input       [31:0]      din2,
    input                   sel,
    output reg  [31:0]      dout
    );

    always @(*)begin
        case(sel)
            1'b0:dout=din1;
            1'b1:dout=din2;
        endcase
    end
endmodule