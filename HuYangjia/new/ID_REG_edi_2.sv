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

    logic [31: 0] instruction   [0:NUM-1];
    logic [31: 0] PC            [0:NUM-1];
    logic [ 0: 0] o_inst_lawful [0:NUM-1];
    logic [ 0: 0] o_valid       [0:NUM-1];
    logic [ 9: 0] inst_type     [0:NUM-1];
    logic [ 9: 0] br_type       [0:NUM-1];
    logic [31: 0] imm           [0:NUM-1];
    logic [ 4: 0] rf_rd         [0:NUM-1];
    logic [ 0: 0] rf_we         [0:NUM-1];
    logic [ 3: 0] alu_src1_sel  [0:NUM-1];
    logic [ 3: 0] alu_src2_sel  [0:NUM-1];
    logic [11: 0] alu_op        [0:NUM-1];
    logic [ 0: 0] mem_we        [0:NUM-1];
    logic [ 3: 0] ldst_type     [0:NUM-1];
    logic [ 8: 0] mux_sel       [0:NUM-1];
    logic [ 4: 0] rf_raddr1     [0:NUM-1];
    logic [ 4: 0] rf_raddr2     [0:NUM-1];
    logic [31: 0] rf_rdata1     [0:NUM-1];
    logic [31: 0] rf_rdata2     [0:NUM-1];
    logic [ 0: 0] sign_bit      [0:NUM-1];
    logic [ 1: 0] type_predict  [0:NUM-1];
    logic [31: 0] PC_pre        [0:NUM-1];
    logic [ 2: 0] csr_type      [0:NUM-1];
    logic [13: 0] csr_raddr     [0:NUM-1];
    logic [ 6: 0] ecode_in      [0:NUM-1];
    logic [ 0: 0] ecode_we      [0:NUM-1];
    logic [ 4: 0] code_for_cacop[0:NUM-1];

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


    always @(posedge clk) begin
        if( !rstn ) begin
            for(integer i = 0; i < NUM ; i++) begin
                instruction   [i] = 0;
                PC            [i] = 0;
                o_inst_lawful [i] = 0;
                o_valid       [i] = 0;
                inst_type     [i] = 0;
                br_type       [i] = 0;
                imm           [i] = 0;
                rf_rd         [i] = 0;
                rf_we         [i] = 0;
                alu_src1_sel  [i] = 0;
                alu_src2_sel  [i] = 0;
                alu_op        [i] = 0;
                mem_we        [i] = 0;
                ldst_type     [i] = 0;
                mux_sel       [i] = 0;
                rf_raddr1     [i] = 0;
                rf_raddr2     [i] = 0;
                rf_rdata1     [i] = 0;
                rf_rdata2     [i] = 0;
                sign_bit      [i] = 0;
                type_predict  [i] = 0;
                PC_pre        [i] = 0;
                csr_type      [i] = 0;
                csr_raddr     [i] = 0;
                ecode_in      [i] = 0;
                ecode_we      [i] = 0;
                code_for_cacop[i] = 0;
            end
        end
        else begin 
            case (length_add)
                2'd1: begin
                    instruction[head] <= i_PC_set1_instruction;
                    PC[head] <= i_PC_set1_PC;
                    o_inst_lawful[head] <= i_PC_set1_o_inst_lawful;
                    o_valid[head] <= i_PC_set1_o_valid;
                    inst_type[head] <= i_PC_set1_inst_type;
                    br_type[head] <= i_PC_set1_br_type;
                    imm[head] <= i_PC_set1_imm;
                    rf_rd[head] <= i_PC_set1_rf_rd;
                    rf_we[head] <= i_PC_set1_rf_we;
                    alu_src1_sel[head] <= i_PC_set1_alu_src1_sel;
                    alu_src2_sel[head] <= i_PC_set1_alu_src2_sel;
                    alu_op[head] <= i_PC_set1_alu_op;
                    mem_we[head] <= i_PC_set1_mem_we;
                    ldst_type[head] <= i_PC_set1_ldst_type;
                    mux_sel[head] <= i_PC_set1_mux_sel;
                    rf_raddr1[head] <= i_PC_set1_rf_raddr1;
                    rf_raddr2[head] <= i_PC_set1_rf_raddr2;
                    rf_rdata1[head] <= i_PC_set1_rf_rdata1;
                    rf_rdata2[head] <= i_PC_set1_rf_rdata2;
                    sign_bit[head] <= i_PC_set1_sign_bit;
                    type_predict[head] <= i_PC_set1_type_predict;
                    PC_pre[head] <= i_PC_set1_PC_pre;
                    csr_type[head] <= i_PC_set1_csr_type;
                    csr_raddr[head] <= i_PC_set1_csr_raddr;
                    ecode_in[head] <= i_PC_set1_ecode_in;
                    ecode_we[head] <= i_PC_set1_ecode_we;
                    code_for_cacop[head] <= i_PC_set1_code_for_cacop;
                end
                2'd2: begin
                    instruction[head] <= i_PC_set1_instruction;
                    PC[head] <= i_PC_set1_PC;
                    o_inst_lawful[head] <= i_PC_set1_o_inst_lawful;
                    o_valid[head] <= i_PC_set1_o_valid;
                    inst_type[head] <= i_PC_set1_inst_type;
                    br_type[head] <= i_PC_set1_br_type;
                    imm[head] <= i_PC_set1_imm;
                    rf_rd[head] <= i_PC_set1_rf_rd;
                    rf_we[head] <= i_PC_set1_rf_we;
                    alu_src1_sel[head] <= i_PC_set1_alu_src1_sel;
                    alu_src2_sel[head] <= i_PC_set1_alu_src2_sel;
                    alu_op[head] <= i_PC_set1_alu_op;
                    mem_we[head] <= i_PC_set1_mem_we;
                    ldst_type[head] <= i_PC_set1_ldst_type;
                    mux_sel[head] <= i_PC_set1_mux_sel;
                    rf_raddr1[head] <= i_PC_set1_rf_raddr1;
                    rf_raddr2[head] <= i_PC_set1_rf_raddr2;
                    rf_rdata1[head] <= i_PC_set1_rf_rdata1;
                    rf_rdata2[head] <= i_PC_set1_rf_rdata2;
                    sign_bit[head] <= i_PC_set1_sign_bit;
                    type_predict[head] <= i_PC_set1_type_predict;
                    PC_pre[head] <= i_PC_set1_PC_pre;
                    csr_type[head] <= i_PC_set1_csr_type;
                    csr_raddr[head] <= i_PC_set1_csr_raddr;
                    ecode_in[head] <= i_PC_set1_ecode_in;
                    ecode_we[head] <= i_PC_set1_ecode_we;
                    code_for_cacop[head] <= i_PC_set1_code_for_cacop;

                    instruction[head_plus_1] <= i_PC_set1_instruction;
                    PC[head_plus_1] <= i_PC_set1_PC;
                    o_inst_lawful[head_plus_1] <= i_PC_set1_o_inst_lawful;
                    o_valid[head_plus_1] <= i_PC_set1_o_valid;
                    inst_type[head_plus_1] <= i_PC_set1_inst_type;
                    br_type[head_plus_1] <= i_PC_set1_br_type;
                    imm[head_plus_1] <= i_PC_set1_imm;
                    rf_rd[head_plus_1] <= i_PC_set1_rf_rd;
                    rf_we[head_plus_1] <= i_PC_set1_rf_we;
                    alu_src1_sel[head_plus_1] <= i_PC_set1_alu_src1_sel;
                    alu_src2_sel[head_plus_1] <= i_PC_set1_alu_src2_sel;
                    alu_op[head_plus_1] <= i_PC_set1_alu_op;
                    mem_we[head_plus_1] <= i_PC_set1_mem_we;
                    ldst_type[head_plus_1] <= i_PC_set1_ldst_type;
                    mux_sel[head_plus_1] <= i_PC_set1_mux_sel;
                    rf_raddr1[head_plus_1] <= i_PC_set1_rf_raddr1;
                    rf_raddr2[head_plus_1] <= i_PC_set1_rf_raddr2;
                    rf_rdata1[head_plus_1] <= i_PC_set1_rf_rdata1;
                    rf_rdata2[head_plus_1] <= i_PC_set1_rf_rdata2;
                    sign_bit[head_plus_1] <= i_PC_set1_sign_bit;
                    type_predict[head_plus_1] <= i_PC_set1_type_predict;
                    PC_pre[head_plus_1] <= i_PC_set1_PC_pre;
                    csr_type[head_plus_1] <= i_PC_set1_csr_type;
                    csr_raddr[head_plus_1] <= i_PC_set1_csr_raddr;
                    ecode_in[head_plus_1] <= i_PC_set1_ecode_in;
                    ecode_we[head_plus_1] <= i_PC_set1_ecode_we;
                    code_for_cacop[head_plus_1] <= i_PC_set1_code_for_cacop;
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
    assign o_PC_set1_instruction = instruction[tail];
    assign o_PC_set1_PC = PC[tail];
    assign o_PC_set1_o_inst_lawful = o_inst_lawful[tail];
    assign o_PC_set1_o_valid = o_valid[tail];
    assign o_PC_set1_inst_type = inst_type[tail];
    assign o_PC_set1_br_type = br_type[tail];
    assign o_PC_set1_imm = imm[tail];
    assign o_PC_set1_rf_rd = rf_rd[tail];
    assign o_PC_set1_rf_we = rf_we[tail];
    assign o_PC_set1_alu_src1_sel = alu_src1_sel[tail];
    assign o_PC_set1_alu_src2_sel = alu_src2_sel[tail];
    assign o_PC_set1_alu_op = alu_op[tail];
    assign o_PC_set1_mem_we = mem_we[tail];
    assign o_PC_set1_ldst_type = ldst_type[tail];
    assign o_PC_set1_mux_sel = mux_sel[tail];
    assign o_PC_set1_rf_raddr1 = rf_raddr1[tail];
    assign o_PC_set1_rf_raddr2 = rf_raddr2[tail];
    assign o_PC_set1_rf_rdata1 = rf_rdata1[tail];
    assign o_PC_set1_rf_rdata2 = rf_rdata2[tail];
    assign o_PC_set1_sign_bit = sign_bit[tail];
    assign o_PC_set1_type_predict = type_predict[tail];
    assign o_PC_set1_PC_pre = PC_pre[tail];
    assign o_PC_set1_csr_type = csr_type[tail];
    assign o_PC_set1_csr_raddr = csr_raddr[tail];
    assign o_PC_set1_ecode_in = ecode_in[tail];
    assign o_PC_set1_ecode_we = ecode_we[tail];
    assign o_PC_set1_code_for_cacop = code_for_cacop[tail];

    assign o_PC_set2_instruction = instruction[tail_plus_1];
    assign o_PC_set2_PC = PC[tail_plus_1];
    assign o_PC_set2_o_inst_lawful = o_inst_lawful[tail_plus_1];
    assign o_PC_set2_o_valid = o_valid[tail_plus_1];
    assign o_PC_set2_inst_type = inst_type[tail_plus_1];
    assign o_PC_set2_br_type = br_type[tail_plus_1];
    assign o_PC_set2_imm = imm[tail_plus_1];
    assign o_PC_set2_rf_rd = rf_rd[tail_plus_1];
    assign o_PC_set2_rf_we = rf_we[tail_plus_1];
    assign o_PC_set2_alu_src1_sel = alu_src1_sel[tail_plus_1];
    assign o_PC_set2_alu_src2_sel = alu_src2_sel[tail_plus_1];
    assign o_PC_set2_alu_op = alu_op[tail_plus_1];
    assign o_PC_set2_mem_we = mem_we[tail_plus_1];
    assign o_PC_set2_ldst_type = ldst_type[tail_plus_1];
    assign o_PC_set2_mux_sel = mux_sel[tail_plus_1];
    assign o_PC_set2_rf_raddr1 = rf_raddr1[tail_plus_1];
    assign o_PC_set2_rf_raddr2 = rf_raddr2[tail_plus_1];
    assign o_PC_set2_rf_rdata1 = rf_rdata1[tail_plus_1];
    assign o_PC_set2_rf_rdata2 = rf_rdata2[tail_plus_1];
    assign o_PC_set2_sign_bit = sign_bit[tail_plus_1];
    assign o_PC_set2_type_predict = type_predict[tail_plus_1];
    assign o_PC_set2_PC_pre = PC_pre[tail_plus_1];
    assign o_PC_set2_csr_type = csr_type[tail_plus_1];
    assign o_PC_set2_csr_raddr = csr_raddr[tail_plus_1];
    assign o_PC_set2_ecode_in = ecode_in[tail_plus_1];
    assign o_PC_set2_ecode_we = ecode_we[tail_plus_1];
    assign o_PC_set2_code_for_cacop = code_for_cacop[tail_plus_1];

    assign a_rf_raddr1 = rf_raddr1[tail];
    assign a_rf_raddr2 = rf_raddr2[tail];
    assign b_rf_raddr1 = rf_raddr1[tail_plus_1];
    assign b_rf_raddr2 = rf_raddr2[tail_plus_1];
    assign csr_raddr_1 = csr_raddr[tail];
    assign csr_raddr_2 = csr_raddr[tail_plus_1];

endmodule