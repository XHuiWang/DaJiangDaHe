module FU_BR(
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
    input           [31: 0]     EX_pc_pd_a,         //A指令的分支预测的跳转结果PC
    input           [31: 0]     EX_pc_pd_b,         //B指令的分支预测的跳转结果PC          

    // input                       stall_dcache,
    input                       stall_dcache_buf,
    input                       stall_div_buf,
    
    output                      EX_br_a,            //A指令是否需要修正预测的结果
    output                      EX_br,              //是否需要修正预测的结果
    output          [31: 0]     EX_pc_br,           //修正时应跳转到的地址

    //发给分支预测的信号
    output          [31: 0]     EX_pc_of_br,        //分支指令的PC值，不考虑stall
    input           [ 1: 0]     EX_pd_type_a,       //A指令的分支类型（与分支预测交互）
    input           [ 1: 0]     EX_pd_type_b,       //B指令的分支类型（与分支预测交互）
    output          [ 1: 0]     EX_pd_type,         //分支指令的分支类型（与分支预测交互）需要考虑stall  
    output          [31: 0]     EX_br_target,       //分支指令原本的目标地址，不考虑stall
    output                      EX_br_jump          //分支指令原本是否应跳转，不考虑stall
);
logic               br_orig_a;      //A跳转指令是否本应跳转
logic               br_orig_b;      //B跳转指令是否本应跳转
logic   [31: 0]     pc_br_orig_a;   //无分支预测时，A应跳转到的地址
logic   [31: 0]     pc_br_orig_b;   //无分支预测时，B应跳转到的地址

// logic               EX_br_a;        //A指令是否需要修正预测的结果
logic               EX_br_b;        //B指令是否需要修正预测的结果
logic   [31: 0]     EX_pc_br_a;     //A指令修正时应跳转到的地址
logic   [31: 0]     EX_pc_br_b;     //B指令修正时应跳转到的地址
logic               EX_br_orig;     //尚未考虑Dcache的stall时，是否需要修正预测的结果
assign EX_br_a      =(EX_br_type_a==4'b0000)?1'b0:EX_br_pd_a^br_orig_a || (|(EX_pc_pd_a^pc_br_orig_a));//是否需要修正=预测结果与原本结果的异或
assign EX_br_b      =(EX_br_type_b==4'b0000)?1'b0:EX_br_pd_b^br_orig_b || (|(EX_pc_pd_b^pc_br_orig_b));//是否需要修正=预测结果与原本结果的异或
assign EX_pc_br_a   =br_orig_a?pc_br_orig_a:(EX_pc_a+32'd4); //修正后的地址：应跳预测不跳则跳过去，不应跳预测跳则跳回去
assign EX_pc_br_b   =br_orig_b?pc_br_orig_b:(EX_pc_b+32'd4); //修正后的地址：应跳预测不跳则跳过去，不应跳预测跳则跳回去

assign EX_br_orig   =EX_br_a|EX_br_b;
assign EX_br        =EX_br_orig&(~stall_dcache_buf)&(~stall_div_buf); 
//MEM段dcache stall流水线时，若EX段为BR指令，在stall的整个期间（stall_dcache为1以及其后的第一个为0的周期）
//因stall造成的EX段的EX_br_orig连续置1的多个周期中，EX段的EX_BR仅在第一个周期可以被置1
//stall_div/stall_dcache/ex_br的产生是同时的，均用buf来抑制，ex_br的再次产生前stall置零，再次产生时buf置零，不会有多余干涉
assign EX_pc_br     =(EX_br_a)?EX_pc_br_a:EX_pc_br_b;  

//发给分支预测
assign EX_pc_of_br  =EX_pd_type_a==2'b00 ? EX_pc_b : EX_pc_a;
assign EX_pd_type   =(EX_pd_type_a==2'b00 ? EX_pd_type_b : EX_pd_type_a)
                        &{2{~stall_dcache_buf}}&{2{~stall_div_buf}};
assign EX_br_target =EX_pd_type_a==2'b00 ? pc_br_orig_b : pc_br_orig_a;
assign EX_br_jump   =EX_pd_type_a==2'b00 ? br_orig_b : br_orig_a;
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