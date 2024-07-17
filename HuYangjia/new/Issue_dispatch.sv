`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 13:25:11
// Design Name: 
// Module Name: Issue_dispatch
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

import Public_Info::*;
module Issue_dispatch(
    input [ 0: 0] clk,
    input PC_set i_set1,
    input PC_set i_set2,


    output PC_set o_set1,
    output PC_set o_set2,
    output [ 1: 0] o_usingNUM

    );

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;

    logic [ 0: 0] last_ld;
    logic [ 4: 0] rf_waddr;

    logic [ 0: 0] double_BR;
    logic [ 0: 0] double_LDSW;
    logic [ 0: 0] RAW_exist;
    logic [ 1: 0] ld_exist;




    logic [ 1: 0] i_is_valid;
    assign i_is_valid = {i_set1.o_valid, i_set2.o_valid};


    assign o_set1.instruction   = i_set1.instruction  ;
    assign o_set1.PC            = i_set1.PC           ;
    // assign o_set1.        = i_set1.o_valid      ;
    assign o_set1.inst_type     = i_set1.inst_type    ;
    assign o_set1.br_type       = i_set1.br_type      ;
    assign o_set1.imm           = i_set1.imm          ;
    assign o_set1.rf_rd         = i_set1.rf_rd        ;
    assign o_set1.rf_we         = i_set1.rf_we        ;
    assign o_set1.alu_src1_sel  = i_set1.alu_src1_sel ;
    assign o_set1.alu_src2_sel  = i_set1.alu_src2_sel ;
    assign o_set1.alu_op        = i_set1.alu_op       ;
    assign o_set1.mem_we        = i_set1.mem_we       ;
    assign o_set1.ldst_type     = i_set1.ldst_type    ;
    assign o_set1.wb_sel        = i_set1.wb_sel       ;
    assign o_set1.rf_raddr1     = rf_raddr1           ;
    assign o_set1.rf_raddr2     = rf_raddr2           ;
    assign o_set1.rf_rdata1     = i_set1.rf_rdata1    ;
    assign o_set1.rf_rdata2     = i_set1.rf_rdata2    ;

    assign o_set2.instruction   = i_set2.instruction  ;
    assign o_set2.PC            = i_set2.PC           ;
    // assign o_set2.o_valid       = i_set2.o_valid      ;
    assign o_set2.inst_type     = i_set2.inst_type    ;
    assign o_set2.br_type       = i_set2.br_type      ;
    assign o_set2.imm           = i_set2.imm          ;
    assign o_set2.rf_rd         = i_set2.rf_rd        ;
    assign o_set2.rf_we         = i_set2.rf_we        ;
    assign o_set2.alu_src1_sel  = i_set2.alu_src1_sel ;
    assign o_set2.alu_src2_sel  = i_set2.alu_src2_sel ;
    assign o_set2.alu_op        = i_set2.alu_op       ;
    assign o_set2.mem_we        = i_set2.mem_we       ;
    assign o_set2.ldst_type     = i_set2.ldst_type    ;
    assign o_set2.wb_sel        = i_set2.wb_sel       ;
    assign o_set2.rf_raddr1     = rf_raddr1           ;
    assign o_set2.rf_raddr2     = rf_raddr2           ;
    assign o_set2.rf_rdata1     = i_set2.rf_rdata1    ;
    assign o_set2.rf_rdata2     = i_set2.rf_rdata2    ;

    always @(*) begin
        if(flush || stall) begin
            o_set1.o_valid = 1'b0;
            o_set2.o_valid = 1'b0;
            o_usingNUM = 2'b00;
        end
        else begin
            case (i_is_valid)
                2'b00: begin
                    o_set1.o_valid = 1'b0;
                    o_set2.o_valid = 1'b0;
                    o_usingNUM = 2'b00;
                end
                2'b10: begin
                    o_set1.o_valid = 1'b1;
                    o_set2.o_valid = 1'b0;
                    o_usingNUM = 2'b01;
                end
                2'b01: begin
                    o_set1.o_valid = 1'b0;
                    o_set2.o_valid = 1'b0;
                    o_usingNUM = 2'b00;
                end
                2'b11: begin
                    // 两个合法，开始检测
                    if(double_BR || double_LDSW || RAW_exist) begin
                        o_set1.o_valid = 1'b1;
                        o_set2.o_valid = 1'b0;
                        o_usingNUM = 2'd1;
                    end
                    else begin
                        o_set1.o_valid = 1'b1;
                        o_set2.o_valid = 1'b1;
                        o_usingNUM = 2'd2;
                    end
                end
            endcase
        end
    end
    assign ld_exist[1] = (o_usingNUM != 0) ? ~(i_set1.ldst_type[3]) : 0;
    assign ld_exist[0] = (o_usingNUM == 2) ? ~(i_set2.ldst_type[3]) : 0;


    assign double_BR   = (i_is_valid == 2'b11) ? ( (|(i_set1.br_type)) && (|(i_set2.br_type))) : 0; // 同时为BR，两个都不是全0
    assign double_LDSW = (i_is_valid == 2'b11) ? ( ~((i_set1.ldst_type[3]) | (i_set2.ldst_type[3])) ) : 0; // 同时为LDSW，最高位都是0
    assign RAW_exist   = (i_is_valid == 2'b11 && i_set1.rf_rd != 0) ? ( (i_set1.rf_rd == i_set2.rf_raddr1) || (i_set1.rf_rd == i_set2.rf_raddr2) ) : 0; // 前rd=后rf,且rd = 0


    always @(posedge clk) begin
        last_ld <= |ld_exist;
        rf_waddr <= (ld_exist[1]) ? i_set1.rf_rd : i_set2.rf_rd;
    end



endmodule
