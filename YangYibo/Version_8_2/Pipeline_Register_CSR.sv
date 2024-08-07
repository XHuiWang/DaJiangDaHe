module Pipeline_Register_CSR(
    input                       clk,
    input                       rstn,

    input                       stall_ex,
    input                       stall_dcache,

    input                       MEM_br_a,       //在MEM段组合地抑制B路关键信号
    input                       MEM_br,         //作为EX->MEM段的flush信号
 
    input           [31: 0]     MEM_pc_a,
    input           [31: 0]     MEM_pc_b,
    input           [31: 0]     EX_mem_addr,

    //CSR读写
    //CSRRD CSRWR CSRXCHG ERTN均单发B指令
    input           [13: 0]     EX_csr_waddr,
    input           [31: 0]     EX_csr_we,
    input           [31: 0]     EX_csr_wdata,
    input           [63: 0]     EX_rdcntv,
    input           [31: 0]     EX_rdcntid,
    output  logic   [31: 0]     MEM_csr_we,
    output  logic   [13: 0]     WB_csr_waddr,
    output  logic   [31: 0]     WB_csr_we,
    output  logic   [31: 0]     WB_csr_wdata,
    output  logic   [63: 0]     MEM_rdcntv,
    output  logic   [31: 0]     MEM_rdcntid,

    //CSR控制
    input                       EX_a_enable,
    input                       EX_b_enable,
    output  logic               MEM_a_enable,
    output  logic               MEM_b_enable,
    input                       MEM_interrupt,
    output  logic               MEM_interrupt_buf,  //若MEM_a_enable MEM_b_enable均为0，MEM_interrupt在MEM段保留一拍
    input                       EX_ertn,
    output  logic               MEM_ertn,
    output  logic               WB_ertn,

    input           [ 6: 0]     EX_ecode_in_aa,     //EX段处理后的A指令异常码
    input           [ 6: 0]     EX_ecode_in_bb,     //EX段处理后的B指令异常码
    input                       EX_ecode_we_aa,     //EX段处理后的A指令是否产生例外
    input                       EX_ecode_we_bb,     //EX段处理后的B指令是否产生例外
    // input           [31: 0]     EX_badv_in_a,       //取值地址错记录pc，地址非对齐记录地址
    // input           [31: 0]     EX_badv_in_b,       //B指令 EX段检测访存地址非对齐
    input                       EX_badv_we_a,       //是否发生取指地址错
    input                       EX_badv_we_b,

    output  logic   [ 6: 0]     MEM_ecode_in_a,
    output  logic   [ 6: 0]     MEM_ecode_in_b,
    output  logic               MEM_ecode_we_a,
    output  logic               MEM_ecode_we_b,
    output  logic   [31: 0]     MEM_badv_in_a,
    output  logic   [31: 0]     MEM_badv_in_b,
    output  logic               MEM_badv_we_a,
    output  logic               MEM_badv_we_b,

    input           [ 6: 0]     MEM_ecode_in,
    input                       MEM_ecode_we,
    input           [31: 0]     MEM_badv_in,
    input                       MEM_badv_we,
    input           [31: 0]     MEM_era_in,
    input                       MEM_era_we,
    input                       MEM_era_en,
    input                       MEM_eentry_en,
    input                       MEM_store_state,
    input                       MEM_restore_state,
    input                       MEM_flush_csr,
    input           [31: 0]     MEM_flush_csr_pc,

    output  logic   [ 6: 0]     WB_ecode_in,
    output  logic               WB_ecode_we,
    output  logic   [31: 0]     WB_badv_in,
    output  logic               WB_badv_we,
    output  logic   [31: 0]     WB_era_in,
    output  logic               WB_era_we,
    output  logic               WB_era_en,
    output  logic               WB_eentry_en,
    output  logic               WB_store_state,
    output  logic               WB_restore_state,
    output  logic               WB_flush_csr,
    output  logic   [31: 0]     WB_flush_csr_pc
);
logic   [31: 0]     MEM_mem_addr;
logic   [13: 0]     MEM_csr_waddr;
// logic   [31: 0]     MEM_csr_we;
logic   [31: 0]     MEM_csr_wdata;
logic               MEM_b_enable_ori;       //尚未考虑MEM_br_a
logic   [31: 0]     MEM_csr_we_ori;
logic               MEM_ertn_ori;
logic               MEM_ecode_we_b_ori;
logic               MEM_badv_we_b_ori;

logic               WB_interrupt;   //interrupt留存一级，中断造成的WB_flush_csr应能够完全清空流水线
                                    //例外造成的WB_flush_csr，不能清除interrupt信号的传递
logic               interrupt;  //本次MEM段有尚未处理的中断且可以处理  
        //尚未处理的中断：包括新发来的MEM_interrupt和此前未处理的MEM_interrupt_buf
assign MEM_b_enable = MEM_b_enable_ori & ~MEM_br_a & ~WB_flush_csr;
assign MEM_csr_we = MEM_csr_we_ori & {32{~MEM_br_a}}; 
assign MEM_ertn = MEM_ertn_ori & ~MEM_br_a;
assign MEM_ecode_we_b = MEM_ecode_we_b_ori & ~MEM_br_a;
assign MEM_badv_we_b = MEM_badv_we_b_ori & ~MEM_br_a;
assign MEM_badv_in_a = MEM_pc_a;
assign MEM_badv_in_b = MEM_ecode_we_b & MEM_ecode_in_b==7'h8 ? MEM_pc_b : MEM_mem_addr;

assign interrupt = ( MEM_a_enable | MEM_b_enable ) & (MEM_interrupt | MEM_interrupt_buf);

always@(posedge clk)
begin
    if(!rstn | WB_flush_csr | MEM_br)
    begin
        MEM_a_enable<=1'b0;
        MEM_ecode_we_a<=1'b0;
        MEM_badv_we_a<=1'b0;

        MEM_b_enable_ori<=1'b0;
        MEM_ecode_we_b_ori<=1'b0;
        MEM_badv_we_b_ori<=1'b0;
        MEM_csr_we_ori<=32'h0000_0000;
        MEM_ertn_ori<=1'b0;
    end
    else if(!stall_dcache&&!stall_ex)begin //考虑到前递，stall应阻塞所有段间寄存器
        MEM_a_enable<=EX_a_enable;
        MEM_ecode_we_a<=EX_ecode_we_aa;
        MEM_badv_we_a<=EX_badv_we_a;

        MEM_b_enable_ori<=EX_b_enable;
        MEM_ecode_we_b_ori<=EX_ecode_we_bb;
        MEM_badv_we_b_ori<=EX_badv_we_b;  
        MEM_csr_we_ori<=EX_csr_we;
        MEM_ertn_ori<= ( (|EX_ecode_in_aa) | (|EX_ecode_in_bb) ) ? 1'b0 : EX_ertn;  //保险，若译码段已考虑特权等级，此处可简化
    end
    else begin end
end

//MEM->WB
always@(posedge clk)begin
    if(!rstn) begin
        MEM_interrupt_buf<=1'b0;
        WB_csr_we<=32'h0000_0000;
        WB_ertn<=1'b0;
        WB_ecode_we<=1'b0;
        WB_badv_we<=1'b0;
        WB_era_we<=1'b0;
        WB_era_en<=1'b0;
        WB_eentry_en<=1'b0;
        WB_store_state<=1'b0;
        WB_restore_state<=1'b0;
        WB_flush_csr<=1'b0;
        WB_flush_csr_pc<=32'h0000_0000;
        WB_interrupt<=1'b0;
    end
    else if(WB_flush_csr)begin  //TOFIX: 要考虑中断在MEM，例外在WB时，MEM_interrupt_buf在本级保留直到新的有效指令到来
        MEM_interrupt_buf <= (~MEM_a_enable&~MEM_b_enable&(MEM_interrupt|MEM_interrupt_buf)) & ~WB_interrupt;
            //存在尚未处理的中断且本轮MEM段不能处理中断，中断信号保留一拍，若flush由中断引发，不保留
        WB_csr_we<=32'h0000_0000;
        WB_ertn<=1'b0;
        WB_ecode_we<=interrupt & ~WB_interrupt;   //中断不受非中断影响，中断受中断影响
        WB_badv_we<=1'b0;
        WB_era_we<=interrupt & ~WB_interrupt;   //中断不受非中断影响，中断受中断影响
        WB_era_en<=1'b0;
        WB_eentry_en<=interrupt & ~WB_interrupt;
        WB_store_state<=interrupt & ~WB_interrupt;
        WB_restore_state<=1'b0;
        WB_flush_csr<=interrupt & ~WB_interrupt;
        WB_flush_csr_pc<=MEM_flush_csr_pc;
        WB_interrupt<=interrupt;
    end
    else if(!stall_dcache&&!stall_ex)begin
        //存在尚未处理的中断且本轮MEM段不能处理中断，中断信号保留一拍
        MEM_interrupt_buf <= (~MEM_a_enable&~MEM_b_enable)&(MEM_interrupt|MEM_interrupt_buf);
        WB_csr_we<= |MEM_ecode_in ? 32'h0 : MEM_csr_we; //非中断例外，特别是特权等级错例外时不写入
        WB_ertn<=MEM_ertn;
        WB_ecode_we<=MEM_ecode_we;
        WB_badv_we<=MEM_badv_we;
        WB_era_we<=MEM_era_we;
        WB_era_en<=MEM_era_en;
        WB_eentry_en<=MEM_eentry_en;
        WB_store_state<=MEM_store_state;
        WB_restore_state<=MEM_restore_state;
        WB_flush_csr<=MEM_flush_csr;
        WB_flush_csr_pc<=MEM_flush_csr_pc;
        WB_interrupt<=(MEM_a_enable | MEM_b_enable) & (MEM_interrupt | MEM_interrupt_buf);
            //WB_interrupt记录MEM段的中断是否被处理
    end
end

always@(posedge clk) begin
    if(!stall_dcache&&!stall_ex)begin
        MEM_mem_addr<=EX_mem_addr;
        MEM_csr_waddr<=EX_csr_waddr;
        MEM_csr_wdata<=EX_csr_wdata;
        // MEM_badv_in_a<=EX_badv_in_a;
        // MEM_badv_in_b<=EX_badv_in_b;
        MEM_ecode_in_b<=EX_ecode_in_bb;
        MEM_rdcntv<=EX_rdcntv;
        MEM_rdcntid<=EX_rdcntid;
        MEM_ecode_in_a<=EX_ecode_in_aa;

        WB_csr_waddr<=MEM_csr_waddr;
        WB_csr_wdata<=MEM_csr_wdata;
        WB_ecode_in<=MEM_ecode_in;
        WB_badv_in<=MEM_badv_in;
        WB_era_in<=MEM_era_in;
    end
    else begin end
end
endmodule