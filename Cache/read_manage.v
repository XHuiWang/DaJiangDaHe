`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 17:00:44
// Design Name: 
// Module Name: read_manage
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


module read_manage(
    input [127:0] r_data_mem,
    input [1:0]  offset,
    output reg  [31:0] inst_from_icache
    );
always @(*) begin
    case(offset)
    2'b00: inst_from_icache = r_data_mem[31:0];
    2'b01: inst_from_icache = r_data_mem[63:32];
    2'b10: inst_from_icache = r_data_mem[95:64];
    2'b11: inst_from_icache = r_data_mem[127:96];
endcase
end
endmodule
