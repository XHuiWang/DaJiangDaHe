`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 22:31:36
// Design Name: 
// Module Name: Issue_dispatch_edi_2
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


module Issue_dispatch_edi_2(
    input [ 0: 0] clk,

    input [31: 0] i_set1_instruction   ,
    input [31: 0] i_set1_PC            ,
    input [ 0: 0] i_set1_o_inst_lawful ,
    input [ 0: 0] i_set1_o_valid       ,
    input [ 9: 0] i_set1_inst_type     ,
    input [ 9: 0] i_set1_br_type       , 
    input [31: 0] i_set1_imm           ,
    input [ 4: 0] i_set1_rf_rd         ,
    input [ 0: 0] i_set1_rf_we         ,
    input [ 3: 0] i_set1_alu_src1_sel  ,
    input [ 3: 0] i_set1_alu_src2_sel  ,
    input [11: 0] i_set1_alu_op        ,
    input [ 0: 0] i_set1_mem_we        ,
    input [ 3: 0] i_set1_ldst_type     ,
    input [ 8: 0] i_set1_mux_sel       , // B通道WB来源的选择信号
    input [ 4: 0] i_set1_rf_raddr1     ,
    input [ 4: 0] i_set1_rf_raddr2     ,
    input [31: 0] i_set1_rf_rdata1     ,
    input [31: 0] i_set1_rf_rdata2     ,
    input [ 0: 0] i_set1_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    input [ 1: 0] i_set1_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    input [31: 0] i_set1_PC_pre        , // 用于预测分支时得到的PC
    input [ 2: 0] i_set1_csr_type      , // 用于csr指令的类型
    input [13: 0] i_set1_csr_raddr     , // 用于csr指令的读csr地址
    input [ 6: 0] i_set1_ecode_in      , // 用于异常处理的输入
    input [ 0: 0] i_set1_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    input [ 4: 0] i_set1_code_for_cacop, // 用于cacop指令的code

    input [31: 0] i_set2_instruction   ,
    input [31: 0] i_set2_PC            ,
    input [ 0: 0] i_set2_o_inst_lawful ,
    input [ 0: 0] i_set2_o_valid       ,
    input [ 9: 0] i_set2_inst_type     ,
    input [ 9: 0] i_set2_br_type       , 
    input [31: 0] i_set2_imm           ,
    input [ 4: 0] i_set2_rf_rd         ,
    input [ 0: 0] i_set2_rf_we         ,
    input [ 3: 0] i_set2_alu_src1_sel  ,
    input [ 3: 0] i_set2_alu_src2_sel  ,
    input [11: 0] i_set2_alu_op        ,
    input [ 0: 0] i_set2_mem_we        ,
    input [ 3: 0] i_set2_ldst_type     ,
    input [ 8: 0] i_set2_mux_sel       , // B通道WB来源的选择信号
    input [ 4: 0] i_set2_rf_raddr1     ,
    input [ 4: 0] i_set2_rf_raddr2     ,
    input [31: 0] i_set2_rf_rdata1     ,
    input [31: 0] i_set2_rf_rdata2     ,
    input [ 0: 0] i_set2_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    input [ 1: 0] i_set2_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    input [31: 0] i_set2_PC_pre        , // 用于预测分支时得到的PC
    input [ 2: 0] i_set2_csr_type      , // 用于csr指令的类型
    input [13: 0] i_set2_csr_raddr     , // 用于csr指令的读csr地址
    input [ 6: 0] i_set2_ecode_in      , // 用于异常处理的输入
    input [ 0: 0] i_set2_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    input [ 4: 0] i_set2_code_for_cacop, // 用于cacop指令的code

    input [ 1: 0] i_is_valid,
    input [ 0: 0] stall,
    input [ 0: 0] flush,


    output logic [31: 0] o_set1_instruction   ,
    output logic [31: 0] o_set1_PC            ,
    output logic [ 0: 0] o_set1_o_inst_lawful ,
    output logic [ 0: 0] o_set1_o_valid       ,
    output logic [ 9: 0] o_set1_inst_type     ,
    output logic [ 9: 0] o_set1_br_type       , 
    output logic [31: 0] o_set1_imm           ,
    output logic [ 4: 0] o_set1_rf_rd         ,
    output logic [ 0: 0] o_set1_rf_we         ,
    output logic [ 3: 0] o_set1_alu_src1_sel  ,
    output logic [ 3: 0] o_set1_alu_src2_sel  ,
    output logic [11: 0] o_set1_alu_op        ,
    output logic [ 0: 0] o_set1_mem_we        ,
    output logic [ 3: 0] o_set1_ldst_type     ,
    output logic [ 8: 0] o_set1_mux_sel       , // B通道WB来源的选择信号
    output logic [ 4: 0] o_set1_rf_raddr1     ,
    output logic [ 4: 0] o_set1_rf_raddr2     ,
    output logic [31: 0] o_set1_rf_rdata1     ,
    output logic [31: 0] o_set1_rf_rdata2     ,
    output logic [ 0: 0] o_set1_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    output logic [ 1: 0] o_set1_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    output logic [31: 0] o_set1_PC_pre        , // 用于预测分支时得到的PC
    output logic [ 2: 0] o_set1_csr_type      , // 用于csr指令的类型
    output logic [13: 0] o_set1_csr_raddr     , // 用于csr指令的读csr地址
    output logic [ 6: 0] o_set1_ecode_in      , // 用于异常处理的输入
    output logic [ 0: 0] o_set1_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    output logic [ 4: 0] o_set1_code_for_cacop, // 用于cacop指令的code
    
    
    output logic [31: 0] o_set2_instruction   ,
    output logic [31: 0] o_set2_PC            ,
    output logic [ 0: 0] o_set2_o_inst_lawful ,
    output logic [ 0: 0] o_set2_o_valid       ,
    output logic [ 9: 0] o_set2_inst_type     ,
    output logic [ 9: 0] o_set2_br_type       , 
    output logic [31: 0] o_set2_imm           ,
    output logic [ 4: 0] o_set2_rf_rd         ,
    output logic [ 0: 0] o_set2_rf_we         ,
    output logic [ 3: 0] o_set2_alu_src1_sel  ,
    output logic [ 3: 0] o_set2_alu_src2_sel  ,
    output logic [11: 0] o_set2_alu_op        ,
    output logic [ 0: 0] o_set2_mem_we        ,
    output logic [ 3: 0] o_set2_ldst_type     ,
    output logic [ 8: 0] o_set2_mux_sel       , // B通道WB来源的选择信号
    output logic [ 4: 0] o_set2_rf_raddr1     ,
    output logic [ 4: 0] o_set2_rf_raddr2     ,
    output logic [31: 0] o_set2_rf_rdata1     ,
    output logic [31: 0] o_set2_rf_rdata2     ,
    output logic [ 0: 0] o_set2_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    output logic [ 1: 0] o_set2_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    output logic [31: 0] o_set2_PC_pre        , // 用于预测分支时得到的PC
    output logic [ 2: 0] o_set2_csr_type      , // 用于csr指令的类型
    output logic [13: 0] o_set2_csr_raddr     , // 用于csr指令的读csr地址
    output logic [ 6: 0] o_set2_ecode_in      , // 用于异常处理的输入
    output logic [ 0: 0] o_set2_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    output logic [ 4: 0] o_set2_code_for_cacop, // 用于cacop指令的code


    output logic [ 1: 0] o_usingNUM

    );

    // logic [ 0: 0] flush;
    // logic [ 0: 0] stall;

    logic [ 0: 0] last_ld;
    logic [ 4: 0] rf_waddr;

    logic [ 0: 0] double_BR;
    logic [ 0: 0] signle_cacop; // 确定是否是两条指令有效的情况下，B是cacop
    logic [ 0: 0] LDSW_Mul_Div_csr_rdcnt_cacop_plus_any;
    logic [ 0: 0] BR_exception_plus_LDST_cacop_prob;
    // logic [ 0: 0] any_plus_LDSW;
    logic [ 0: 0] RAW_exist;
    logic [ 1: 0] ld_exist;
    logic [ 1: 0] rdcnt_exist;
    logic [ 1: 0] mul_div_exist;
    logic [ 0: 0] lock_in_1;
    logic [ 0: 0] lock_in_2;




    logic [ 1: 0] is_valid;
    assign is_valid = {i_set1_o_valid & i_is_valid[1], i_set2_o_valid & i_is_valid[0]};


    assign o_set1_instruction    = i_set1_instruction   ;
    assign o_set1_PC             = i_set1_PC            ;
    assign o_set1_o_inst_lawful  = i_set1_o_inst_lawful ;
    assign o_set1_inst_type      = i_set1_inst_type     ;
    assign o_set1_br_type        = i_set1_br_type       ;
    assign o_set1_imm            = i_set1_imm           ;
    assign o_set1_rf_rd          = i_set1_rf_rd         ;
    assign o_set1_rf_we          = i_set1_rf_we         ;
    assign o_set1_alu_src1_sel   = i_set1_alu_src1_sel  ;
    assign o_set1_alu_src2_sel   = i_set1_alu_src2_sel  ;
    assign o_set1_alu_op         = i_set1_alu_op        ;
    assign o_set1_mem_we         = i_set1_mem_we        ;
    assign o_set1_ldst_type      = i_set1_ldst_type     ;
    assign o_set1_mux_sel        = i_set1_mux_sel       ;
    assign o_set1_rf_raddr1      = i_set1_rf_raddr1     ;
    assign o_set1_rf_raddr2      = i_set1_rf_raddr2     ;
    assign o_set1_rf_rdata1      = i_set1_rf_rdata1     ;
    assign o_set1_rf_rdata2      = i_set1_rf_rdata2     ;
    assign o_set1_sign_bit       = i_set1_sign_bit      ;
    assign o_set1_type_predict   = i_set1_type_predict  ;
    assign o_set1_PC_pre         = i_set1_PC_pre        ;
    assign o_set1_csr_type       = i_set1_csr_type      ;
    assign o_set1_csr_raddr      = i_set1_csr_raddr     ;
    assign o_set1_ecode_in       = i_set1_ecode_in      ;
    assign o_set1_ecode_we       = i_set1_ecode_we      ;
    assign o_set1_code_for_cacop = i_set1_code_for_cacop;


    assign o_set2_instruction    = i_set2_instruction   ;
    assign o_set2_PC             = i_set2_PC            ;
    assign o_set2_o_inst_lawful  = i_set2_o_inst_lawful ;
    assign o_set2_inst_type      = i_set2_inst_type     ;
    assign o_set2_br_type        = i_set2_br_type       ;
    assign o_set2_imm            = i_set2_imm           ;
    assign o_set2_rf_rd          = i_set2_rf_rd         ;
    assign o_set2_rf_we          = i_set2_rf_we         ;
    assign o_set2_alu_src1_sel   = i_set2_alu_src1_sel  ;
    assign o_set2_alu_src2_sel   = i_set2_alu_src2_sel  ;
    assign o_set2_alu_op         = i_set2_alu_op        ;
    assign o_set2_mem_we         = i_set2_mem_we        ;
    assign o_set2_ldst_type      = i_set2_ldst_type     ;
    assign o_set2_mux_sel        = i_set2_mux_sel       ;
    assign o_set2_rf_raddr1      = i_set2_rf_raddr1     ;
    assign o_set2_rf_raddr2      = i_set2_rf_raddr2     ;
    assign o_set2_rf_rdata1      = i_set2_rf_rdata1     ;
    assign o_set2_rf_rdata2      = i_set2_rf_rdata2     ;
    assign o_set2_sign_bit       = i_set2_sign_bit      ;
    assign o_set2_type_predict   = i_set2_type_predict  ;
    assign o_set2_PC_pre         = i_set2_PC_pre        ;
    assign o_set2_csr_type       = i_set2_csr_type      ;
    assign o_set2_csr_raddr      = i_set2_csr_raddr     ;
    assign o_set2_ecode_in       = i_set2_ecode_in      ;
    assign o_set2_ecode_we       = i_set2_ecode_we      ;
    assign o_set2_code_for_cacop = i_set2_code_for_cacop;

    // 对于处在前面A位置，但是在B位置发射的指令，dispatch位置不变，在Issue_EXE根据选择信号抉择
    always @(*) begin
        case (is_valid)
            2'b00: begin
                o_set1_o_valid = 1'b0;
                o_set2_o_valid = 1'b0;
                o_usingNUM = 2'b00;
            end
            2'b10: begin
                if( !lock_in_1) begin
                    o_set1_o_valid = 1'b1;
                    o_set2_o_valid = 1'b0;
                    o_usingNUM = 2'd1;
                end
                else begin
                    o_set1_o_valid = 1'b0;
                    o_set2_o_valid = 1'b0;
                    o_usingNUM = 2'b00;
                end
            end
            2'b01: begin
                o_set1_o_valid = 1'b0;
                o_set2_o_valid = 1'b0;
                o_usingNUM = 2'b00;
            end
            2'b11: begin
                // 两个合法，开始检测
                
                if( lock_in_1 ) begin
                    o_set1_o_valid = 1'b0;
                    o_set2_o_valid = 1'b0;
                    o_usingNUM = 2'b00;
                end
                else begin
                    if( lock_in_2 ) begin
                        o_set1_o_valid = 1'b1;
                        o_set2_o_valid = 1'b0;
                        o_usingNUM = 2'd1;
                    end
                    else begin
                        // 都没有互锁现象
                        if(LDSW_Mul_Div_csr_rdcnt_cacop_plus_any) begin
                            // 第一个指令只能发射在B位置
                            o_set1_o_valid = 1'b1;
                            o_set2_o_valid = 1'b0;
                            o_usingNUM = 2'd1;
                        end
                        else if(double_BR | signle_cacop | RAW_exist | BR_exception_plus_LDST_cacop_prob) begin
                            o_set1_o_valid = 1'b1;
                            o_set2_o_valid = 1'b0;
                            o_usingNUM = 2'd1;
                        end
                        // TODO: 也许可以合并
                        else begin
                            o_set1_o_valid = 1'b1;
                            o_set2_o_valid = 1'b1;
                            o_usingNUM = 2'd2;
                        end
                    end
                end
            end
        endcase
    end
    // assign ld_exist = (LDSW_Mul_Div_plus_any & (o_usingNUM != 2'b00)) | (any_plus_LDSW & (o_usingNUM == 2'd2)) | ((is_valid == 2'b10) & (o_usingNUM != 2'b00) & ~o_set1_ldst_type[3]);
    assign ld_exist[1] = (o_usingNUM != 2'd0) & ~o_set1_ldst_type[3];
    assign ld_exist[0] = (o_usingNUM == 2'd2) & ~o_set2_ldst_type[3];
    assign rdcnt_exist[1] = (o_usingNUM != 2'd0) & o_set1_inst_type[6];
    assign rdcnt_exist[0] = (o_usingNUM == 2'd2) & o_set2_inst_type[6];
    assign mul_div_exist[1] = (o_usingNUM != 2'd0) & (o_set1_inst_type[2] | o_set1_inst_type[3]);
    assign mul_div_exist[0] = (o_usingNUM == 2'd2) & (o_set2_inst_type[2] | o_set2_inst_type[3]);
    
    // &is_valid <==> is_valid == 2'b11 


    assign double_BR     = (&is_valid) ? ( ~((i_set1_br_type[0])) && ~((i_set2_br_type[0]))) : 0; // 同时为BR，两个都不是全0
    assign signle_cacop  = (&is_valid) ? (i_set2_inst_type == 10'h080) : 0; // B是cacop
    assign LDSW_Mul_Div_csr_rdcnt_cacop_plus_any = (&is_valid) ? (i_set1_inst_type != 10'h001) : 0; // 前LDSW，Div， Mul，3csr, ertn, cacop后任意
    

    assign RAW_exist     = (&is_valid  && i_set1_rf_rd != 0) ? ( (i_set1_rf_rd == i_set2_rf_raddr1) || (i_set1_rf_rd == i_set2_rf_raddr2) ) : 0; // 前rd=后rf,且rd = 0
    assign BR_exception_plus_LDST_cacop_prob  = (&is_valid) ? ((i_set2_mem_we | i_set2_inst_type == 10'h080) & ((~i_set1_br_type[0]) | i_set1_ecode_we)) : 0; // 前BR、例外后LDSW


    assign lock_in_1     = (is_valid[1] & last_ld) ? (rf_waddr == i_set1_rf_raddr1) || (rf_waddr == i_set1_rf_raddr2) : 0; // LW和RDCNT与A指令互锁
    assign lock_in_2     = (is_valid[0] & last_ld) ? (rf_waddr == i_set2_rf_raddr1) || (rf_waddr == i_set2_rf_raddr2) : 0; // LW和RDCNT与B指令互锁


    always @(posedge clk) begin
        if(flush) begin
            last_ld <= 1'b0;
            rf_waddr <= 5'd0;
        end
        else if( stall ) begin
            last_ld <= last_ld;
            rf_waddr <= rf_waddr;
        end
        else begin
            last_ld <= (|ld_exist) | (|rdcnt_exist) | (|mul_div_exist);
            rf_waddr <= (ld_exist[1] | rdcnt_exist[1] | mul_div_exist[1]) ? i_set1_rf_rd : i_set2_rf_rd;
        end
    end



endmodule

