`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/11 23:59:25
// Design Name: 
// Module Name: register
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


module  register
#( parameter WIDTH = 32,
             RST_VAL = 0
)(
    input  clk, rstn, en,
    input  [WIDTH-1:0]  d,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk)//同步复位
        begin
            if (!rstn) q <= RST_VAL;
            else  if (en) q <= d;
        end

endmodule