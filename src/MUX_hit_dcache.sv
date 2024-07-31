`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/13 12:55:48
// Design Name: 
// Module Name: MUX_hit_dcache
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


module MUX_hit_dcache(
    input     [1:0]    hit,
    input     [127:0]  r_data1,
    input     [127:0]  r_data2,
    output reg [127:0] r_data_mem
    );
    always @(*) begin
        case(hit)
            2'b00: r_data_mem = 128'd0;
            2'b01: r_data_mem = r_data1;
            2'b10: r_data_mem = r_data2;
            default: r_data_mem = r_data2;
        endcase
    end
endmodule
