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
    input [33: 0] i_brtype_pcpre_1,
    input [33: 0] i_brtype_pcpre_2,
    input [ 7: 0] i_ecode,

    input [ 0: 0] i_is_valid,

    // flush&stall信号
    input [ 0: 0] flush_BR,
    input [ 0: 0] stall_ICache,
    input [ 0: 0] stall_full_instr,
    input [ 0: 0] BR_predecoder,

    output logic [31: 0] o_PC1,
    output logic [31: 0] o_PC2,
    output logic [33: 0] o_brtype_pcpre_1,
    output logic [33: 0] o_brtype_pcpre_2,
    output logic [ 7: 0] o_ecode_1,
    output logic [ 7: 0] o_ecode_2,

    output logic [ 1: 0] o_is_valid
    );

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;
    assign flush = flush_BR | BR_predecoder;
    assign stall = stall_ICache | stall_full_instr;

    logic [ 1: 0] o_is_valid_temp;

    always @(posedge clk) begin
        if( !rstn ) begin
            o_is_valid_temp <= 2'b00;
        end
        // else if(flush) begin
        //     o_is_valid_temp <= 2'b00;
        // end
        else if(stall) begin
            o_is_valid_temp <= o_is_valid_temp;
        end
        else begin
            o_is_valid_temp <= {2{i_is_valid}};
        end
    end
    assign o_is_valid = o_is_valid_temp & {2{~flush}} & {2{~stall}};

    always @(posedge clk) begin
        if(stall) begin
            o_PC1 <= o_PC1;
            o_PC2 <= o_PC2;
            o_brtype_pcpre_1 <= o_brtype_pcpre_1;
            o_brtype_pcpre_2 <= o_brtype_pcpre_2;
            o_ecode_1 <= o_ecode_1;
            o_ecode_2 <= o_ecode_2;
        end
        else begin
            o_PC1 <= i_PC1;
            o_PC2 <= i_PC2;
            o_brtype_pcpre_1 <= i_brtype_pcpre_1;
            o_brtype_pcpre_2 <= i_brtype_pcpre_2;
            o_ecode_1 <= i_ecode;
            o_ecode_2 <= i_ecode;
        end
    end
endmodule
