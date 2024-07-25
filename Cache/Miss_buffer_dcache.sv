`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/05 12:42:13
// Design Name: 
// Module Name: Miss_buffer_dcache
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


module Miss_buffer_dcache(
    input                 clk,
    input       [31:0]    address,
    input                 way_sel,
    input       [19:0]    r_tagv1,
    input       [19:0]    r_tagv2,
    input                 mbuf_we,
    output  reg [31:0]    d_awaddr_cache
    );
    wire  [31:0]   d_waddr_temp;
    assign d_waddr_temp = way_sel == 1'b1 ? {r_tagv2,address[11:4],4'b0} : {r_tagv1,address[11:4],4'b0};

    always @(posedge clk)begin
        if(mbuf_we) d_awaddr_cache <= d_waddr_temp;
    end
endmodule
