`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/22 20:31:13
// Design Name: 
// Module Name: mux_2_1_icache
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


module mux_2_1_icache(
    input       [63:0]      din1,
    input       [63:0]      din2,
    input                   sel,
    output reg  [63:0]      dout
    );

    always @(*)begin
        case(sel)
            1'b0:dout=din1;
            1'b1:dout=din2;
        endcase
    end
endmodule