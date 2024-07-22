`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 15:17:16
// Design Name: 
// Module Name: My_CPU_test
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

`include "Public_Info.sv"
import Public_Info::*;
module My_CPU_test(
    input clk,
    input rstn
    );
    
    
    PC_set PC_set1_front;
    PC_set PC_set2_front;
    PC_set PC_set1_back ;
    PC_set PC_set2_back ;
    PC_set set_final_1 ;
    PC_set set_final_2 ;


    logic [31: 0] pc_predict;
    logic [31: 0] pc_BR;
    logic [31: 0] pc_IF1;
    logic [ 0: 0] is_valid;
  

    logic [ 0: 0] clk;
    logic [ 0: 0] rstn;
    // logic [31: 0] i_PC1_IF1;
    // logic [31: 0] i_PC2_IF1;
    logic [31: 0] i_PC1;
    logic [31: 0] i_IR1;
    logic [31: 0] i_PC2;
    logic [31: 0] i_IR2;
    logic [ 1: 0] i_is_valid;
    logic [31: 0] o_PC1;
    logic [31: 0] o_IR1;
    logic [31: 0] o_PC2;
    logic [31: 0] o_IR2;
    logic [ 1: 0] o_is_valid;
    logic [ 0: 0] o_is_full;
    logic [ 0: 0] ID_status;


    // RegFile中的信号
    logic [ 0: 0] clk;
    logic [31: 0] raddr_a1;
    logic [ 4: 0] raddr_a2;
    logic [ 4: 0] raddr_b1;
    logic [ 4: 0] raddr_b2;
    logic [31: 0] rdata_a1;
    logic [31: 0] rdata_a2;
    logic [31: 0] rdata_b1;
    logic [31: 0] rdata_b2;
    logic [ 4: 0] addr;
    logic [31: 0] dout_rf;
    logic [ 4: 0] waddr_a;
    logic [ 4: 0] waddr_b;
    logic [31: 0] wdata_a;
    logic [31: 0] wdata_b;
    logic we_a;
    logic we_b;


    logic [ 1: 0] i_usingNUM;

    // Issue Buffer
    logic [ 1: 0] o_is_valid_2;
    logic [ 0: 0] o_is_full_2;

    // Issue_EXE
    logic [ 0: 0] EX_a_enable;
    logic [ 0: 0] EX_b_enable;
    logic [31: 0] EX_pc_a;
    logic [31: 0] EX_pc_b;
    logic [ 4: 0] EX_rf_raddr_a1;
    logic [ 4: 0] EX_rf_raddr_a2;
    logic [ 4: 0] EX_rf_raddr_b1;
    logic [ 4: 0] EX_rf_raddr_b2;
    logic [31: 0] EX_rf_rdata_a1;
    logic [31: 0] EX_rf_rdata_a2;
    logic [31: 0] EX_rf_rdata_b1;
    logic [31: 0] EX_rf_rdata_b2;
    logic [31: 0] EX_imm_a;
    logic [31: 0] EX_imm_b;
    logic [ 2: 0] EX_alu_src_sel_a1;
    logic [ 2: 0] EX_alu_src_sel_a2;
    logic [ 2: 0] EX_alu_src_sel_b1;
    logic [ 2: 0] EX_alu_src_sel_b2;
    logic [11: 0] EX_alu_op_a;
    logic [11: 0] EX_alu_op_b;
    logic [ 3: 0] EX_br_type_a;
    logic [ 3: 0] EX_br_type_b;
    logic [ 0: 0] EX_br_pd_a;
    logic [ 0: 0] EX_br_pd_b;
    logic [ 0: 0] EX_rf_we_a;
    logic [ 0: 0] EX_rf_we_b;
    logic [ 4: 0] EX_rf_waddr_a;
    logic [ 4: 0] EX_rf_waddr_b;
    logic [ 0: 0] EX_mem_we_a;
    logic [ 0: 0] EX_mem_we_b;
    logic [ 2: 0] EX_mem_type_a;
    logic [ 2: 0] EX_mem_type_b;
    logic [ 5: 0] EX_mux_select;
  
  

        
    // output from EXE
    logic [ 0: 0] WB_rf_we_a;
    logic [ 0: 0] WB_rf_we_b;
    logic [ 4: 0] WB_rf_waddr_a;
    logic [ 4: 0] WB_rf_waddr_b;
    logic [31: 0] WB_rf_wdata_a;
    logic [31: 0] WB_rf_wdata_b;
    logic [ 0: 0] EX_br;
    logic [31: 0] EX_pc_br;
    
    // stall && flush
    logic [ 0: 0] stall_DCache; // 由于Dcache缺失带来的逻辑的stall信号，只作用于issue Buffer
    logic [ 0: 0] stall_dcache; // 由于Dcache缺失带来的真正的stall信号
    logic [ 0: 0] stall_full_issue; // 由于issue Buffer满带来的stall信号，只作用于Instruction Buffer
    logic [ 0: 0] stall_full_instr; // 由于Instruction Buffer满带来的stall信号，作用于IF1
    logic [ 0: 0] stall_ICache; // 由于Icache缺失带来的stall信号，作用于IF1的取值模块和IF1_IF2段间寄存器
    logic [ 0: 0] flush_BR; // 由于分支预测错误带来的flush信号，作用于两个Buffer和IF1_IF2段间寄存器，作用于ICache(在Miss则停止操作)

    // temp测试
    assign stall_ICache = 0;
    assign stall_DCache = stall_dcache;
    assign flush_BR = EX_br;
    assign stall_full_issue = o_is_full_2;
    assign stall_full_instr = o_is_full;
    
  
    assign pc_predict = pc_IF1 + 8;

    IF1  IF1_inst (
        .clk(clk),
        .rstn(rstn),
        .pc_predict(pc_predict),
        .pc_BR(EX_pc_br),
        .EX_BR(EX_br),
        .stall_ICache(stall_ICache),
        .stall_full_instr(stall_full_instr),
        .pc_IF1(pc_IF1),
        .is_valid(is_valid)
    );

    temp IMeM (
        .clka(clk),    // input wire clka
        .wea(0),      // input wire [0 : 0] wea
        .addra(pc_IF1[14: 2]),  // input wire [12 : 0] addra
        .dina(0),    // input wire [31 : 0] dina
        .douta(i_IR1),  // output wire [31 : 0] douta
        .clkb(clk),    // input wire clkb
        .web(0),      // input wire [0 : 0] web
        .addrb(pc_IF1[14: 2]+1),  // input wire [12 : 0] addrb
        .dinb(0),    // input wire [31 : 0] dinb
        .doutb(i_IR2)  // output wire [31 : 0] doutb
    );

    IF1_IF2  IF1_IF2_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC1(pc_IF1),
        .i_PC2(pc_IF1+4),
        .flush_BR(flush_BR),
        .stall_ICache(stall_ICache),
        .o_PC1(i_PC1),
        .o_PC2(i_PC2),
        .o_is_valid(i_is_valid)
    );

    
    IF2_ID1  IF2_ID1_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC1(i_PC1),
        .i_IR1(i_IR1),
        .i_PC2(i_PC2),
        .i_IR2(i_IR2),
        .i_is_valid(i_is_valid),
        .flush_BR(flush_BR),
        .stall_ICache(stall_ICache),
        .stall_full_issue(stall_full_issue),
        .o_PC1(o_PC1),
        .o_IR1(o_IR1),
        .o_PC2(o_PC2),
        .o_IR2(o_IR2),
        .o_is_valid(o_is_valid),
        .o_is_full(o_is_full),
        .ID_status(ID_status)
    );
    // logic [ 0: 0] ID_status;
    ID_Decode_edi_2  ID_Decode_edi_2_inst_1 (
        .IF_IR(o_IR1),
        .PC(o_PC1),
        .ID_status(ID_status),
        .data_valid(o_is_valid[1]),
        .PC_set(PC_set1_front)
    );
    ID_Decode_edi_2  ID_Decode_edi_2_inst_2 (
        .IF_IR(o_IR2),
        .PC(o_PC2),
        .ID_status(ID_status),
        .data_valid(o_is_valid[0]),
        .PC_set(PC_set2_front)
    );

    ID_REG  ID_REG_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC_set1(PC_set1_front),
        .i_PC_set2(PC_set2_front),
        .i_usingNUM(i_usingNUM),
        .flush_BR(flush_BR),
        .stall_DCache(stall_DCache),
        .o_PC_set1(PC_set1_back),
        .o_PC_set2(PC_set2_back),
        .a_rf_raddr1(raddr_a1),
        .a_rf_raddr2(raddr_a2),
        .b_rf_raddr1(raddr_b1),
        .b_rf_raddr2(raddr_b2),
        .o_is_valid(o_is_valid_2),
        .o_is_full(o_is_full_2)
    );
    
    

    RF # (
        .ADDR_WIDTH(5),
        .DATA_WIDTH(32)
    )
    RF_inst (
        .clk(clk),
        .raddr_a1(raddr_a1),
        .raddr_a2(raddr_a2),
        .raddr_b1(raddr_b1),
        .raddr_b2(raddr_b2),
        .rdata_a1(rdata_a1),
        .rdata_a2(rdata_a2),
        .rdata_b1(rdata_b1),
        .rdata_b2(rdata_b2),
        .addr(addr),
        .dout_rf(dout_rf),
        .waddr_a(WB_rf_waddr_a),
        .waddr_b(WB_rf_waddr_b),
        .wdata_a(WB_rf_wdata_a),
        .wdata_b(WB_rf_wdata_b),
        .we_a(WB_rf_we_a),
        .we_b(WB_rf_we_b)
    );

    Issue_dispatch  Issue_dispatch_inst (
        .clk(clk),
        .i_set1(PC_set1_back),
        .i_set2(PC_set2_back),
        .i_is_valid(o_is_valid_2),
        .o_set1(set_final_1),
        .o_set2(set_final_2),
        .o_usingNUM(i_usingNUM)
    );


    Issue_EXE  Issue_EXE_inst (
        .clk(clk),
        .rstn(rstn),
        .i_set1(set_final_1),
        .i_set2(set_final_2),
        .rdata_a1(rdata_a1),
        .rdata_a2(rdata_a2),
        .rdata_b1(rdata_b1),
        .rdata_b2(rdata_b2),
        .flush_BR(flush_BR),
        .stall_DCache(stall_DCache),
        .EX_a_enable(EX_a_enable),
        .EX_b_enable(EX_b_enable),
        .EX_pc_a(EX_pc_a),
        .EX_pc_b(EX_pc_b),
        .EX_rf_raddr_a1(EX_rf_raddr_a1),
        .EX_rf_raddr_a2(EX_rf_raddr_a2),
        .EX_rf_raddr_b1(EX_rf_raddr_b1),
        .EX_rf_raddr_b2(EX_rf_raddr_b2),
        .EX_rf_rdata_a1(EX_rf_rdata_a1),
        .EX_rf_rdata_a2(EX_rf_rdata_a2),
        .EX_rf_rdata_b1(EX_rf_rdata_b1),
        .EX_rf_rdata_b2(EX_rf_rdata_b2),
        .EX_imm_a(EX_imm_a),
        .EX_imm_b(EX_imm_b),
        .EX_alu_src_sel_a1(EX_alu_src_sel_a1),
        .EX_alu_src_sel_a2(EX_alu_src_sel_a2),
        .EX_alu_src_sel_b1(EX_alu_src_sel_b1),
        .EX_alu_src_sel_b2(EX_alu_src_sel_b2),
        .EX_alu_op_a(EX_alu_op_a),
        .EX_alu_op_b(EX_alu_op_b),
        .EX_br_type_a(EX_br_type_a),
        .EX_br_type_b(EX_br_type_b),
        .EX_br_pd_a(EX_br_pd_a),
        .EX_br_pd_b(EX_br_pd_b),
        .EX_rf_we_a(EX_rf_we_a),
        .EX_rf_we_b(EX_rf_we_b),
        .EX_mux_sel(EX_mux_select),
        .EX_rf_waddr_a(EX_rf_waddr_a),
        .EX_rf_waddr_b(EX_rf_waddr_b),
        .EX_mem_we_a(EX_mem_we_a),
        .EX_mem_we_b(EX_mem_we_b),
        .EX_mem_type_a(EX_mem_type_a),
        .EX_mem_type_b(EX_mem_type_b)
    );
    

    ex_mem_wb  ex_mem_wb_inst (
        .clk(clk),
        .rstn(rstn),
        .EX_pc_a(EX_pc_a),
        .EX_pc_b(EX_pc_b),
        .EX_rf_rdata_a1(EX_rf_rdata_a1),
        .EX_rf_rdata_a2(EX_rf_rdata_a2),
        .EX_rf_rdata_b1(EX_rf_rdata_b1),
        .EX_rf_rdata_b2(EX_rf_rdata_b2),
        .EX_imm_a(EX_imm_a),
        .EX_imm_b(EX_imm_b),
        .EX_rf_raddr_a1(EX_rf_raddr_a1),
        .EX_rf_raddr_a2(EX_rf_raddr_a2),
        .EX_rf_raddr_b1(EX_rf_raddr_b1),
        .EX_rf_raddr_b2(EX_rf_raddr_b2),
        .EX_alu_src_sel_a1(EX_alu_src_sel_a1),
        .EX_alu_src_sel_a2(EX_alu_src_sel_a2),
        .EX_alu_src_sel_b1(EX_alu_src_sel_b1),
        .EX_alu_src_sel_b2(EX_alu_src_sel_b2),
        .EX_alu_op_a(EX_alu_op_a),
        .EX_alu_op_b(EX_alu_op_b),
        .EX_br_type_a(EX_br_type_a),
        .EX_br_type_b(EX_br_type_b),
        .EX_br_pd_a(EX_br_pd_a),
        .EX_br_pd_b(EX_br_pd_b),
        .EX_rf_we_a(EX_rf_we_a),
        .EX_rf_we_b(EX_rf_we_b),
        .EX_rf_waddr_a(EX_rf_waddr_a),
        .EX_rf_waddr_b(EX_rf_waddr_b),
        .EX_mem_we_a(EX_mem_we_a),
        .EX_mem_we_b(EX_mem_we_b),
        .EX_mem_type_a(EX_mem_type_a),
        .EX_mem_type_b(EX_mem_type_b),
        .EX_wb_mux_select_b(EX_mux_select),
        .WB_rf_we_a(WB_rf_we_a),
        .WB_rf_we_b(WB_rf_we_b),
        .WB_rf_waddr_a(WB_rf_waddr_a),
        .WB_rf_waddr_b(WB_rf_waddr_b),
        .WB_rf_wdata_a(WB_rf_wdata_a),
        .WB_rf_wdata_b(WB_rf_wdata_b),
        .EX_br(EX_br),
        .EX_pc_br(EX_pc_br),
        .stall_dcache(stall_dcache)
    );

endmodule
