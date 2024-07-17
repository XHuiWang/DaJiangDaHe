`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 21:38:34
// Design Name: 
// Module Name: Issue_EXE
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

// 从Issue_Buffer中决策取出需要的指令，发射到EXE阶段
/*
    需要组装REGFILE中取出的数据
*/

import Public_Info::*;
module Issue_EXE(
    input [ 0: 0] clk,
    input [ 0: 0] rstn,


    input PC_set i_set1,
    input PC_set i_set2,

    input [31: 0] rdata_a1,
    input [31: 0] rdata_a2,
    input [31: 0] rdata_b1,
    input [31: 0] rdata_b2,

    output logic [ 0: 0] EX_a_enable,        //A指令是否有效
    output logic [ 0: 0] EX_b_enable,        //B指令是否有效

    output logic [31: 0] EX_pc_a,            //A指令的PC值
    output logic [31: 0] EX_pc_b,            //B指令的PC值
    output logic [31: 0] EX_rf_rdata_a1,     //A指令的第一个寄存器的值
    output logic [31: 0] EX_rf_rdata_a2,     //A指令的第二个寄存器的值
    output logic [31: 0] EX_rf_rdata_b1,     //B指令的第一个寄存器的值
    output logic [31: 0] EX_rf_rdata_b2,     //B指令的第二个寄存器的值
    output logic [31: 0] EX_imm_a,           //A指令的立即数
    output logic [31: 0] EX_imm_b,           //B指令的立即数

    output logic [ 1: 0] EX_alu_src_sel_a1,  //A指令的第一个操作数选择信号
    output logic [ 1: 0] EX_alu_src_sel_a2,  //A指令的第二个操作数选择信号
    output logic [ 1: 0] EX_alu_src_sel_b1,  //B指令的第一个操作数选择信号
    output logic [ 1: 0] EX_alu_src_sel_b2,  //B指令的第二个操作数选择信号
    output logic [11: 0] EX_alu_op_a,        //A指令的运算类型
    output logic [11: 0] EX_alu_op_b,        //B指令的运算类型

    output logic [ 3: 0] EX_br_type_a,       //A指令的分支类型
    output logic [ 3: 0] EX_br_type_b,       //B指令的分支类型
    output logic [ 0: 0] EX_br_pd_a,         //predict A指令的分支预测，1预测跳转，0预测不跳转
    output logic [ 0: 0] EX_br_pd_b,         //predict B指令的分支预测，1预测跳转，0预测不跳转

    output logic [ 0: 0] EX_rf_we_a,         //A指令寄存器写使能
    output logic [ 0: 0] EX_rf_we_b,         //B指令寄存器写使能
    output logic [ 4: 0] EX_rf_waddr_a,      //A指令寄存器写地址
    output logic [ 4: 0] EX_rf_waddr_b,      //B指令寄存器写地址

    output logic [ 0: 0]  EX_mem_we_a,        //A指令内存写使能
    output logic [ 0: 0]  EX_mem_we_b,        //B指令内存写使能
    output logic [ 0: 0]  EX_br,              //是否需要修正预测的结果
    output logic [31: 0]  EX_pc_br,           //修正时应跳转到的地址

    output logic [ 0: 0]  EX_mem_we_bb        //考虑A为BR指令时的修正问题后，B指令内存写使能      


    );

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;

    PC_set error_set;
    assign error_set.o_valid = 1'b0;

    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            EX_a_enable <= 1'b0;
            EX_b_enable <= 1'b0;
        end
        else if(flush) begin
            EX_a_enable <= 1'b0;
            EX_b_enable <= 1'b0;
        end
        else if(stall) begin
            EX_a_enable <= 1'b0;
            EX_b_enable <= 1'b0;
        end
        else begin
            EX_a_enable <= i_set1.o_valid;
            EX_b_enable <= i_set2.o_valid;
        end
    end

    always @(posedge clk) begin
        EX_pc_a        <= i_set1.PC;
        EX_pc_b        <= i_set2.PC;
        EX_rf_rdata_a1 <= rdata_a1;
        EX_rf_rdata_a2 <= rdata_a2;
        EX_rf_rdata_b1 <= rdata_b1;
        EX_rf_rdata_b2 <= rdata_b2;
        EX_imm_a       <= i_set1.imm;
        EX_imm_b       <= i_set2.imm;
        EX_alu_src_sel_a1 <= i_set1.alu_src1_sel;
        EX_alu_src_sel_a2 <= i_set1.alu_src2_sel;
        EX_alu_src_sel_b1 <= i_set2.alu_src1_sel;
        EX_alu_src_sel_b2 <= i_set2.alu_src2_sel;
        EX_alu_op_a       <= i_set1.alu_op;
        EX_alu_op_b       <= i_set2.alu_op;
        EX_br_type_a      <= i_set1.br_type;
        EX_br_type_b      <= i_set2.br_type;
        // EX_br_pd_a        <= i_set1.o_inst_lawful;
        // EX_br_pd_b        <= i_set2.o_inst_lawful;
        EX_rf_we_a        <= i_set1.rf_we;
        EX_rf_we_b        <= i_set2.rf_we;
        EX_rf_waddr_a     <= i_set1.rf_rd;
        EX_rf_waddr_b     <= i_set2.rf_rd;
        EX_mem_we_a       <= i_set1.mem_we;
        EX_mem_we_b       <= i_set2.mem_we;
        // EX_br             <= 1'b0;
        // EX_pc_br          <= 32'h0000_0000;
        // EX_mem_we_bb      <= 1'b0;
    end
endmodule
