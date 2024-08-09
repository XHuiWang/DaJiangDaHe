module FU_CSR2(
    //CSR读写
    input           [31: 0]     MEM_csr_we,         //是否写CSR
    //CSR控制
    input                       MEM_ertn,           //是否从例外返回
    input                       MEM_interrupt,      //中断信号，CSR直接发给MEM段
    input                       MEM_interrupt_buf,  //若MEM_a_enable MEM_b_enable均为0，MEM_interrupt在MEM段保留一拍

    input                       MEM_a_enable,       //A指令是否有效
    input                       MEM_b_enable,       //B指令是否有效
    input           [31: 0]     MEM_pc_a,           //A指令的PC值
    input           [31: 0]     MEM_pc_b,           //B指令的PC值
    input           [ 6: 0]     MEM_ecode_in_a,     //A指令的异常码
    input           [ 6: 0]     MEM_ecode_in_b,     //B指令的异常码
    input                       MEM_ecode_we_a,     //A指令是否产生例外
    input                       MEM_ecode_we_b,     //B指令是否产生例外
    input           [31: 0]     MEM_badv_in_a,      //取值地址错记录pc，地址非对齐记录地址
    input           [31: 0]     MEM_badv_in_b,      //B指令 EX段检测访存地址非对齐
    input                       MEM_badv_we_a,      //A是否发生取指地址错
    input                       MEM_badv_we_b,      //B是否发生取指地址错/地址非对齐

    output  wire    [ 6: 0]     MEM_ecode_in,       //例外码
    output  wire                MEM_ecode_we,       //是否产生例外    
    output  wire    [31: 0]     MEM_badv_in,        //AB取值地址错记录pc，地址非对齐记录地址
    output  wire                MEM_badv_we,        //AB是否发生取指地址错/地址非对齐
    output  wire    [31: 0]     MEM_era_in,         //产生例外指令的PC
    output  wire                MEM_era_we,         //是否产生例外
    output  wire                MEM_era_en,         //ertn 是否使用era从例外处理返回
    output  wire                MEM_eentry_en,      //例外 是否使用eentry进入例外处理
    output  wire                MEM_store_state,    //是否触发例外，保存当前plv和ie
    output  wire                MEM_restore_state,  //是否从例外恢复，恢复plv和ie
    
    output  wire                MEM_flush_csr,      //因任何原因写CSR时，清空流水线
    output  wire    [31: 0]     MEM_flush_csr_pc    //CSRWR/CSRXCHG，清空流水线时pc跳转的位置
);
logic   interrupt;  //本次MEM段有尚未处理的中断且可以处理  
        //尚未处理的中断：包括新发来的MEM_interrupt和此前未处理的MEM_interrupt_buf
assign interrupt = ( MEM_a_enable | MEM_b_enable ) & (MEM_interrupt | MEM_interrupt_buf);
        //能触发例外的指令在此前已保证是enable的，中断不会因为未附着而落后于例外
assign MEM_ecode_in = interrupt ? 7'h0 : 
    ( MEM_ecode_we_a ? MEM_ecode_in_a : MEM_ecode_in_b );
assign MEM_ecode_we = interrupt | MEM_ecode_we_a | MEM_ecode_we_b;
assign MEM_badv_in  = MEM_badv_we_a ? MEM_badv_in_a : MEM_badv_in_b;
assign MEM_badv_we  = MEM_badv_we_a | MEM_badv_we_b;
assign MEM_era_in   = interrupt ? (MEM_a_enable ? MEM_pc_a : MEM_pc_b ) 
    : (MEM_ecode_we_a ? MEM_pc_a : MEM_pc_b);   //中断优先于例外，A优先于B
assign MEM_era_we   = interrupt | MEM_ecode_we_a | MEM_ecode_we_b;
assign MEM_era_en   = MEM_ertn;
assign MEM_eentry_en= interrupt | MEM_ecode_we_a | MEM_ecode_we_b;
assign MEM_store_state = interrupt | MEM_ecode_we_a | MEM_ecode_we_b;
assign MEM_restore_state = MEM_ertn;

assign MEM_flush_csr = MEM_ecode_we | (|MEM_csr_we) | MEM_ertn; //触发例外/写CSR/例外返回
assign MEM_flush_csr_pc = MEM_pc_b+32'h4; //CSRWR/CSRXCHG，清空流水线时pc跳转的位置，单发B指令
endmodule