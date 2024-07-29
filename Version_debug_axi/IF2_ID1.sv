`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/28 21:19:03
// Design Name: 
// Module Name: ID1_ID2
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

module IF2_ID1(
    input [ 0: 0] clk,
    input [ 0: 0] rstn,

    input [31: 0] i_PC1,
    input [31: 0] i_IR1,
    input [33: 0] i_brtype_pcpre_1,

    input [31: 0] i_PC2,
    input [31: 0] i_IR2,
    input [33: 0] i_brtype_pcpre_2, 

    input [ 1: 0] i_is_valid,

    // flush&stall信号
    input [ 0: 0] flush_BR,
    input [ 0: 0] stall_full_instr,

    output logic [31: 0] o_PC1,
    output logic [31: 0] o_IR1,
    output logic [33: 0] o_brtype_pcpre_1,

    output logic [31: 0] o_PC2,
    output logic [31: 0] o_IR2,
    output logic [33: 0] o_brtype_pcpre_2,

    output logic [ 1: 0] o_is_valid
    );

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;
    assign flush = flush_BR;
    assign stall = stall_full_instr;

    always @(posedge clk) begin
        if( !rstn ) begin
            o_is_valid <= 2'b00;
        end
        else if(flush) begin
            o_is_valid <= 2'b00;
        end
        else if(stall) begin
            o_is_valid <= o_is_valid;
        end
        else begin
            o_is_valid <= i_is_valid;
        end
    end
    always @(posedge clk) begin
        if( !rstn ) begin
            o_IR1 <= 32'h0;
            o_PC1 <= 32'h0;
            o_brtype_pcpre_1 <= 34'h0;
            o_IR2 <= 32'h0;
            o_PC2 <= 32'h0;
            o_brtype_pcpre_2 <= 34'h0;
        end
        else if(stall) begin
            o_IR1 <= o_IR1;
            o_PC1 <= o_PC1;
            o_brtype_pcpre_1 <= o_brtype_pcpre_1;
            o_IR2 <= o_IR2;
            o_PC2 <= o_PC2;
            o_brtype_pcpre_2 <= o_brtype_pcpre_2;
        end
        else begin
            o_IR1 <= i_IR1;
            o_PC1 <= i_PC1;
            o_brtype_pcpre_1 <= i_brtype_pcpre_1;
            o_IR2 <= i_IR2;
            o_PC2 <= i_PC2;
            o_brtype_pcpre_2 <= i_brtype_pcpre_2;
        end
    end

endmodule