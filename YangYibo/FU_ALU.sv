module FU_ALU(                                      //A指令固定在B指令之前
                                                    //两条BR指令不会同时发射
                                                    //BR指令在前则 BR+B；BR指令在后则A+BR
                                                    //EX_br会阻止B指令的执行，但不会阻止A指令的执行
                                                    //此处暂时认为BR+B的情况，B是预测结果对应位置的指令
                                                    //若BR+B情况下，B为BR地址后的指令，则要改用br_orig

    input           [31: 0]     EX_pc_a,            //A指令的PC值
    input           [31: 0]     EX_pc_b,            //B指令的PC值

    input           [31: 0]     EX_rf_rdata_a1,     //A指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_a2,     //A指令的第二个寄存器的值
    input           [31: 0]     EX_rf_rdata_b1,     //B指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_b2,     //B指令的第二个寄存器的值
    input           [31: 0]     EX_imm_a,           //A指令的立即数
    input           [31: 0]     EX_imm_b,           //B指令的立即数
    input           [ 3: 0]     EX_alu_src_sel_a1,  //A指令的第一个操作数选择信号
    input           [ 3: 0]     EX_alu_src_sel_a2,  //A指令的第二个操作数选择信号
    input           [ 3: 0]     EX_alu_src_sel_b1,  //B指令的第一个操作数选择信号
    input           [ 3: 0]     EX_alu_src_sel_b2,  //B指令的第二个操作数选择信号
    input           [11: 0]     EX_alu_op_a,        //A指令的运算类型
    input           [11: 0]     EX_alu_op_b,        //B指令的运算类型

    input           [31: 0]     EX_csr_rdata,       //B指令的CSR读数据

    output  reg     [31: 0]     EX_alu_result_a,    //A指令的运算结果
    output  reg     [31: 0]     EX_alu_result_b,    //B指令的运算结果
    output  reg     [31: 0]     EX_alu_result_a_n,  //A指令的运算结果 取反加一
    output  reg     [31: 0]     EX_alu_result_b_n   //B指令的运算结果 取反加一
);
logic   [31: 0]      EX_alu_src_a1;
logic   [31: 0]      EX_alu_src_a2;
logic   [31: 0]      EX_alu_src_b1;
logic   [31: 0]      EX_alu_src_b2;
assign EX_alu_result_a_n = ~EX_alu_result_a + 1;
assign EX_alu_result_b_n = ~EX_alu_result_b + 1;
Mux MUX_A1(
    .a(EX_pc_a),
    .b(EX_rf_rdata_a1),
    .c(32'h0000_0000),
    .d(32'h0000_0000),//不使用
    .s(EX_alu_src_sel_a1),
    .y(EX_alu_src_a1)
);
Mux MUX_A2(
    .a(EX_imm_a),
    .b(EX_rf_rdata_a2),
    .c(32'h0000_0004),
    .d(32'h0000_0000),//不使用
    .s(EX_alu_src_sel_a2),
    .y(EX_alu_src_a2)
);
Mux MUX_B1(
    .a(EX_pc_b),
    .b(EX_rf_rdata_b1),
    .c(32'h0000_0000),
    .d(32'h0000_0000),//不使用
    .s(EX_alu_src_sel_b1),
    .y(EX_alu_src_b1)
);
Mux MUX_B2(
    .a(EX_imm_b),
    .b(EX_rf_rdata_b2),
    .c(32'h0000_0004),
    .d(EX_csr_rdata),
    .s(EX_alu_src_sel_b2),
    .y(EX_alu_src_b2)
);
ALU ALU_A(
    .a(EX_alu_src_a1),
    .b(EX_alu_src_a2),
    .f(EX_alu_op_a),
    .y(EX_alu_result_a)
);
ALU ALU_B(
    .a(EX_alu_src_b1),
    .b(EX_alu_src_b2),
    .f(EX_alu_op_b),
    .y(EX_alu_result_b)
);
endmodule