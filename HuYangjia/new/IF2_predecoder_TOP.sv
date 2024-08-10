`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 16:26:50
// Design Name: 
// Module Name: IF2_predecoder_TOP
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


module IF2_predecoder_TOP(
    input [31: 0] IR1,
    input [31: 0] IR2,
    input [31: 0] PC1,
    input [31: 0] PC2,
    input [31: 0] PC1_plus_4,
    input [31: 0] PC2_plus_4,
    input [33: 0] brtype_pcpre1,
    input [33: 0] brtype_pcpre2,
    input [ 1: 0] i_is_valid,

    output logic [ 1: 0] o_is_valid, // PC有效信号
    output logic [31: 0] PC_fact,
    output logic [ 0: 0] predecoder_BR, // 是否跳转信号
    output logic [33: 0] type_pcpre_1,
    output logic [33: 0] type_pcpre_2
    );

    logic [ 0: 0] o_valid1;
    logic [ 0: 0] o_valid2;
    logic [31: 0] PC_fact1;
    logic [31: 0] PC_fact2;

    wire [ 0: 0] data_valid_1;
    wire [ 0: 0] data_valid_0;
    assign data_valid_1 = i_is_valid[1];
    assign data_valid_0 = i_is_valid[0];

    IF2_PreDecoder  IF2_PreDecoder_inst_1 (
        .IF_IR(IR1),
        .PC(PC1),
        .PC_plus_4(PC1_plus_4),
        .brtype_pcpre(brtype_pcpre1),
        .data_valid(data_valid_1),
        .o_valid(o_valid1),
        .PC_fact(PC_fact1),
        .type_pcpre(type_pcpre_1)
    );
    IF2_PreDecoder  IF2_PreDecoder_inst_2 (
        .IF_IR(IR2),
        .PC(PC2),
        .PC_plus_4(PC2_plus_4),
        .brtype_pcpre(brtype_pcpre2),
        .data_valid(data_valid_0),
        .o_valid(o_valid2),
        .PC_fact(PC_fact2),
        .type_pcpre(type_pcpre_2)
    );
    assign o_is_valid = (o_valid1) ? 2'b10 : 2'b11;
    assign predecoder_BR = o_valid1 | o_valid2;
    assign PC_fact = (o_valid1) ? PC_fact1 : PC_fact2;
endmodule
