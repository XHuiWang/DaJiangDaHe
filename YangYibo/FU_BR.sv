module FU_BR(
    input                       clk,
    input                       rstn,
    input                       stall,

    input           [31: 0]     EX_pc_a,            //A指令的PC值
    input           [31: 0]     EX_pc_b,            //B指令的PC值
    input           [31: 0]     EX_rf_rdata_a1,     //A指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_a2,     //A指令的第二个寄存器的值
    input           [31: 0]     EX_rf_rdata_b1,     //B指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_b2,     //B指令的第二个寄存器的值
    input           [31: 0]     EX_imm_a,           //A指令的立即数
    input           [31: 0]     EX_imm_b,           //B指令的立即数
    input           [ 3: 0]     EX_br_type_a,       //A指令的分支类型
    input           [ 3: 0]     EX_br_type_b,       //B指令的分支类型

    input                       EX_br_pd_a,         //predict A指令的分支预测，1预测跳转，0预测不跳转                  
    input                       EX_br_pd_b,         //predict B指令的分支预测，1预测跳转，0预测不跳转                  

    output                      EX_br_a,            //A指令是否需要修正预测的结果
    output                      EX_br_b,            //B指令是否需要修正预测的结果
    output          [31: 0]     EX_pc_br_a,         //A指令修正时应跳转到的地址
    output          [31: 0]     EX_pc_br_b          //B指令修正时应跳转到的地址
);
logic               br_orig_a;      //A跳转指令是否本应跳转
logic               br_orig_b;      //B跳转指令是否本应跳转
logic   [31: 0]     pc_br_orig_a;   //无分支预测时，A应跳转到的地址
logic   [31: 0]     pc_br_orig_b;   //无分支预测时，B应跳转到的地址


assign EX_br_a=EX_br_pd_a^br_orig_a;       //是否需要修正=预测结果与原本结果的异或
assign EX_br_b=EX_br_pd_b^br_orig_b;       //是否需要修正=预测结果与原本结果的异或
assign EX_pc_br_a=br_orig_a?pc_br_orig_a:(EX_pc_a+32'd4); //修正后的地址：应跳预测不跳则跳过去，不应跳预测跳则跳回去
assign EX_pc_br_b=br_orig_b?pc_br_orig_b:(EX_pc_b+32'd4); //修正后的地址：应跳预测不跳则跳过去，不应跳预测跳则跳回去

Branch Branch_A(
    .br_type(EX_br_type_a),
    .pc_orig(EX_pc_a),
    .imm(EX_imm_a),
    .rf_rdata1(EX_rf_rdata_a1),
    .rf_rdata2(EX_rf_rdata_a2),
    .br(br_orig_a),
    .pc_br(pc_br_orig_a)
);
Branch Branch_B(
    .br_type(EX_br_type_b),
    .pc_orig(EX_pc_b),
    .imm(EX_imm_b),
    .rf_rdata1(EX_rf_rdata_b1),
    .rf_rdata2(EX_rf_rdata_b2),
    .br(br_orig_b),
    .pc_br(pc_br_orig_b)
);

endmodule