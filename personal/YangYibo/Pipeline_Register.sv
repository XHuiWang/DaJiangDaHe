`include "config.vh"
module Pipeline_Register(
    input                       clk,
    input                       rstn,

    input                       stall_ex,
    input                       stall_ex_buf,
    input                       stall_dcache,
    input                       stall_dcache_buf,

    input           [ 6: 0]     MEM_ecode_in_a, //A指令的异常码
    input           [ 6: 0]     MEM_ecode_in_b, //B指令的异常码
    input                       WB_flush_csr,
    
    //BR 跳转在MEM段生效
    input                       EX_br_a,        //A指令是否需要修正预测的结果
    input                       EX_br_b,        //B指令是否需要修正预测的结果
    input           [31: 0]     EX_pc_br_a,     //A指令需要修正预测结果时，PC的修正值
    input           [31: 0]     EX_pc_br_b,     //B指令需要修正预测结果时，PC的修正值
    input                       EX_br_a_ori,    //A跳转指令是否本应跳转
    input                       EX_br_b_ori,    //B跳转指令是否本应跳转
    input           [31: 0]     EX_pc_br_a_ori, //无分支预测时，A应跳转到的地址
    input           [31: 0]     EX_pc_br_b_ori, //无分支预测时，B应跳转到的地址
    input           [ 1: 0]     EX_pd_type_a,   //A指令的分支类型（与分支预测交互）
    input           [ 1: 0]     EX_pd_type_b,   //B指令的分支类型（与分支预测交互）

    output  logic               MEM_br_a,       //在MEM段组合地抑制B路关键信号
    output  logic               MEM_br,         //作为EX->MEM段的flush信号
    output  logic   [31: 0]     MEM_pc_br,
    output  logic   [31: 0]     MEM_pc_of_br,
    output  logic   [ 1: 0]     MEM_pd_type,
    output  logic   [31: 0]     MEM_br_target,
    output  logic               MEM_br_jump,
    

    input           [31: 0]     EX_pc_a,            //A指令的PC
    input           [31: 0]     EX_pc_b,            //B指令的PC
    output  logic   [31: 0]     MEM_pc_a,
    output  logic   [31: 0]     MEM_pc_b,
    output  logic   [31: 0]     WB_pc_a,            
    output  logic   [31: 0]     WB_pc_b,

    input           [31: 0]     EX_alu_result_a,    //A指令的运算结果
    input           [31: 0]     EX_alu_result_b,    //B指令的运算结果
    output  logic   [31: 0]     MEM_alu_result_a,
    output  logic   [31: 0]     MEM_alu_result_b,

    input           [63: 0]     EX_mul_tmp1,        //乘法器临时结果1
    input           [63: 0]     EX_mul_tmp2,        //乘法器临时结果2
    output  logic   [63: 0]     MEM_mul_tmp1,
    output  logic   [63: 0]     MEM_mul_tmp2,

    input                       EX_rf_we_a,         //A指令寄存器写使能
    input                       EX_rf_we_b,         //B指令寄存器写使能
    input           [ 4: 0]     EX_rf_waddr_a,      //A指令寄存器写地址
    input           [ 4: 0]     EX_rf_waddr_b,      //B指令寄存器写地址
    input           [ 8: 0]     EX_wb_mux_select_b,
    output  logic   [ 8: 0]     MEM_wb_mux_select_b,

    output  logic               MEM_rf_we_a,
    output  logic               MEM_rf_we_b,
    output  logic   [ 4: 0]     MEM_rf_waddr_a,
    output  logic   [ 4: 0]     MEM_rf_waddr_b,
    input           [31: 0]     MEM_rf_wdata_a,
    input           [31: 0]     MEM_rf_wdata_b,


    output  logic               WB_rf_we_a,
    output  logic               WB_rf_we_b,
    output  logic   [ 4: 0]     WB_rf_waddr_a,
    output  logic   [ 4: 0]     WB_rf_waddr_b,
    output  logic   [31: 0]     WB_rf_wdata_a,
    output  logic   [31: 0]     WB_rf_wdata_b

`ifdef DIFFTEST_EN
,
    input   logic   [31: 0]     EX_a_inst,
    input   logic   [31: 0]     EX_b_inst,
    output  logic   [31: 0]     WB_a_inst,
    output  logic   [31: 0]     WB_b_inst,

    input   logic   [ 7: 0]     EX_st_valid,
    input   logic   [ 7: 0]     EX_ld_valid,
    output  logic   [ 7: 0]     WB_st_valid,
    output  logic   [ 7: 0]     WB_ld_valid,

    input   logic   [31: 0]     EX_mem_addr,    //虚拟访存地址
    input   logic   [31: 0]     EX_mem_addr_p,  //物理访存地址
    input   logic   [31: 0]     EX_mem_wdata,
    output  logic   [31: 0]     WB_mem_addr,
    output  logic   [31: 0]     WB_mem_addr_p,
    output  logic   [31: 0]     WB_mem_wdata
`endif
);
logic               MEM_br_b;           //B指令是否需要修正

logic   [31: 0]     MEM_pc_br_a;        //A修正时应跳转到的地址
logic   [31: 0]     MEM_pc_br_b;        //B修正时应跳转到的地址
logic               MEM_br_a_ori, MEM_br_b_ori;
logic   [31: 0]     MEM_pc_br_a_ori, MEM_pc_br_b_ori;
logic   [ 1: 0]     MEM_pd_type_a, MEM_pd_type_b;

logic               MEM_rf_we_b_ori;    //尚未考虑A指令修正预测结果

logic               WB_flush_csr_buf;   //留存一级flush信号来抑制MEM段的关键信号
`ifdef DIFFTEST_EN
logic   [31: 0]     MEM_a_inst;
logic   [31: 0]     MEM_b_inst;
logic   [ 7: 0]     MEM_st_valid;
logic   [ 7: 0]     MEM_ld_valid;
logic   [31: 0]     MEM_mem_addr;
logic   [31: 0]     MEM_mem_addr_p;
logic   [31: 0]     MEM_mem_wdata;
`endif
assign MEM_br   = ( MEM_br_a | MEM_br_b ) & 
    ( ~stall_dcache_buf & ~stall_ex_buf ) & ~WB_flush_csr_buf;
assign MEM_pc_br = MEM_br_a ? MEM_pc_br_a : MEM_pc_br_b;

assign MEM_pc_of_br = MEM_pd_type_a==2'b00 ? MEM_pc_b : MEM_pc_a;
assign MEM_pd_type = (MEM_pd_type_a==2'b00 ? MEM_pd_type_b : MEM_pd_type_a) & 
    {2{~stall_dcache_buf}}&{2{~stall_ex_buf}} & ~WB_flush_csr_buf;
assign MEM_br_target = MEM_pd_type_a==2'b00 ? MEM_pc_br_b_ori : MEM_pc_br_a_ori;
assign MEM_br_jump = MEM_pd_type_a==2'b00 ? MEM_br_b_ori : MEM_br_a_ori;

assign MEM_rf_we_b = ~MEM_br_a & MEM_rf_we_b_ori;
//stall流水线时，若MEM段为BR指令，在stall的整个期间（stall为1以及其后的第一个为0的周期）
//因stall造成的MEM_br_orig等信号连续置1的多个周期中，MEM_br等信号仅在第一个周期可以被置1
//stall_div/stall_dcache/flush的产生是同时的，均用buf来抑制，flush的再次产生前stall置零，再次产生时buf置零，不会有多余干涉
//EX->MEM
always@(posedge clk)
begin
    if(!rstn | WB_flush_csr | MEM_br)
    begin
        MEM_rf_we_a<=1'b0;
        MEM_rf_we_b_ori<=1'b0;
        MEM_br_a<=1'b0;  //对B路抑制信号
        MEM_br_b<=1'b0;
        MEM_pd_type_a<=2'b00;
        MEM_pd_type_b<=2'b00;
`ifdef DIFFTEST_EN
        MEM_st_valid<=8'b0000_0000;
        MEM_ld_valid<=8'b0000_0000;
`endif
    end
    else if(!stall_dcache&&!stall_ex)begin //考虑到前递，stall_dcache应阻塞所有段间寄存器
        MEM_rf_we_a<=EX_rf_we_a;
        MEM_rf_we_b_ori<=EX_rf_we_b;
        MEM_br_a<=EX_br_a;  //对B路抑制信号
        MEM_br_b<=EX_br_b;
        MEM_pd_type_a<=EX_pd_type_a;
        MEM_pd_type_b<=EX_pd_type_b;
`ifdef DIFFTEST_EN
        MEM_st_valid<=EX_st_valid;
        MEM_ld_valid<=EX_ld_valid;
`endif
    end
    else begin end
end


//MEM->WB
always@(posedge clk)begin
    if(!rstn | WB_flush_csr) begin
        WB_rf_we_a<=1'b0;
        WB_rf_we_b<=1'b0;
`ifdef DIFFTEST_EN
        WB_st_valid<=8'b0000_0000;
        WB_ld_valid<=8'b0000_0000;
`endif
    end
    else if(!stall_dcache&&!stall_ex) begin
        WB_rf_we_a<=|MEM_ecode_in_a ? 1'b0 : MEM_rf_we_a;    //A指令有无非中断例外
        WB_rf_we_b<=((|MEM_ecode_in_a) | (|MEM_ecode_in_b)) ? 1'b0 : MEM_rf_we_b; //AB指令有无非中断例外
`ifdef DIFFTEST_EN
        WB_st_valid<=MEM_st_valid;
        WB_ld_valid<=MEM_ld_valid;
`endif
    end
    else begin end
end

always@(posedge clk) begin
    if(!stall_dcache&&!stall_ex)begin
        MEM_pc_br_a <= EX_pc_br_a;
        MEM_pc_br_b <= EX_pc_br_b;
        MEM_br_a_ori<=EX_br_a_ori;
        MEM_br_b_ori<=EX_br_b_ori;
        MEM_pc_br_a_ori<=EX_pc_br_a_ori;
        MEM_pc_br_b_ori<=EX_pc_br_b_ori;

        MEM_alu_result_a<=EX_alu_result_a;
        MEM_alu_result_b<=EX_alu_result_b;
        MEM_rf_waddr_a<=EX_rf_waddr_a;
        MEM_rf_waddr_b<=EX_rf_waddr_b;
        MEM_wb_mux_select_b<=EX_wb_mux_select_b;
        MEM_mul_tmp1<=EX_mul_tmp1;
        MEM_mul_tmp2<=EX_mul_tmp2;
        MEM_pc_a<=EX_pc_a;
        MEM_pc_b<=EX_pc_b;

        WB_pc_a<=MEM_pc_a;
        WB_pc_b<=MEM_pc_b;
        WB_rf_waddr_a<=MEM_rf_waddr_a;
        WB_rf_waddr_b<=MEM_rf_waddr_b;
        WB_rf_wdata_a<=MEM_rf_wdata_a;
        WB_rf_wdata_b<=MEM_rf_wdata_b;
        
        WB_flush_csr_buf<=WB_flush_csr;

`ifdef DIFFTEST_EN
        MEM_a_inst<=EX_a_inst;
        MEM_b_inst<=EX_b_inst;
        WB_a_inst<=MEM_a_inst;
        WB_b_inst<=MEM_b_inst;

        MEM_mem_addr<=EX_mem_addr;
        MEM_mem_addr_p<=EX_mem_addr_p;
        MEM_mem_wdata<=EX_mem_wdata;
        WB_mem_addr<=MEM_mem_addr;
        WB_mem_addr_p<=MEM_mem_addr_p;
        WB_mem_wdata<=MEM_mem_wdata;
`endif
    end
    else begin end
end
endmodule