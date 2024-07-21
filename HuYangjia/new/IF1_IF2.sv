`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 15:50:30
// Design Name: 
// Module Name: IF1_IF2
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


module IF1_IF2(
    input [ 0: 0] clk,
    input [ 0: 0] rstn,

    input [31: 0] i_PC1,
    input [31: 0] i_PC2,

    // flush&stall信号
    input [ 0: 0] flush_BR,
    input [ 0: 0] stall_ICache,

    output logic [31: 0] o_PC1,
    output logic [31: 0] o_PC2,

    output logic [ 1: 0] o_is_valid
    );

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;
    assign flush = flush_BR;
    assign stall = stall_ICache;

    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            o_is_valid <= 2'b00;
        end
        else begin
            if(flush) begin
                o_is_valid <= 2'b00;
            end
            else begin
                o_is_valid <= 2'b11;
            end
        end
    end
    always @(posedge clk) begin
        if(stall) begin
            o_PC1 <= o_PC1;
            o_PC2 <= o_PC2;
        end
        else begin
            o_PC1 <= i_PC1;
            o_PC2 <= i_PC2;
        end
    end
endmodule
