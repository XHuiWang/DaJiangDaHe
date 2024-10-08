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
        logic [ 2: 0] alu_src1_sel ;
        logic [ 2: 0] alu_src2_sel ;
        logic [11: 0] alu_op       ;
        logic [ 0: 0] mem_we       ;
        logic [ 3: 0] ldst_type    ;
        logic [ 0: 0] wb_sel       ;
        logic [ 5: 0] mux_sel      ; // B通道WB来源的选择信号
        logic [ 4: 0] rf_raddr1    ;
        logic [ 4: 0] rf_raddr2    ;
        logic [31: 0] rf_rdata1    ;
        logic [31: 0] rf_rdata2    ;
    } PC_set;
endpackage