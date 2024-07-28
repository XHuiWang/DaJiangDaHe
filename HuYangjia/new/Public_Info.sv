`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 15:19:26
// Design Name: 
// Module Name: Public_Info
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


package Public_Info;
    // 在包中定义结构体
    typedef struct {
        logic [31: 0] instruction  ;
        logic [31: 0] PC           ;
        logic [ 0: 0] o_inst_lawful;
        logic [ 0: 0] o_valid      ;
        logic [ 9: 0] inst_type    ;
        logic [ 3: 0] br_type      ; 
        logic [31: 0] imm          ;
        logic [ 4: 0] rf_rd        ;
        logic [ 0: 0] rf_we        ;
        logic [ 3: 0] alu_src1_sel ;
        logic [ 3: 0] alu_src2_sel ;
        logic [11: 0] alu_op       ;
        logic [ 0: 0] mem_we       ;
        logic [ 3: 0] ldst_type    ;
        logic [ 0: 0] wb_sel       ;
        logic [ 5: 0] mux_sel      ; // B通道WB来源的选择信号
        logic [ 4: 0] rf_raddr1    ;
        logic [ 4: 0] rf_raddr2    ;
        logic [31: 0] rf_rdata1    ;
        logic [31: 0] rf_rdata2    ;
        logic [ 0: 0] sign_bit     ; // 符号位,运用于乘除法 // 1为有符号数
        logic [ 1: 0] type_predict ; // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
        logic [31: 0] PC_pre       ; // 用于预测分支时得到的PC
        logic [ 2: 0] csr_type     ; // 用于csr指令的类型
        logic [13: 0] csr_raddr    ; // 用于csr指令的读csr地址
        logic [ 6: 0] ecode_in     ; // 用于异常处理的输入
        logic [ 0: 0] ecode_we     ; // 用于异常处理的写曾经，表示已经修改过ecode_in
    } PC_set;
endpackage