module FU_CSR(
    //CSR读写
    input           [31: 0]     EX_rf_rdata_b1_f,
    input           [31: 0]     EX_rf_rdata_b2_f,
    input           [ 2: 0]     EX_csr_type,
    output          [31: 0]     EX_csr_we,
    output          [31: 0]     EX_csr_wdata,

    //CSR控制
    input           [31: 0]     EX_pc_a,            //A指令的PC值
    input           [31: 0]     EX_pc_b,            //B指令的PC值
    input           [ 6: 0]     EX_ecode_in_a,      //A指令的异常码
    input           [ 6: 0]     EX_ecode_in_b,      //B指令的异常码
    input                       EX_ecode_we_a,      //A指令是否产生例外
    input                       EX_ecode_we_b,      //B指令是否产生例外
    input                       EX_mem_rvalid,      //B指令为LOAD指令
    input                       EX_mem_wvalid,      //B指令为STORE指令
    input           [31: 0]     EX_mem_addr,        //B指令访存地址
    input           [ 2: 0]     EX_mem_type,        //B指令访存类型

    output  wire    [ 6: 0]     EX_ecode_in_aa,     //EX段处理后的A指令异常码
    output  wire    [ 6: 0]     EX_ecode_in_bb,     //EX段处理后的B指令异常码
    output  wire                EX_ecode_we_aa,     //EX段处理后的A指令是否产生例外
    output  wire                EX_ecode_we_bb,     //EX段处理后的B指令是否产生例外

    output  wire    [31: 0]     EX_badv_in_a,       //取值地址错记录pc，地址非对齐记录地址
    output  wire    [31: 0]     EX_badv_in_b,       //B指令 EX段检测访存地址非对齐
    output  wire                EX_badv_we_a,       //是否发生取指地址错
    output  wire                EX_badv_we_b
);
//CSR读写
assign EX_csr_we = {32{EX_csr_type[1]}} | ({32{EX_csr_type[2]}}&EX_rf_rdata_b1_f);
assign EX_csr_wdata = EX_rf_rdata_b2_f; 
//CSR控制
logic               ale, ale_h, ale_w;    //B指令 访存地址非对齐例外 half word
assign ale_h = (EX_mem_rvalid | EX_mem_wvalid) & 
    ( EX_mem_type[2] |  EX_mem_type[1]) & EX_mem_type[0] & EX_mem_addr[0];
assign ale_w = (EX_mem_rvalid | EX_mem_wvalid) & 
    (~EX_mem_type[2] & ~EX_mem_type[1]) & (EX_mem_addr[1:0]!=2'b00);
assign ale   = ale_h | ale_w;

assign EX_ecode_in_aa = EX_ecode_in_a;  //A指令在EX段不会产生例外
assign EX_ecode_in_bb = EX_ecode_we_b ? EX_ecode_in_b : 
    (ale ? 7'h9 : EX_ecode_in_b);
assign EX_ecode_we_aa = EX_ecode_we_a;
assign EX_ecode_we_bb = EX_ecode_we_b | ale;

assign EX_badv_in_a = EX_ecode_we_a & EX_ecode_in_a== 7'h8 ? EX_pc_a : 32'h0000_0000;
assign EX_badv_in_b = EX_ecode_we_b & EX_ecode_in_b== 7'h8 ? EX_pc_b : 
    (ale ? EX_mem_addr : 32'h0000_0000);
assign EX_badv_we_a = EX_ecode_we_a & EX_ecode_in_a== 7'h8;
assign EX_badv_we_b = EX_ecode_we_b & EX_ecode_in_b== 7'h8 | ale;
endmodule