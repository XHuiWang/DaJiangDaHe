`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/13 12:56:15
// Design Name: 
// Module Name: read_manage_dcache
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


module read_manage_dcache(
    input [127:0] r_data_mem,
    input [1:0]  offset,
    output reg  [31:0] data_from_dcache
    );
always @(*) begin
    case(offset)
    2'b00: data_from_dcache = r_data_mem[31:0];
    2'b01: data_from_dcache = r_data_mem[63:32];
    2'b10: data_from_dcache = r_data_mem[95:64];
    2'b11: data_from_dcache = r_data_mem[127:96];
endcase
end
endmodule

