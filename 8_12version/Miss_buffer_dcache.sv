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
    input       [1:0]     hit,
    input                 cacop_en_pipe,
    input       [1:0]     cacop_code_pipe,
    output  reg [31:0]    d_awaddr_cache
    );
    reg  [31:0]   d_waddr_temp;
    always @(*) begin
        if(!cacop_en_pipe) d_waddr_temp = way_sel == 1'b1 ? {r_tagv2,address[11:4],4'b0} : {r_tagv1,address[11:4],4'b0};
        else if(cacop_code_pipe == 2'b01) d_waddr_temp = address[0] == 1'b1 ? {r_tagv2,address[11:4],4'b0} : {r_tagv1,address[11:4],4'b0};
        else begin
            if(hit == 2'b01) d_waddr_temp = {r_tagv1,address[11:4],4'b0};
            else d_waddr_temp = {r_tagv2,address[11:4],4'b0};
        end
    end

    always @(posedge clk)begin
        if(mbuf_we) d_awaddr_cache <= d_waddr_temp;
    end
endmodule
