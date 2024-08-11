`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 22:18:09
// Design Name: 
// Module Name: ID_REG_edi_2
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



module ID_REG_edi_2(
    input [ 0: 0] clk,
    input [ 0: 0] rstn,

    input [31: 0] i_PC_set1_instruction   ,
    input [31: 0] i_PC_set1_PC            ,
    input [ 0: 0] i_PC_set1_o_inst_lawful ,
    input [ 0: 0] i_PC_set1_o_valid       ,
    input [ 9: 0] i_PC_set1_inst_type     ,
    input [ 9: 0] i_PC_set1_br_type       , 
    input [31: 0] i_PC_set1_imm           ,
    input [ 4: 0] i_PC_set1_rf_rd         ,
    input [ 0: 0] i_PC_set1_rf_we         ,
    input [ 3: 0] i_PC_set1_alu_src1_sel  ,
    input [ 3: 0] i_PC_set1_alu_src2_sel  ,
    input [11: 0] i_PC_set1_alu_op        ,
    input [ 0: 0] i_PC_set1_mem_we        ,
    input [ 3: 0] i_PC_set1_ldst_type     ,
    input [ 8: 0] i_PC_set1_mux_sel       , // B通道WB来源的选择信号
    input [ 4: 0] i_PC_set1_rf_raddr1     ,
    input [ 4: 0] i_PC_set1_rf_raddr2     ,
    input [31: 0] i_PC_set1_rf_rdata1     ,
    input [31: 0] i_PC_set1_rf_rdata2     ,
    input [ 0: 0] i_PC_set1_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    input [ 1: 0] i_PC_set1_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    input [31: 0] i_PC_set1_PC_pre        , // 用于预测分支时得到的PC
    input [ 2: 0] i_PC_set1_csr_type      , // 用于csr指令的类型
    input [13: 0] i_PC_set1_csr_raddr     , // 用于csr指令的读csr地址
    input [ 6: 0] i_PC_set1_ecode_in      , // 用于异常处理的输入
    input [ 0: 0] i_PC_set1_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    input [ 4: 0] i_PC_set1_code_for_cacop, // 用于cacop指令的code

    input [31: 0] i_PC_set2_instruction   ,
    input [31: 0] i_PC_set2_PC            ,
    input [ 0: 0] i_PC_set2_o_inst_lawful ,
    input [ 0: 0] i_PC_set2_o_valid       ,
    input [ 9: 0] i_PC_set2_inst_type     ,
    input [ 9: 0] i_PC_set2_br_type       , 
    input [31: 0] i_PC_set2_imm           ,
    input [ 4: 0] i_PC_set2_rf_rd         ,
    input [ 0: 0] i_PC_set2_rf_we         ,
    input [ 3: 0] i_PC_set2_alu_src1_sel  ,
    input [ 3: 0] i_PC_set2_alu_src2_sel  ,
    input [11: 0] i_PC_set2_alu_op        ,
    input [ 0: 0] i_PC_set2_mem_we        ,
    input [ 3: 0] i_PC_set2_ldst_type     ,
    input [ 8: 0] i_PC_set2_mux_sel       , // B通道WB来源的选择信号
    input [ 4: 0] i_PC_set2_rf_raddr1     ,
    input [ 4: 0] i_PC_set2_rf_raddr2     ,
    input [31: 0] i_PC_set2_rf_rdata1     ,
    input [31: 0] i_PC_set2_rf_rdata2     ,
    input [ 0: 0] i_PC_set2_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    input [ 1: 0] i_PC_set2_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    input [31: 0] i_PC_set2_PC_pre        , // 用于预测分支时得到的PC
    input [ 2: 0] i_PC_set2_csr_type      , // 用于csr指令的类型
    input [13: 0] i_PC_set2_csr_raddr     , // 用于csr指令的读csr地址
    input [ 6: 0] i_PC_set2_ecode_in      , // 用于异常处理的输入
    input [ 0: 0] i_PC_set2_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    input [ 4: 0] i_PC_set2_code_for_cacop, // 用于cacop指令的code
    

    input [ 1: 0] i_usingNUM,

    // stall&flush
    input [ 0: 0] flush_BR,
    input [ 0: 0] stall_DCache,
    input [ 0: 0] stall_EX,

    output logic [31: 0] o_PC_set1_instruction   ,
    output logic [31: 0] o_PC_set1_PC            ,
    output logic [ 0: 0] o_PC_set1_o_inst_lawful ,
    output logic [ 0: 0] o_PC_set1_o_valid       ,
    output logic [ 9: 0] o_PC_set1_inst_type     ,
    output logic [ 9: 0] o_PC_set1_br_type       , 
    output logic [31: 0] o_PC_set1_imm           ,
    output logic [ 4: 0] o_PC_set1_rf_rd         ,
    output logic [ 0: 0] o_PC_set1_rf_we         ,
    output logic [ 3: 0] o_PC_set1_alu_src1_sel  ,
    output logic [ 3: 0] o_PC_set1_alu_src2_sel  ,
    output logic [11: 0] o_PC_set1_alu_op        ,
    output logic [ 0: 0] o_PC_set1_mem_we        ,
    output logic [ 3: 0] o_PC_set1_ldst_type     ,
    output logic [ 8: 0] o_PC_set1_mux_sel       , // B通道WB来源的选择信号
    output logic [ 4: 0] o_PC_set1_rf_raddr1     ,
    output logic [ 4: 0] o_PC_set1_rf_raddr2     ,
    output logic [31: 0] o_PC_set1_rf_rdata1     ,
    output logic [31: 0] o_PC_set1_rf_rdata2     ,
    output logic [ 0: 0] o_PC_set1_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    output logic [ 1: 0] o_PC_set1_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    output logic [31: 0] o_PC_set1_PC_pre        , // 用于预测分支时得到的PC
    output logic [ 2: 0] o_PC_set1_csr_type      , // 用于csr指令的类型
    output logic [13: 0] o_PC_set1_csr_raddr     , // 用于csr指令的读csr地址
    output logic [ 6: 0] o_PC_set1_ecode_in      , // 用于异常处理的输入
    output logic [ 0: 0] o_PC_set1_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    output logic [ 4: 0] o_PC_set1_code_for_cacop, // 用于cacop指令的code

    output logic [31: 0] o_PC_set2_instruction   ,
    output logic [31: 0] o_PC_set2_PC            ,
    output logic [ 0: 0] o_PC_set2_o_inst_lawful ,
    output logic [ 0: 0] o_PC_set2_o_valid       ,
    output logic [ 9: 0] o_PC_set2_inst_type     ,
    output logic [ 9: 0] o_PC_set2_br_type       , 
    output logic [31: 0] o_PC_set2_imm           ,
    output logic [ 4: 0] o_PC_set2_rf_rd         ,
    output logic [ 0: 0] o_PC_set2_rf_we         ,
    output logic [ 3: 0] o_PC_set2_alu_src1_sel  ,
    output logic [ 3: 0] o_PC_set2_alu_src2_sel  ,
    output logic [11: 0] o_PC_set2_alu_op        ,
    output logic [ 0: 0] o_PC_set2_mem_we        ,
    output logic [ 3: 0] o_PC_set2_ldst_type     ,
    output logic [ 8: 0] o_PC_set2_mux_sel       , // B通道WB来源的选择信号
    output logic [ 4: 0] o_PC_set2_rf_raddr1     ,
    output logic [ 4: 0] o_PC_set2_rf_raddr2     ,
    output logic [31: 0] o_PC_set2_rf_rdata1     ,
    output logic [31: 0] o_PC_set2_rf_rdata2     ,
    output logic [ 0: 0] o_PC_set2_sign_bit      , // 符号位,运用于乘除法 // 1为有符号数
    output logic [ 1: 0] o_PC_set2_type_predict  , // using for branch predict, to know the stardard, see the IF2_PreDecoder.sv
    output logic [31: 0] o_PC_set2_PC_pre        , // 用于预测分支时得到的PC
    output logic [ 2: 0] o_PC_set2_csr_type      , // 用于csr指令的类型
    output logic [13: 0] o_PC_set2_csr_raddr     , // 用于csr指令的读csr地址
    output logic [ 6: 0] o_PC_set2_ecode_in      , // 用于异常处理的输入
    output logic [ 0: 0] o_PC_set2_ecode_we      , // 用于异常处理的写曾经，表示已经修改过ecode_in
    output logic [ 4: 0] o_PC_set2_code_for_cacop, // 用于cacop指令的code

    output logic [ 4: 0] a_rf_raddr1,
    output logic [ 4: 0] a_rf_raddr2,
    output logic [ 4: 0] b_rf_raddr1,
    output logic [ 4: 0] b_rf_raddr2,
    output logic [13: 0] csr_raddr_1,
    output logic [13: 0] csr_raddr_2,

    output logic [ 1: 0] o_is_valid,
    output logic [ 0: 0] o_is_full
    );

    parameter NUM = 16;

    logic [ 1: 0] o_is_valid_temp;
    logic [ 1: 0] i_is_valid;
    assign i_is_valid = {i_PC_set1_o_valid, i_PC_set2_o_valid};

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;
    assign flush = flush_BR;
    assign stall = stall_DCache | stall_EX;

    typedef struct {
        logic [31:0] instruction;
        logic [31:0] PC;
        logic o_inst_lawful;
        logic o_valid;
        logic [9:0] inst_type;
        logic [9:0] br_type;
        logic [31:0] imm;
        logic [4:0] rf_rd;
        logic rf_we;
        logic [2:0] alu_src1_sel;
        logic [2:0] alu_src2_sel;
        logic [11:0] alu_op;
        logic mem_we;
        logic [3:0] ldst_type;
        logic [8:0] mux_sel;
        logic [4:0] rf_raddr1;
        logic [4:0] rf_raddr2;
        logic [31:0] rf_rdata1;
        logic [31:0] rf_rdata2;
        logic sign_bit;
        logic [1:0] type_predict;
        logic [31:0] PC_pre;
        logic [2:0] csr_type;
        logic [13:0] csr_raddr;
        logic [6:0] ecode_in;
        logic ecode_we;
        logic [4:0] code_for_cacop;
    } PC_set;

    PC_set PC_set_Buffer[NUM];

    logic [ 6: 0] length; // 缓存数组的长度+将要存入的数据的长度
    logic [ 6: 0] length_left; // 缓存数组的长度
    logic [ 1: 0] length_add; // 将要存入的数据的长度
    logic [ 6: 0] temp_length; // 临时长度,队头减队尾，有可能为负数

    logic [ 4: 0] head; // 指针,指示FIFO的队头，即下一个要写入的位置
    logic [ 4: 0] tail; // 指针,指示FIFO的队尾，即下一个要写取的位置
    logic [ 4: 0] next_head; // 下一个队头
    logic [ 4: 0] next_tail; // 下一个队尾
    logic [ 4: 0] head_plus_1; // 第1个装填位置
    logic [ 4: 0] head_plus_2; // 第2个装填位置
    logic [ 4: 0] tail_plus_1; // 第1个取用位置 
    logic [ 4: 0] tail_plus_2; // 第2个取用位置    

    assign temp_length = head - (tail + i_usingNUM);
    assign length_left = temp_length + ((temp_length[6] == 0) ? 0 : NUM);
    assign length_add  = (i_is_valid[1] ? (i_is_valid[0] ? 2 : 1) : 0 );
    assign length = length_left + length_add;

    assign next_head   = (head + length_add) - (((head + length_add) >= NUM ? NUM : 0));
    assign head_plus_1 = (head + 1) - ((head + 1 >= NUM ? NUM : 0));
    assign head_plus_2 = (head + 2) - ((head + 2 >= NUM ? NUM : 0));
    assign tail_plus_1 = (tail + 1) - ((tail + 1 >= NUM ? NUM : 0));
    assign tail_plus_2 = (tail + 2) - ((tail + 2 >= NUM ? NUM : 0));

    PC_set error_set;
    assign error_set.instruction = 32'd0;
    assign error_set.PC = 32'd0;
    assign error_set.o_inst_lawful = 1'b0;
    assign error_set.o_valid = 1'b0;
    assign error_set.inst_type = 10'd1;
    assign error_set.br_type = 10'd1;
    assign error_set.imm = 32'd0;
    assign error_set.rf_rd = 5'd0;
    assign error_set.rf_we = 1'b0;
    assign error_set.alu_src1_sel = 3'd0;
    assign error_set.alu_src2_sel = 3'd0;
    assign error_set.alu_op = 12'd0;
    assign error_set.mem_we = 1'b0;
    assign error_set.ldst_type = 4'd0;
    assign error_set.mux_sel = 9'b0;
    assign error_set.rf_raddr1 = 5'd0;
    assign error_set.rf_raddr2 = 5'd0;
    assign error_set.rf_rdata1 = 32'd0;
    assign error_set.rf_rdata2 = 32'd0;
    assign error_set.sign_bit = 1'b0;
    assign error_set.type_predict = 2'd0;
    assign error_set.PC_pre = 32'd0;
    assign error_set.csr_type = 3'd0;
    assign error_set.csr_raddr = 14'd0;
    assign error_set.ecode_in = 7'd0;
    assign error_set.ecode_we = 1'b0;
    assign error_set.code_for_cacop = 5'd0;

    always @(posedge clk) begin
        if( !rstn ) begin
            PC_set_Buffer[ 0] <= error_set;
            PC_set_Buffer[ 1] <= error_set;
            PC_set_Buffer[ 2] <= error_set;
            PC_set_Buffer[ 3] <= error_set;
            PC_set_Buffer[ 4] <= error_set;
            PC_set_Buffer[ 5] <= error_set;
            PC_set_Buffer[ 6] <= error_set;
            PC_set_Buffer[ 7] <= error_set;
            PC_set_Buffer[ 8] <= error_set;
            PC_set_Buffer[ 9] <= error_set;
            PC_set_Buffer[10] <= error_set;
            PC_set_Buffer[11] <= error_set;
            PC_set_Buffer[12] <= error_set;
            PC_set_Buffer[13] <= error_set;
            PC_set_Buffer[14] <= error_set;
            PC_set_Buffer[15] <= error_set;
        end
        else begin 
            case (length_add)
                2'd1: begin
                    PC_set_Buffer[head].instruction <= i_PC_set1_instruction;
                    PC_set_Buffer[head].PC <= i_PC_set1_PC;
                    PC_set_Buffer[head].o_inst_lawful <= i_PC_set1_o_inst_lawful;
                    PC_set_Buffer[head].o_valid <= i_PC_set1_o_valid;
                    PC_set_Buffer[head].inst_type <= i_PC_set1_inst_type;
                    PC_set_Buffer[head].br_type <= i_PC_set1_br_type;
                    PC_set_Buffer[head].imm <= i_PC_set1_imm;
                    PC_set_Buffer[head].rf_rd <= i_PC_set1_rf_rd;
                    PC_set_Buffer[head].rf_we <= i_PC_set1_rf_we;
                    PC_set_Buffer[head].alu_src1_sel <= i_PC_set1_alu_src1_sel;
                    PC_set_Buffer[head].alu_src2_sel <= i_PC_set1_alu_src2_sel;
                    PC_set_Buffer[head].alu_op <= i_PC_set1_alu_op;
                    PC_set_Buffer[head].mem_we <= i_PC_set1_mem_we;
                    PC_set_Buffer[head].ldst_type <= i_PC_set1_ldst_type;
                    PC_set_Buffer[head].mux_sel <= i_PC_set1_mux_sel;
                    PC_set_Buffer[head].rf_raddr1 <= i_PC_set1_rf_raddr1;
                    PC_set_Buffer[head].rf_raddr2 <= i_PC_set1_rf_raddr2;
                    PC_set_Buffer[head].rf_rdata1 <= i_PC_set1_rf_rdata1;
                    PC_set_Buffer[head].rf_rdata2 <= i_PC_set1_rf_rdata2;
                    PC_set_Buffer[head].sign_bit <= i_PC_set1_sign_bit;
                    PC_set_Buffer[head].type_predict <= i_PC_set1_type_predict;
                    PC_set_Buffer[head].PC_pre <= i_PC_set1_PC_pre;
                    PC_set_Buffer[head].csr_type <= i_PC_set1_csr_type;
                    PC_set_Buffer[head].csr_raddr <= i_PC_set1_csr_raddr;
                    PC_set_Buffer[head].ecode_in <= i_PC_set1_ecode_in;
                    PC_set_Buffer[head].ecode_we <= i_PC_set1_ecode_we;
                    PC_set_Buffer[head].code_for_cacop <= i_PC_set1_code_for_cacop;
                end
                2'd2: begin
                    PC_set_Buffer[head].instruction <= i_PC_set1_instruction;
                    PC_set_Buffer[head].PC <= i_PC_set1_PC;
                    PC_set_Buffer[head].o_inst_lawful <= i_PC_set1_o_inst_lawful;
                    PC_set_Buffer[head].o_valid <= i_PC_set1_o_valid;
                    PC_set_Buffer[head].inst_type <= i_PC_set1_inst_type;
                    PC_set_Buffer[head].br_type <= i_PC_set1_br_type;
                    PC_set_Buffer[head].imm <= i_PC_set1_imm;
                    PC_set_Buffer[head].rf_rd <= i_PC_set1_rf_rd;
                    PC_set_Buffer[head].rf_we <= i_PC_set1_rf_we;
                    PC_set_Buffer[head].alu_src1_sel <= i_PC_set1_alu_src1_sel;
                    PC_set_Buffer[head].alu_src2_sel <= i_PC_set1_alu_src2_sel;
                    PC_set_Buffer[head].alu_op <= i_PC_set1_alu_op;
                    PC_set_Buffer[head].mem_we <= i_PC_set1_mem_we;
                    PC_set_Buffer[head].ldst_type <= i_PC_set1_ldst_type;
                    PC_set_Buffer[head].mux_sel <= i_PC_set1_mux_sel;
                    PC_set_Buffer[head].rf_raddr1 <= i_PC_set1_rf_raddr1;
                    PC_set_Buffer[head].rf_raddr2 <= i_PC_set1_rf_raddr2;
                    PC_set_Buffer[head].rf_rdata1 <= i_PC_set1_rf_rdata1;
                    PC_set_Buffer[head].rf_rdata2 <= i_PC_set1_rf_rdata2;
                    PC_set_Buffer[head].sign_bit <= i_PC_set1_sign_bit;
                    PC_set_Buffer[head].type_predict <= i_PC_set1_type_predict;
                    PC_set_Buffer[head].PC_pre <= i_PC_set1_PC_pre;
                    PC_set_Buffer[head].csr_type <= i_PC_set1_csr_type;
                    PC_set_Buffer[head].csr_raddr <= i_PC_set1_csr_raddr;
                    PC_set_Buffer[head].ecode_in <= i_PC_set1_ecode_in;
                    PC_set_Buffer[head].ecode_we <= i_PC_set1_ecode_we;
                    PC_set_Buffer[head].code_for_cacop <= i_PC_set1_code_for_cacop;


                    PC_set_Buffer[head_plus_1].instruction <= i_PC_set2_instruction;
                    PC_set_Buffer[head_plus_1].PC <= i_PC_set2_PC;
                    PC_set_Buffer[head_plus_1].o_inst_lawful <= i_PC_set2_o_inst_lawful;
                    PC_set_Buffer[head_plus_1].o_valid <= i_PC_set2_o_valid;
                    PC_set_Buffer[head_plus_1].inst_type <= i_PC_set2_inst_type;
                    PC_set_Buffer[head_plus_1].br_type <= i_PC_set2_br_type;
                    PC_set_Buffer[head_plus_1].imm <= i_PC_set2_imm;
                    PC_set_Buffer[head_plus_1].rf_rd <= i_PC_set2_rf_rd;
                    PC_set_Buffer[head_plus_1].rf_we <= i_PC_set2_rf_we;
                    PC_set_Buffer[head_plus_1].alu_src1_sel <= i_PC_set2_alu_src1_sel;
                    PC_set_Buffer[head_plus_1].alu_src2_sel <= i_PC_set2_alu_src2_sel;
                    PC_set_Buffer[head_plus_1].alu_op <= i_PC_set2_alu_op;
                    PC_set_Buffer[head_plus_1].mem_we <= i_PC_set2_mem_we;
                    PC_set_Buffer[head_plus_1].ldst_type <= i_PC_set2_ldst_type;
                    PC_set_Buffer[head_plus_1].mux_sel <= i_PC_set2_mux_sel;
                    PC_set_Buffer[head_plus_1].rf_raddr1 <= i_PC_set2_rf_raddr1;
                    PC_set_Buffer[head_plus_1].rf_raddr2 <= i_PC_set2_rf_raddr2;
                    PC_set_Buffer[head_plus_1].rf_rdata1 <= i_PC_set2_rf_rdata1;
                    PC_set_Buffer[head_plus_1].rf_rdata2 <= i_PC_set2_rf_rdata2;
                    PC_set_Buffer[head_plus_1].sign_bit <= i_PC_set2_sign_bit;
                    PC_set_Buffer[head_plus_1].type_predict <= i_PC_set2_type_predict;
                    PC_set_Buffer[head_plus_1].PC_pre <= i_PC_set2_PC_pre;
                    PC_set_Buffer[head_plus_1].csr_type <= i_PC_set2_csr_type;
                    PC_set_Buffer[head_plus_1].csr_raddr <= i_PC_set2_csr_raddr;
                    PC_set_Buffer[head_plus_1].ecode_in <= i_PC_set2_ecode_in;
                    PC_set_Buffer[head_plus_1].ecode_we <= i_PC_set2_ecode_we;
                    PC_set_Buffer[head_plus_1].code_for_cacop <= i_PC_set2_code_for_cacop;
                end
                default: begin
                    
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if( !rstn ) begin
            head <= 5'b0;
            tail <= 5'b0;
        end
        else if(flush) begin
            tail <= 0;
            head <= 0;
        end
        else if(stall) begin
            tail <= tail;
            head <= next_head;
        end
        else begin
            tail <= ( |i_usingNUM ) ? (i_usingNUM[0]) ? tail_plus_1 : tail_plus_2 : tail;
            head <= next_head;
        end
    end

    // o_is_valid_temp 是否有效
    always @(posedge clk) begin
        if( !rstn ) begin
            o_is_valid_temp <= 2'b00;
        end
        else if(flush) begin
            o_is_valid_temp <= 2'b00;
        end
        // else if(stall) begin
        //     o_is_valid_temp <= 2'b00;
        //     // TODO: 修正,STALL信号后面的行为有待商榷，DCache Miss结束后的行为是什么
        // end
        else begin
            case (length)
                7'd0: begin
                    o_is_valid_temp <= 2'b00;
                end
                7'd1: begin
                    o_is_valid_temp <= 2'b10;
                end
                default: begin
                    o_is_valid_temp <= 2'b11;
                end
            endcase
        end
    end
    assign o_is_valid = o_is_valid_temp;

    // o_is_full 是否满
    always @(posedge clk) begin
        if( !rstn ) begin
            o_is_full <= 1'b0;
        end
        else if(length_left >= NUM - 8) begin
            o_is_full <= 1'b1;
        end
        else begin
            o_is_full <= 1'b0;
        end
    end

    // 输出固定使用tail的两个，同时根据长度制定o_is_valid_temp
    assign o_PC_set1_instruction = PC_set_Buffer[tail].instruction;
    assign o_PC_set1_PC = PC_set_Buffer[tail].PC;
    assign o_PC_set1_o_inst_lawful = PC_set_Buffer[tail].o_inst_lawful;
    assign o_PC_set1_o_valid = PC_set_Buffer[tail].o_valid;
    assign o_PC_set1_inst_type = PC_set_Buffer[tail].inst_type;
    assign o_PC_set1_br_type = PC_set_Buffer[tail].br_type;
    assign o_PC_set1_imm = PC_set_Buffer[tail].imm;
    assign o_PC_set1_rf_rd = PC_set_Buffer[tail].rf_rd;
    assign o_PC_set1_rf_we = PC_set_Buffer[tail].rf_we;
    assign o_PC_set1_alu_src1_sel = PC_set_Buffer[tail].alu_src1_sel;
    assign o_PC_set1_alu_src2_sel = PC_set_Buffer[tail].alu_src2_sel;
    assign o_PC_set1_alu_op = PC_set_Buffer[tail].alu_op;
    assign o_PC_set1_mem_we = PC_set_Buffer[tail].mem_we;
    assign o_PC_set1_ldst_type = PC_set_Buffer[tail].ldst_type;
    assign o_PC_set1_mux_sel = PC_set_Buffer[tail].mux_sel;
    assign o_PC_set1_rf_raddr1 = PC_set_Buffer[tail].rf_raddr1;
    assign o_PC_set1_rf_raddr2 = PC_set_Buffer[tail].rf_raddr2;
    assign o_PC_set1_rf_rdata1 = PC_set_Buffer[tail].rf_rdata1;
    assign o_PC_set1_rf_rdata2 = PC_set_Buffer[tail].rf_rdata2;
    assign o_PC_set1_sign_bit = PC_set_Buffer[tail].sign_bit;
    assign o_PC_set1_type_predict = PC_set_Buffer[tail].type_predict;
    assign o_PC_set1_PC_pre = PC_set_Buffer[tail].PC_pre;
    assign o_PC_set1_csr_type = PC_set_Buffer[tail].csr_type;
    assign o_PC_set1_csr_raddr = PC_set_Buffer[tail].csr_raddr;
    assign o_PC_set1_ecode_in = PC_set_Buffer[tail].ecode_in;
    assign o_PC_set1_ecode_we = PC_set_Buffer[tail].ecode_we;
    assign o_PC_set1_code_for_cacop = PC_set_Buffer[tail].code_for_cacop;

    assign o_PC_set2_instruction = PC_set_Buffer[tail_plus_1].instruction;
    assign o_PC_set2_PC = PC_set_Buffer[tail_plus_1].PC;
    assign o_PC_set2_o_inst_lawful = PC_set_Buffer[tail_plus_1].o_inst_lawful;
    assign o_PC_set2_o_valid = PC_set_Buffer[tail_plus_1].o_valid;
    assign o_PC_set2_inst_type = PC_set_Buffer[tail_plus_1].inst_type;
    assign o_PC_set2_br_type = PC_set_Buffer[tail_plus_1].br_type;
    assign o_PC_set2_imm = PC_set_Buffer[tail_plus_1].imm;
    assign o_PC_set2_rf_rd = PC_set_Buffer[tail_plus_1].rf_rd;
    assign o_PC_set2_rf_we = PC_set_Buffer[tail_plus_1].rf_we;
    assign o_PC_set2_alu_src1_sel = PC_set_Buffer[tail_plus_1].alu_src1_sel;
    assign o_PC_set2_alu_src2_sel = PC_set_Buffer[tail_plus_1].alu_src2_sel;
    assign o_PC_set2_alu_op = PC_set_Buffer[tail_plus_1].alu_op;
    assign o_PC_set2_mem_we = PC_set_Buffer[tail_plus_1].mem_we;
    assign o_PC_set2_ldst_type = PC_set_Buffer[tail_plus_1].ldst_type;
    assign o_PC_set2_mux_sel = PC_set_Buffer[tail_plus_1].mux_sel;
    assign o_PC_set2_rf_raddr1 = PC_set_Buffer[tail_plus_1].rf_raddr1;
    assign o_PC_set2_rf_raddr2 = PC_set_Buffer[tail_plus_1].rf_raddr2;
    assign o_PC_set2_rf_rdata1 = PC_set_Buffer[tail_plus_1].rf_rdata1;
    assign o_PC_set2_rf_rdata2 = PC_set_Buffer[tail_plus_1].rf_rdata2;
    assign o_PC_set2_sign_bit = PC_set_Buffer[tail_plus_1].sign_bit;
    assign o_PC_set2_type_predict = PC_set_Buffer[tail_plus_1].type_predict;
    assign o_PC_set2_PC_pre = PC_set_Buffer[tail_plus_1].PC_pre;
    assign o_PC_set2_csr_type = PC_set_Buffer[tail_plus_1].csr_type;
    assign o_PC_set2_csr_raddr = PC_set_Buffer[tail_plus_1].csr_raddr;
    assign o_PC_set2_ecode_in = PC_set_Buffer[tail_plus_1].ecode_in;
    assign o_PC_set2_ecode_we = PC_set_Buffer[tail_plus_1].ecode_we;
    assign o_PC_set2_code_for_cacop = PC_set_Buffer[tail_plus_1].code_for_cacop;

    assign a_rf_raddr1 = PC_set_Buffer[tail].rf_raddr1;
    assign a_rf_raddr2 = PC_set_Buffer[tail].rf_raddr2;
    assign b_rf_raddr1 = PC_set_Buffer[tail_plus_1].rf_raddr1;
    assign b_rf_raddr2 = PC_set_Buffer[tail_plus_1].rf_raddr2;
    assign csr_raddr_1 = PC_set_Buffer[tail].csr_raddr;
    assign csr_raddr_2 = PC_set_Buffer[tail_plus_1].csr_raddr;

endmodule