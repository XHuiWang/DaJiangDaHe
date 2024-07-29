module Pipeline_Register_CSR(
    input                       clk,
    input                       rstn,
    input                       stall_dcache,
    input                       stall_div,
    input                       EX_br_a,      //A指令是否需要修正预测的结果，在EX段发生跳转

    //CSR读写
    //CSRRD CSRWR CSRXCHG ERTN均单发B指令
    input           [13: 0]     EX_csr_waddr,
    input           [31: 0]     EX_csr_we,
    input           [31: 0]     EX_csr_wdata,
    output  reg     [31: 0]     MEM_csr_we,
    output  reg     [13: 0]     WB_csr_waddr,
    output  reg     [31: 0]     WB_csr_we,
    output  reg     [31: 0]     WB_csr_wdata,

    //CSR控制
    input                       EX_ertn,
    output  reg                 MEM_ertn,
    output  reg                 WB_ertn,

    input           [ 6: 0]     EX_ecode_in_aa,     //EX段处理后的A指令异常码
    input           [ 6: 0]     EX_ecode_in_bb,     //EX段处理后的B指令异常码
    input                       EX_ecode_we_aa,     //EX段处理后的A指令是否产生例外
    input                       EX_ecode_we_bb,     //EX段处理后的B指令是否产生例外
    input           [31: 0]     EX_badv_in_a,       //取值地址错记录pc，地址非对齐记录地址
    input           [31: 0]     EX_badv_in_b,       //B指令 EX段检测访存地址非对齐
    input                       EX_badv_we_a,       //是否发生取指地址错
    input                       EX_badv_we_b,

    output  reg     [ 6: 0]     MEM_ecode_in_a,
    output  reg     [ 6: 0]     MEM_ecode_in_b,
    output  reg                 MEM_ecode_we_a,
    output  reg                 MEM_ecode_we_b,
    output  reg     [31: 0]     MEM_badv_in_a,
    output  reg     [31: 0]     MEM_badv_in_b,
    output  reg                 MEM_badv_we_a,
    output  reg                 MEM_badv_we_b,

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

    output  reg     [ 6: 0]     WB_ecode_in,
    output  reg                 WB_ecode_we,
    output  reg     [31: 0]     WB_badv_in,
    output  reg                 WB_badv_we,
    output  reg     [31: 0]     WB_era_in,
    output  reg                 WB_era_we,
    output  reg                 WB_era_en,
    output  reg                 WB_eentry_en,
    output  reg                 WB_store_state,
    output  reg                 WB_restore_state,
    output  reg                 WB_flush_csr,
    output  reg     [31: 0]     WB_flush_csr_pc
);
logic   [13: 0]     MEM_csr_waddr;
// logic   [31: 0]     MEM_csr_we;
logic   [31: 0]     MEM_csr_wdata;
always@(posedge clk)
begin
    if(!rstn | WB_flush_csr)
    begin
        MEM_csr_waddr<=14'h0000;
        MEM_csr_we<=32'h0000_0000;
        MEM_csr_wdata<=32'h0000_0000;
        WB_csr_waddr<=14'h0000;
        WB_csr_we<=32'h0000_0000;
        WB_csr_wdata<=32'h0000_0000;
        MEM_ertn<=1'b0;
        WB_ertn<=1'b0;
        MEM_ecode_in_a<=7'h0;
        MEM_ecode_in_b<=7'h0;
        MEM_ecode_we_a<=1'b0;
        MEM_ecode_we_b<=1'b0;
        MEM_badv_in_a<=32'h0000_0000;
        MEM_badv_in_b<=32'h0000_0000;
        MEM_badv_we_a<=1'b0;
        MEM_badv_we_b<=1'b0;
        WB_ecode_in<=7'h0;
        WB_ecode_we<=1'b0;
        WB_badv_in<=32'h0000_0000;
        WB_badv_we<=1'b0;
        WB_era_in<=32'h0000_0000;
        WB_era_we<=1'b0;
        WB_era_en<=1'b0;
        WB_eentry_en<=1'b0;
        WB_store_state<=1'b0;
        WB_restore_state<=1'b0;
        WB_flush_csr<=1'b0;
        WB_flush_csr_pc<=32'h0000_0000;
    end
    else if(!stall_dcache&&!stall_div)begin //考虑到前递，stall_dcache应阻塞所有段间寄存器
        //EX->MEM
        //不需要修正分支预测
        if(!EX_br_a) begin 
            MEM_csr_waddr<=EX_csr_waddr;
            MEM_csr_we<=EX_csr_we;
            MEM_csr_wdata<=EX_csr_wdata;
            MEM_ertn<=EX_ertn;
            MEM_ecode_in_a<=EX_ecode_in_aa;
            MEM_ecode_in_b<=EX_ecode_in_bb;
            MEM_ecode_we_a<=EX_ecode_we_aa;
            MEM_ecode_we_b<=EX_ecode_we_bb;
            MEM_badv_in_a<=EX_badv_in_a;
            MEM_badv_in_b<=EX_badv_in_b;
            MEM_badv_we_a<=EX_badv_we_a;
            MEM_badv_we_b<=EX_badv_we_b;
        end
        //需要修正分支预测
        else begin 
            MEM_csr_waddr<=14'h0000;
            MEM_csr_we<=32'h0000_0000;
            MEM_csr_wdata<=32'h0000_0000;
            MEM_ertn<=1'b0;
            MEM_ecode_in_a<=7'h0;
            MEM_ecode_in_b<=7'h0;
            MEM_ecode_we_a<=1'b0;
            MEM_ecode_we_b<=1'b0;
            MEM_badv_in_a<=32'h0000_0000;
            MEM_badv_in_b<=32'h0000_0000;
            MEM_badv_we_a<=1'b0;
            MEM_badv_we_b<=1'b0;
        end 

        //MEM->WB
        WB_csr_waddr<=MEM_csr_waddr;
        WB_csr_we<= |MEM_ecode_in ? 32'h0 : MEM_csr_we; //非中断例外，特别是特权等级错例外时不写入
        WB_csr_wdata<=MEM_csr_wdata;
        WB_ertn<=MEM_ertn;
        WB_ecode_in<=MEM_ecode_in;
        WB_ecode_we<=MEM_ecode_we;
        WB_badv_in<=MEM_badv_in;
        WB_badv_we<=MEM_badv_we;
        WB_era_in<=MEM_era_in;
        WB_era_we<=MEM_era_we;
        WB_era_en<=MEM_era_en;
        WB_eentry_en<=MEM_eentry_en;
        WB_store_state<=MEM_store_state;
        WB_restore_state<=MEM_restore_state;
        WB_flush_csr<=MEM_flush_csr;
        WB_flush_csr_pc<=MEM_flush_csr_pc;
    end
    else begin end
end

endmodule