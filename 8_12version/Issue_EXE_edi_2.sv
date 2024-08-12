`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 22:43:29
// Design Name: 
// Module Name: Issue_EXE_edi_2
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


module Issue_EXE_edi_2(
    input [ 0: 0] clk,
    input [ 0: 0] rstn,


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

    input [31: 0] rdata_a1,
    input [31: 0] rdata_a2,
    input [31: 0] rdata_b1,
    input [31: 0] rdata_b2,

    input [31: 0] csr_rdata_1,
    input [31: 0] csr_rdata_2,
    input [31: 0] csr_tid,

    // stall&flush
    input [ 0: 0] flush_BR,
    input [ 0: 0] stall_DCache,
    input [ 0: 0] stall_EX,

    output logic [ 0: 0] EX_a_enable,        //A指令是否有效
    output logic [ 0: 0] EX_b_enable,        //B指令是否有效

    output logic [ 1: 0] type_predict_a,     //A指令的类型预测
    output logic [ 1: 0] type_predict_b,     //B指令的类型预测
    output logic [31: 0] EX_PC_pre_a,        //A指令的预测PC
    output logic [31: 0] EX_PC_pre_b,        //B指令的预测PC

    output logic [31: 0] EX_pc_a,            //A指令的PC值
    output logic [31: 0] EX_pc_b,            //B指令的PC值
    output logic [ 4: 0] EX_rf_raddr_a1,     //A指令的第一个寄存器地址
    output logic [ 4: 0] EX_rf_raddr_a2,     //A指令的第二个寄存器地址
    output logic [ 4: 0] EX_rf_raddr_b1,     //B指令的第一个寄存器地址
    output logic [ 4: 0] EX_rf_raddr_b2,     //B指令的第二个寄存器地址
    output logic [31: 0] EX_rf_rdata_a1,     //A指令的第一个寄存器的值
    output logic [31: 0] EX_rf_rdata_a2,     //A指令的第二个寄存器的值
    output logic [31: 0] EX_rf_rdata_b1,     //B指令的第一个寄存器的值
    output logic [31: 0] EX_rf_rdata_b2,     //B指令的第二个寄存器的值
    output logic [31: 0] EX_imm_a,           //A指令的立即数
    output logic [31: 0] EX_imm_b,           //B指令的立即数

    output logic [ 3: 0] EX_alu_src_sel_a1,  //A指令的第一个操作数选择信号
    output logic [ 3: 0] EX_alu_src_sel_a2,  //A指令的第二个操作数选择信号
    output logic [ 3: 0] EX_alu_src_sel_b1,  //B指令的第一个操作数选择信号
    output logic [ 3: 0] EX_alu_src_sel_b2,  //B指令的第二个操作数选择信号
    output logic [11: 0] EX_alu_op_a,        //A指令的运算类型
    output logic [11: 0] EX_alu_op_b,        //B指令的运算类型

    output logic [ 9: 0] EX_br_type_a,       //A指令的分支类型
    output logic [ 9: 0] EX_br_type_b,       //B指令的分支类型
    output logic [ 0: 0] EX_br_pd_a,         //predict A指令的分支预测，1预测跳转，0预测不跳转
    output logic [ 0: 0] EX_br_pd_b,         //predict B指令的分支预测，1预测跳转，0预测不跳转

    output logic [ 0: 0] EX_rf_we_a,         //A指令寄存器写使能
    output logic [ 0: 0] EX_rf_we_b,         //B指令寄存器写使能
    output logic [ 4: 0] EX_rf_waddr_a,      //A指令寄存器写地址
    output logic [ 4: 0] EX_rf_waddr_b,      //B指令寄存器写地址

    output logic [ 0: 0]  EX_mem_we_a,        //A指令内存写使能
    output logic [ 0: 0]  EX_mem_we_b,        //B指令内存写使能
    output logic [ 8: 0]  EX_mux_sel,         //B指令WB来源选择信号
    output logic [ 2: 0]  EX_mem_type_a,      //A指令内存访问类型
    output logic [ 2: 0]  EX_mem_type_b,      //B指令内存访问类型
    
    output logic [ 0: 0] EX_sign_bit,        //符号位,运用于乘除法 // 1为有符号数
    output logic [ 0: 0] EX_div_en,          //除法使能
    output logic [ 0: 0] EX_mul_en,          //除法使能

    // CSR
    output logic [ 2: 0] csr_type,           //csr指令的类型
    output logic [13: 0] csr_raddr,          //csr指令的读csr地址
    output logic [31: 0] csr_rdata,          //csr指令的读csr数据
    output logic [31: 0] EX_tid,             //tid,计时器编号
    output logic [ 6: 0] ecode_in_a,         //异常处理的输入
    output logic [ 0: 0] ecode_we_a,         //异常处理的写曾经，表示已经修改过ecode_in
    output logic [ 6: 0] ecode_in_b,         //异常处理的输入
    output logic [ 0: 0] ecode_we_b,         //异常处理的写曾经，表示已经修改过ecode_in
    output logic [ 0: 0] ertn_check,         //ertn检查

    output logic [ 4: 0] code_for_cacop,     //cacop指令的code
    output logic [ 0: 0] cacop_en            //cacop指令的使能

    `ifdef DIFFTEST_EN
    , 
    
    output logic [31: 0] EX_a_inst,
    output logic [31: 0] EX_b_inst
    `endif  
    );

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;
    assign flush = flush_BR;
    assign stall = stall_DCache | stall_EX;

    logic [ 0: 0] Issue_a_enable;
    logic [ 0: 0] Issue_b_enable;
    assign Issue_a_enable = ~flush & i_set1_o_valid;
    assign Issue_b_enable = ~flush & i_set2_o_valid;

    always @(posedge clk) begin
        if( !rstn ) begin
            EX_a_enable <= 1'b0;
            EX_b_enable <= 1'b0;
        end
        else if(stall) begin
            EX_a_enable <= EX_a_enable;
            EX_b_enable <= EX_b_enable;
        end
        else begin
            if(i_set1_inst_type != 10'h001) begin
                EX_a_enable <= Issue_b_enable;
                EX_b_enable <= Issue_a_enable;
            end
            else begin
                EX_a_enable <= Issue_a_enable;
                EX_b_enable <= Issue_b_enable;
            end
        end
    end
    

    always @(posedge clk) begin
        if( !rstn | flush) begin
            EX_pc_a           <= 32'h0000_0000;
            EX_pc_b           <= 32'h0000_0000;
            EX_rf_raddr_a1    <= 5'h00;
            EX_rf_raddr_a2    <= 5'h00;
            EX_rf_raddr_b1    <= 5'h00;
            EX_rf_raddr_b2    <= 5'h00;
            EX_rf_rdata_a1    <= 32'h0000_0000;
            EX_rf_rdata_a2    <= 32'h0000_0000;
            EX_rf_rdata_b1    <= 32'h0000_0000;
            EX_rf_rdata_b2    <= 32'h0000_0000;
            EX_imm_a          <= 32'h0000_0000;
            EX_imm_b          <= 32'h0000_0000;
            EX_alu_src_sel_a1 <= 3'h0;
            EX_alu_src_sel_a2 <= 3'h0;
            EX_alu_src_sel_b1 <= 3'h0;
            EX_alu_src_sel_b2 <= 3'h0;
            EX_alu_op_a       <= 12'h000;
            EX_alu_op_b       <= 12'h000;
            EX_br_type_a      <= 10'h001;
            EX_br_type_b      <= 10'h001;
            EX_br_pd_a        <= 1'b0;
            EX_br_pd_b        <= 1'b0;
            EX_rf_we_a        <= 1'b0;
            EX_rf_we_b        <= 1'b0;
            EX_mem_type_a     <= 3'h0;
            EX_mem_type_b     <= 3'h0;
            EX_mux_sel        <= 9'h000;
            EX_rf_waddr_a     <= 5'h00;
            EX_rf_waddr_b     <= 5'h00;
            EX_mem_we_a       <= 1'b0;
            EX_mem_we_b       <= 1'b0;
            EX_div_en         <= 1'b0;
            EX_mul_en         <= 1'b0;
            EX_sign_bit       <= 1'b0;
            type_predict_a    <= 2'h0;
            type_predict_b    <= 2'h0;
            EX_PC_pre_a       <= 32'h0000_0004;
            EX_PC_pre_b       <= 32'h0000_0004;
            csr_type          <= 3'h0;
            csr_raddr         <= 14'h0000;
            csr_rdata         <= 32'h0000_0000;
            ertn_check        <= 1'b0;
            ecode_in_a        <= 7'h00;
            ecode_we_a        <= 1'b0;
            ecode_in_b        <= 7'h00;
            ecode_we_b        <= 1'b0;
            EX_tid            <= 32'h0000_0000;
            code_for_cacop    <= 5'h00;
            cacop_en          <= 1'b0;
            `ifdef DIFFTEST_EN
            EX_a_inst         <= 32'h0000_0000;
            EX_b_inst         <= 32'h0000_0000;
            `endif
        end
        else if(stall) begin
            EX_pc_a           <= EX_pc_a;
            EX_pc_b           <= EX_pc_b;
            EX_rf_raddr_a1    <= EX_rf_raddr_a1;
            EX_rf_raddr_a2    <= EX_rf_raddr_a2;
            EX_rf_raddr_b1    <= EX_rf_raddr_b1;
            EX_rf_raddr_b2    <= EX_rf_raddr_b2;
            EX_rf_rdata_a1    <= EX_rf_rdata_a1;
            EX_rf_rdata_a2    <= EX_rf_rdata_a2;
            EX_rf_rdata_b1    <= EX_rf_rdata_b1;
            EX_rf_rdata_b2    <= EX_rf_rdata_b2;
            EX_imm_a          <= EX_imm_a;
            EX_imm_b          <= EX_imm_b;
            EX_alu_src_sel_a1 <= EX_alu_src_sel_a1;
            EX_alu_src_sel_a2 <= EX_alu_src_sel_a2;
            EX_alu_src_sel_b1 <= EX_alu_src_sel_b1;
            EX_alu_src_sel_b2 <= EX_alu_src_sel_b2;
            EX_alu_op_a       <= EX_alu_op_a;
            EX_alu_op_b       <= EX_alu_op_b;
            EX_br_type_a      <= EX_br_type_a;
            EX_br_type_b      <= EX_br_type_b;
            EX_br_pd_a        <= EX_br_pd_a;
            EX_br_pd_b        <= EX_br_pd_b;
            EX_rf_we_a        <= EX_rf_we_a;
            EX_rf_we_b        <= EX_rf_we_b;
            EX_mux_sel        <= EX_mux_sel;
            EX_mem_type_a     <= EX_mem_type_a;
            EX_mem_type_b     <= EX_mem_type_b;
            EX_rf_waddr_a     <= EX_rf_waddr_a;
            EX_rf_waddr_b     <= EX_rf_waddr_b;
            EX_mem_we_a       <= EX_mem_we_a;
            EX_mem_we_b       <= EX_mem_we_b;
            EX_div_en         <= EX_div_en;
            EX_mul_en         <= EX_mul_en;
            EX_sign_bit       <= EX_sign_bit;
            type_predict_a    <= type_predict_a;
            type_predict_b    <= type_predict_b;
            EX_PC_pre_a       <= EX_PC_pre_a;
            EX_PC_pre_b       <= EX_PC_pre_b;
            csr_type          <= csr_type;
            csr_raddr         <= csr_raddr;
            csr_rdata         <= csr_rdata;
            ertn_check        <= ertn_check;
            ecode_in_a        <= ecode_in_a;
            ecode_we_a        <= ecode_we_a;
            ecode_in_b        <= ecode_in_b;
            ecode_we_b        <= ecode_we_b;
            EX_tid            <= EX_tid;
            code_for_cacop    <= code_for_cacop;
            cacop_en          <= cacop_en;
            `ifdef DIFFTEST_EN
            EX_a_inst         <= EX_a_inst;
            EX_b_inst         <= EX_b_inst;
            `endif
        end
        else begin
            if( i_set1_inst_type != 10'h001 ) begin
                EX_pc_a           <= 32'h0000_0000;
                EX_pc_b           <= i_set1_PC;
                EX_rf_raddr_a1    <= i_set2_rf_raddr1;
                EX_rf_raddr_a2    <= i_set2_rf_raddr2;
                EX_rf_raddr_b1    <= i_set1_rf_raddr1;
                EX_rf_raddr_b2    <= i_set1_rf_raddr2;
                EX_rf_rdata_a1    <= rdata_b1;
                EX_rf_rdata_a2    <= rdata_b2;
                EX_rf_rdata_b1    <= rdata_a1;
                EX_rf_rdata_b2    <= rdata_a2;
                EX_imm_a          <= i_set2_imm;
                EX_imm_b          <= i_set1_imm;
                EX_alu_src_sel_a1 <= i_set2_alu_src1_sel;
                EX_alu_src_sel_a2 <= i_set2_alu_src2_sel;
                EX_alu_src_sel_b1 <= i_set1_alu_src1_sel;
                EX_alu_src_sel_b2 <= i_set1_alu_src2_sel;
                EX_alu_op_a       <= i_set2_alu_op;
                EX_alu_op_b       <= i_set1_alu_op;
                EX_br_type_a      <= (Issue_b_enable) ? i_set2_br_type : 10'h001;
                EX_br_type_b      <= (Issue_a_enable) ? i_set1_br_type : 10'h001;
                EX_br_pd_a        <= ~(i_set2_PC_pre == i_set2_PC + 4);
                EX_br_pd_b        <= ~(i_set1_PC_pre == i_set1_PC + 4);
                EX_rf_we_a        <= i_set2_rf_we & Issue_b_enable;
                EX_rf_we_b        <= i_set1_rf_we & Issue_a_enable;
                EX_mux_sel        <= i_set1_mux_sel & {9{Issue_a_enable}};
                EX_mem_type_a     <= i_set2_ldst_type[ 2: 0] & {3{Issue_b_enable}};
                EX_mem_type_b     <= i_set1_ldst_type[ 2: 0] & {3{Issue_a_enable}};
                EX_rf_waddr_a     <= i_set2_rf_rd;
                EX_rf_waddr_b     <= i_set1_rf_rd;
                EX_mem_we_a       <= i_set2_mem_we & Issue_b_enable;
                EX_mem_we_b       <= i_set1_mem_we & Issue_a_enable;
                EX_sign_bit       <= i_set1_sign_bit;
                EX_div_en         <= (i_set1_inst_type == 10'h008) & Issue_a_enable;
                EX_mul_en         <= (i_set1_inst_type == 10'h004) & Issue_a_enable;
                type_predict_a    <= i_set2_type_predict;
                type_predict_b    <= i_set1_type_predict;
                EX_PC_pre_a       <= 32'h0000_0004;
                EX_PC_pre_b       <= (Issue_a_enable) ? i_set1_PC_pre : i_set1_PC + 4;
                csr_type          <= i_set1_csr_type & {3{Issue_a_enable}};
                csr_raddr         <= i_set1_csr_raddr;
                csr_rdata         <= csr_rdata_1;
                ertn_check        <= (i_set1_inst_type == 10'h020) & Issue_a_enable;
                ecode_in_a        <= i_set2_ecode_in & {7{Issue_b_enable}};
                ecode_we_a        <= i_set2_ecode_we & Issue_b_enable;
                ecode_in_b        <= i_set1_ecode_in & {7{Issue_a_enable}};
                ecode_we_b        <= i_set1_ecode_we & Issue_a_enable;
                EX_tid            <= csr_tid;
                code_for_cacop    <= i_set1_code_for_cacop;
                cacop_en          <= (i_set1_inst_type == 10'h080) & Issue_a_enable;
                `ifdef DIFFTEST_EN
                EX_a_inst         <= i_set2_instruction;
                EX_b_inst         <= i_set1_instruction;
                `endif
            end
            else begin
                EX_pc_a           <= i_set1_PC;
                EX_pc_b           <= i_set2_PC;
                EX_rf_raddr_a1    <= i_set1_rf_raddr1;
                EX_rf_raddr_a2    <= i_set1_rf_raddr2;
                EX_rf_raddr_b1    <= i_set2_rf_raddr1;
                EX_rf_raddr_b2    <= i_set2_rf_raddr2;
                EX_rf_rdata_a1    <= rdata_a1;
                EX_rf_rdata_a2    <= rdata_a2;
                EX_rf_rdata_b1    <= rdata_b1;
                EX_rf_rdata_b2    <= rdata_b2;
                EX_imm_a          <= i_set1_imm;
                EX_imm_b          <= i_set2_imm;
                EX_alu_src_sel_a1 <= i_set1_alu_src1_sel;
                EX_alu_src_sel_a2 <= i_set1_alu_src2_sel;
                EX_alu_src_sel_b1 <= i_set2_alu_src1_sel;
                EX_alu_src_sel_b2 <= i_set2_alu_src2_sel;
                EX_alu_op_a       <= i_set1_alu_op;
                EX_alu_op_b       <= i_set2_alu_op;
                EX_br_type_a      <= (Issue_a_enable) ? i_set1_br_type : 10'h001;
                EX_br_type_b      <= (Issue_b_enable) ? i_set2_br_type : 10'h001;
                EX_br_pd_a        <= ~(i_set1_PC_pre == i_set1_PC + 4);
                EX_br_pd_b        <= ~(i_set2_PC_pre == i_set2_PC + 4);
                // TODO: 预测跳转
                EX_rf_we_a        <= i_set1_rf_we & Issue_a_enable;
                EX_rf_we_b        <= i_set2_rf_we & Issue_b_enable;
                EX_mux_sel        <= i_set2_mux_sel & {9{Issue_b_enable}};
                EX_mem_type_a     <= i_set1_ldst_type[ 2: 0] & {3{Issue_a_enable}};
                EX_mem_type_b     <= i_set2_ldst_type[ 2: 0] & {3{Issue_b_enable}};
                EX_rf_waddr_a     <= i_set1_rf_rd;
                EX_rf_waddr_b     <= i_set2_rf_rd;
                EX_mem_we_a       <= i_set1_mem_we & Issue_a_enable;
                EX_mem_we_b       <= i_set2_mem_we & Issue_b_enable;
                EX_sign_bit       <= i_set2_sign_bit;
                EX_div_en         <= (i_set2_inst_type == 10'h008) & Issue_b_enable;
                EX_mul_en         <= (i_set2_inst_type == 10'h004) & Issue_b_enable;
                type_predict_a    <= i_set1_type_predict;
                type_predict_b    <= i_set2_type_predict;
                EX_PC_pre_a       <= (Issue_a_enable) ? i_set1_PC_pre : i_set1_PC + 4;
                EX_PC_pre_b       <= (Issue_b_enable) ? i_set2_PC_pre : i_set2_PC + 4;
                csr_type          <= i_set2_csr_type & {3{Issue_b_enable}};
                csr_raddr         <= i_set2_csr_raddr;
                csr_rdata         <= csr_rdata_2;
                ertn_check        <= (i_set2_inst_type == 10'h020) & Issue_b_enable;
                ecode_in_a        <= i_set1_ecode_in & {7{Issue_a_enable}};
                ecode_we_a        <= i_set1_ecode_we & Issue_a_enable;
                ecode_in_b        <= i_set2_ecode_in & {7{Issue_b_enable}};
                ecode_we_b        <= i_set2_ecode_we & Issue_b_enable;
                EX_tid            <= csr_tid;
                code_for_cacop    <= i_set2_code_for_cacop;
                cacop_en          <= (i_set2_inst_type == 10'h080) & Issue_b_enable;
                `ifdef DIFFTEST_EN
                EX_a_inst         <= i_set1_instruction;
                EX_b_inst         <= i_set2_instruction;
                `endif
            end
        end
    end
endmodule