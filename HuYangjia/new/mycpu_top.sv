`timescale 1ns / 1ps
// `include "Public_Info.sv"
import Public_Info::*;
module mycpu_top(
    input           aclk,
    input           aresetn,
    input    [ 7:0] ext_int, 
    //AXI interface 
    //read reqest
    output logic   [ 3:0] arid,
    output logic   [31:0] araddr,
    output logic   [ 7:0] arlen,
    output logic   [ 2:0] arsize,
    output logic   [ 1:0] arburst,
    output logic   [ 1:0] arlock,
    output logic   [ 3:0] arcache,
    output logic   [ 2:0] arprot,
    output logic          arvalid,
    input                 arready,
    //read back
    input    [ 3:0] rid,
    input    [31:0] rdata,
    input    [ 1:0] rresp,
    input           rlast,
    input           rvalid,
    output logic    rready,
    //write request
    output logic   [ 3:0] awid,
    output logic   [31:0] awaddr,
    output logic   [ 7:0] awlen,
    output logic   [ 2:0] awsize,
    output logic   [ 1:0] awburst,
    output logic   [ 1:0] awlock,
    output logic   [ 3:0] awcache,
    output logic   [ 2:0] awprot,
    output logic          awvalid,
    input                 awready,
    //write data
    output logic   [ 3:0] wid,
    output logic   [31:0] wdata,
    output logic   [ 3:0] wstrb,
    output logic          wlast,
    output logic          wvalid,
    input                 wready,
    //write back
    input    [ 3:0] bid,
    input    [ 1:0] bresp,
    input           bvalid,
    output logic    bready,


    //debug interface
    output logic [31: 0] debug0_wb_pc,
    output logic [ 3: 0] debug0_wb_rf_we,
    output logic [ 4: 0] debug0_wb_rf_wnum,
    output logic [31: 0] debug0_wb_rf_wdata,

    output logic [31: 0] debug1_wb_pc,
    output logic [ 3: 0] debug1_wb_rf_we,
    output logic [ 4: 0] debug1_wb_rf_wnum,
    output logic [31: 0] debug1_wb_rf_wdata

);
    wire clk, rstn;
    assign clk = aclk;
    assign rstn = aresetn;

    // logic [31: 0] debug0_wb_pc;
    // logic [ 3: 0] debug0_wb_rf_we;
    // logic [ 4: 0] debug0_wb_rf_wnum;
    // logic [31: 0] debug0_wb_rf_wdata;

    // logic [31: 0] debug1_wb_pc;
    // logic [ 3: 0] debug1_wb_rf_we;
    // logic [ 4: 0] debug1_wb_rf_wnum;
    // logic [31: 0] debug1_wb_rf_wdata;
    // assign debug_wb_pc = debug0_wb_pc;
    // assign debug_wb_rf_we = debug0_wb_rf_we;
    // assign debug_wb_rf_wnum = debug0_wb_rf_wnum;
    // assign debug_wb_rf_wdata = debug0_wb_rf_wdata;
    
    
    PC_set PC_set1_front;
    PC_set PC_set2_front;
    PC_set PC_set1_back ;
    PC_set PC_set2_back ;
    PC_set set_final_1 ;
    PC_set set_final_2 ;


    logic [31: 0] pc_predict;
    logic [31: 0] pc_BR;
    logic [31: 0] pc_IF1;
    logic [ 0: 0] is_valid;
    logic [ 7: 0] IF1_ecode;
    logic [31: 0] p_addr_IF1;
    logic [ 0: 0] uncache_i;
    logic [ 0: 0] flush_cacop;
    logic [31: 0] addrs_cacop;
  
    // ICache
    logic [ 0: 0] ICache_valid;
    logic [ 0: 0] data_valid;
    // logic         i_rvalid;
    // logic [31: 0] i_araddr;
    // logic         i_rready;
    // logic         i_rlast;
    // logic [31: 0] i_rdata;
    // logic         rready_icache;
    // logic         i_arvalid;
    // logic         i_arready;
    // logic [ 7: 0] i_arlen;



    // BR_Pre 分支预测
    logic [29: 0] pred0_br_target;
    logic [ 1: 0] pred0_br_type;
    logic [29: 0] pred1_br_target;
    logic [ 1: 0] pred1_br_type;
    logic [31: 0] branch_pc;
    logic [ 1: 0] branch_br_type;
    logic [31: 0] branch_br_target;
    logic [ 0: 0] branch_jump;
    logic [29:0]  predict_br_target;



    // IF1_IF2
    logic [ 1: 0] IF1_IF2_valid;
    logic [33: 0] IF2_brtype_pcpre_1;
    logic [33: 0] IF2_brtype_pcpre_2;
    logic [ 1: 0] i_is_valid;
    logic [ 7: 0] IF2_ecode_1;
    logic [ 7: 0] IF2_ecode_2;
    logic [31: 0] IF2_PC1_plus_4;
    logic [31: 0] IF2_PC2_plus_4;

    // 预译码
    logic [33: 0] o_brtype_pcpre_1;
    logic [33: 0] o_brtype_pcpre_2;
    logic [ 1: 0] predecoder_valid;
    logic [ 0: 0] BR_predecoder;
    logic [31: 0] PC_predecoder;
    logic [33: 0] type_pcpre_1;
    logic [33: 0] type_pcpre_2;

    // IF2_ID1
    logic [31: 0] ID1_PC1;
    logic [31: 0] ID1_PC2;
    logic [31: 0] ID1_PC1_plus_4;
    logic [31: 0] ID1_PC2_plus_4;
    logic [31: 0] ID1_IR1;
    logic [31: 0] ID1_IR2;
    logic [33: 0] ID1_brtype_pcpre_1;
    logic [33: 0] ID1_brtype_pcpre_2;
    logic [ 1: 0] ID1_is_valid;
    logic [ 1: 0] fact_valid;
    logic [ 7: 0] ID1_ecode_1;
    logic [ 7: 0] ID1_ecode_2;
    logic [ 0: 0] o_signFor_ADEF_ALE;

    // ID1_ID2
    logic [31: 0] i_PC1;
    logic [31: 0] i_IR1;
    logic [31: 0] i_PC2;
    logic [31: 0] i_IR2;
    logic [31: 0] o_PC1;
    logic [31: 0] o_IR1;
    logic [31: 0] o_PC2;
    logic [31: 0] o_IR2;
    logic [ 1: 0] o_is_valid;
    logic [ 0: 0] o_is_full;
    logic [ 0: 0] ID_status;
    logic [ 7: 0] ID2_ecode_1;
    logic [ 7: 0] ID2_ecode_2;


    // RegFile中的信号
    logic [ 4: 0] raddr_a1;
    logic [ 4: 0] raddr_a2;
    logic [ 4: 0] raddr_b1;
    logic [ 4: 0] raddr_b2;
    logic [31: 0] rdata_a1;
    logic [31: 0] rdata_a2;
    logic [31: 0] rdata_b1;
    logic [31: 0] rdata_b2;
    logic [ 4: 0] waddr_a;
    logic [ 4: 0] waddr_b;
    logic [31: 0] wdata_a;
    logic [31: 0] wdata_b;

    // CSR中的信号
    logic [ 0: 0] stable_clk;
    logic [ 1: 0] plv;
    logic [ 5: 0] ecode;
    logic [13: 0] csr_raddr_1;
    logic [13: 0] csr_raddr_2;
    logic [31: 0] csr_rdata_1;
    logic [31: 0] csr_rdata_2;
    logic [31: 0] era_out;
    logic [31: 0] eentry;
    logic [31: 0] csr_tid;
    logic [ 0: 0] has_interrupt_cpu;
    logic [ 0: 0] has_interrupt_idle;
    logic [ 1: 0] translate_mode;
    logic [ 1: 0] direct_i_mat;
    logic [ 1: 0] direct_d_mat;
    logic [ 0: 0] dmw0_plv0;
    logic [ 0: 0] dmw0_plv3;
    logic [ 0: 0] dmw1_plv0;
    logic [ 0: 0] dmw1_plv3;
    logic [ 1: 0] dmw0_mat;
    logic [ 1: 0] dmw1_mat;
    logic [ 2: 0] dmw0_vseg;
    logic [ 2: 0] dmw0_pseg;
    logic [ 2: 0] dmw1_vseg;
    logic [ 2: 0] dmw1_pseg;
    logic [ 7: 0] hardware_int; // 外界输入，现在赋值0
    logic [ 0: 0] MEM_interrupt;
    assign hardware_int = 8'b0;
    assign stable_clk = clk;
    assign MEM_interrupt = has_interrupt_cpu;


    logic [ 1: 0] i_usingNUM;

    // Issue Buffer
    logic [ 1: 0] o_is_valid_2;
    logic [ 0: 0] o_is_full_2;

    // Issue_EXE
    logic [ 0: 0] EX_a_enable;
    logic [ 0: 0] EX_b_enable;
    logic [31: 0] EX_pc_a;
    logic [31: 0] EX_pc_b;
    logic [ 4: 0] EX_rf_raddr_a1;
    logic [ 4: 0] EX_rf_raddr_a2;
    logic [ 4: 0] EX_rf_raddr_b1;
    logic [ 4: 0] EX_rf_raddr_b2;
    logic [31: 0] EX_rf_rdata_a1;
    logic [31: 0] EX_rf_rdata_a2;
    logic [31: 0] EX_rf_rdata_b1;
    logic [31: 0] EX_rf_rdata_b2;
    logic [31: 0] EX_imm_a;
    logic [31: 0] EX_imm_b;
    logic [ 3: 0] EX_alu_src_sel_a1;
    logic [ 3: 0] EX_alu_src_sel_a2;
    logic [ 3: 0] EX_alu_src_sel_b1;
    logic [ 3: 0] EX_alu_src_sel_b2;
    logic [11: 0] EX_alu_op_a;
    logic [11: 0] EX_alu_op_b;
    logic [ 9: 0] EX_br_type_a;
    logic [ 9: 0] EX_br_type_b;
    logic [ 0: 0] EX_br_pd_a;
    logic [ 0: 0] EX_br_pd_b;
    logic [ 0: 0] EX_rf_we_a;
    logic [ 0: 0] EX_rf_we_b;
    logic [ 4: 0] EX_rf_waddr_a;
    logic [ 4: 0] EX_rf_waddr_b;
    logic [ 0: 0] EX_mem_we_a;
    logic [ 0: 0] EX_mem_we_b;
    logic [ 2: 0] EX_mem_type_a;
    logic [ 2: 0] EX_mem_type_b;
    logic [ 8: 0] EX_mux_select;
    logic [ 0: 0] EX_signed;
    logic [ 0: 0] EX_div_en;
    logic [ 0: 0] EX_mul_en;
    logic [ 1: 0] type_predict_a;
    logic [ 1: 0] type_predict_b;
    logic [31: 0] EX_PC_pre_a;
    logic [31: 0] EX_PC_pre_b;

    // add for csr
    logic [ 2: 0] EX_csr_type;
    logic [31: 0] EX_csr_rdata;
    logic [31: 0] EX_tid;
    logic [13: 0] EX_csr_waddr;
    logic [ 0: 0] EX_ertn;    
    logic [ 6: 0] EX_ecode_in_a;
    logic [ 6: 0] EX_ecode_in_b;
    logic [ 0: 0] EX_ecode_we_a;
    logic [ 0: 0] EX_ecode_we_b;


    // AXI
    assign wid = awid;
    assign arlock[1] = 0;
    assign awlock[1] = 0;
    wire [3:0]  i_axi_awid;         wire [3:0]  d_axi_awid;
    wire [31:0] i_axi_awaddr;       wire [31:0] d_axi_awaddr;
    wire [7:0]  i_axi_awlen;        wire [7:0]  d_axi_awlen;
    wire [2:0]  i_axi_awsize;       wire [2:0]  d_axi_awsize;
    wire [1:0]  i_axi_awburst;      wire [1:0]  d_axi_awburst;
    wire [0:0]  i_axi_awlock;       wire [0:0]  d_axi_awlock;
    wire [3:0]  i_axi_awcache;      wire [3:0]  d_axi_awcache;
    wire [2:0]  i_axi_awprot;       wire [2:0]  d_axi_awprot;
    // wire [3:0]  i_axi_awqos;        wire [3:0]  d_axi_awqos;
    // wire [3:0]  i_axi_awregion;     wire [3:0]  d_axi_awregion;
    wire [0:0]  i_axi_awvalid;      wire [0:0]  d_axi_awvalid;
    wire [0:0]  i_axi_awready;      wire [0:0]  d_axi_awready;
    wire [31:0] i_axi_wdata;        wire [31:0] d_axi_wdata;
    wire [3:0]  i_axi_wstrb;        wire [3:0]  d_axi_wstrb;
    wire [0:0]  i_axi_wlast;        wire [0:0]  d_axi_wlast;
    wire [0:0]  i_axi_wvalid;       wire [0:0]  d_axi_wvalid;
    wire [0:0]  i_axi_wready;       wire [0:0]  d_axi_wready;
    wire [3:0]  i_axi_bid;          wire [3:0]  d_axi_bid;
    wire [1:0]  i_axi_bresp;        wire [1:0]  d_axi_bresp;
    wire [0:0]  i_axi_bvalid;       wire [0:0]  d_axi_bvalid;
    wire [0:0]  i_axi_bready;       wire [0:0]  d_axi_bready;
    wire [3:0]  i_axi_arid;         wire [3:0]  d_axi_arid;
    wire [31:0] i_axi_araddr;       wire [31:0] d_axi_araddr;
    wire [7:0]  i_axi_arlen;        wire [7:0]  d_axi_arlen;
    wire [2:0]  i_axi_arsize;       wire [2:0]  d_axi_arsize;
    wire [1:0]  i_axi_arburst;      wire [1:0]  d_axi_arburst;
    wire [0:0]  i_axi_arlock;       wire [0:0]  d_axi_arlock;
    wire [3:0]  i_axi_arcache;      wire [3:0]  d_axi_arcache;
    wire [2:0]  i_axi_arprot;       wire [2:0]  d_axi_arprot;
    // wire [3:0]  i_axi_arqos;        wire [3:0]  d_axi_arqos;
    // wire [3:0]  i_axi_arregion;     wire [3:0]  d_axi_arregion;
    wire [0:0]  i_axi_arvalid;      wire [0:0]  d_axi_arvalid;
    wire [0:0]  i_axi_arready;      wire [0:0]  d_axi_arready;
    wire [3:0]  i_axi_rid;          wire [3:0]  d_axi_rid;
    wire [31:0] i_axi_rdata;        wire [31:0] d_axi_rdata;
    wire [1:0]  i_axi_rresp;        wire [1:0]  d_axi_rresp;
    wire [0:0]  i_axi_rlast;        wire [0:0]  d_axi_rlast;
    wire [0:0]  i_axi_rvalid;       wire [0:0]  d_axi_rvalid;
    wire [0:0]  i_axi_rready;       wire [0:0]  d_axi_rready;


    assign i_axi_awid = 0;
    assign i_axi_awaddr = 0;
    assign i_axi_awlen = 0;
    assign i_axi_awsize = 0;
    assign i_axi_awburst = 2'b01;
    assign i_axi_awlock = 0;
    assign i_axi_awcache = 0;
    assign i_axi_awprot = 0;
    assign i_axi_awvalid = 0;
    assign i_axi_wdata = 0;
    assign i_axi_wstrb = 0;
    assign i_axi_wlast = 0;
    assign i_axi_wvalid = 0;
    // assign i_axi_bid = 0;
    assign i_axi_bready = 0;
    assign i_axi_arid = 0;
    assign i_axi_arburst = 2'b01;
    assign i_axi_arsize = 3'b010;
    assign i_axi_arlock = 0;
    assign i_axi_arcache = 0;
    assign i_axi_arprot = 3'b100;

    assign d_axi_awid = 1;
    assign d_axi_awburst = 2'b01;
    assign d_axi_awlock = 0;
    assign d_axi_awcache = 0;
    assign d_axi_awprot = 0;
    // assign d_axi_bid = 1;
    assign d_axi_arid = 1;
    assign d_axi_arburst = 2'b01;
    assign d_axi_arlock = 0;
    assign d_axi_arcache = 0;
    assign d_axi_arprot = 0;


    reg  [31:0] rsta_busy;
    reg  [31:0] rstb_busy;
  
  

        
    // output from EXE
    logic [ 0: 0] WB_rf_we_a;
    logic [ 0: 0] WB_rf_we_b;
    logic [ 4: 0] WB_rf_waddr_a;
    logic [ 4: 0] WB_rf_waddr_b;
    logic [31: 0] WB_rf_wdata_a;
    logic [31: 0] WB_rf_wdata_b;
    logic [ 0: 0] MEM_br;
    logic [31: 0] MEM_pc_br;
    logic [ 0: 0] EX_mem_rvalid;
    logic [ 0: 0] EX_mem_wvalid;
    logic [ 0: 0] MEM_mem_rready;
    logic [ 0: 0] MEM_mem_wready;
    logic [31: 0] EX_mem_addr;
    logic [ 2: 0] EX_mem_type;
    logic [31: 0] EX_mem_wdata;
    logic [31: 0] MEM_mem_rdata;
    logic [ 0: 0] EX_UnCache;
    logic [31: 0] p_addr_EX;
    logic [ 0: 0] uncache_d;
    // add for csr
    logic [13: 0]     WB_csr_waddr;       //CSR写地址 MEM段生效
    logic [31: 0]     WB_csr_we;          //CSR写使能 MEM段生效 按位
    logic [31: 0]     WB_csr_wdata;       //CSR写数据 MEM段生效
    logic [ 6: 0]     WB_ecode_in;        //例外码 WB段写入
    logic [ 0: 0]     WB_ecode_we;        //例外码写使能/是否产生例外
    logic [31: 0]     WB_badv_in;         //取指地址错记录PC，地址非对齐记录地址
    logic [ 0: 0]     WB_badv_we;         //出错虚地址写使能
    logic [31: 0]     WB_era_in;          //产生例外的指令PC
    logic [ 0: 0]     WB_era_we;          //产生例外的指令PC写使能
    logic [ 0: 0]     WB_era_en;          //发给PC更新器，下个边沿跳转到CSR.era
    logic [ 0: 0]     WB_eentry_en;       //发给PC更新器，下个边沿跳转到CSR.eentry
    logic [ 0: 0]     WB_store_state;     //触发例外，pplv=plv；pie=ie
    logic [ 0: 0]     WB_restore_state;   //从例外恢复，plv=pplv；ie=pie
    logic [ 0: 0]     WB_flush_csr;       //因任何原因写CSR时，清空流水线
    logic [31: 0]     WB_flush_csr_pc;    //CSRWR/CSRXCHG，清空流水线时pc跳转的位置




    // for cacop
    logic [ 0: 0]     EX_cacop_en;     
    logic [ 4: 0]     EX_cacop_code;   
    logic [ 0: 0]     EX_cacop_finish_i;
    logic [ 0: 0]     EX_cacop_finish_d; 
    logic [ 0: 0]     EX_cacop_en_i;   
    logic [ 0: 0]     EX_cacop_en_d;   
    logic [ 1: 0]     EX_cacop_code_i; 
    logic [ 1: 0]     EX_cacop_code_d;
    logic [31: 0]     EX_cacop_va_i;   

    
    // stall && flush
    logic [ 0: 0] stall_DCache; // 由于Dcache缺失带来的逻辑的stall信号，只作用于issue Buffer
    // logic [ 0: 0] stall_dcache; // 由于Dcache缺失带来的真正的stall信号
    logic [ 0: 0] stall_full_issue; // 由于issue Buffer满带来的stall信号，只作用于Instruction Buffer
    logic [ 0: 0] stall_full_instr; // 由于Instruction Buffer满带来的stall信号，作用于IF1
    logic [ 0: 0] stall_ICache; // 由于Icache缺失带来的逻辑的stall信号，作用于IF1的取值模块和IF1_IF2段间寄存器
    logic [ 0: 0] stall_iCache; // 由于Icache缺失带来的真正的stall信号
    logic [ 0: 0] stall_ex;// 由于除法器和乘法器忙带来的stall信号 现在增加了cacop的stall
    logic [ 0: 0] flush_BR; // 由于分支预测错误带来的flush信号，作用于两个Buffer和IF1_IF2段间寄存器，作用于ICache(在Miss则停止操作)
    logic [ 0: 0] flush_of_ALL; // 由于任何原因带来的flush信号，作用于所有段间寄存器


    // temp测试
    assign stall_ICache = ~stall_iCache;
    assign stall_DCache = ~(MEM_mem_rready | MEM_mem_wready);
    assign flush_BR = MEM_br;
    assign stall_full_issue = o_is_full_2;
    assign stall_full_instr = o_is_full;
    assign flush_of_ALL = MEM_br | WB_era_en | WB_eentry_en | WB_flush_csr | flush_cacop;
    // cacop
    assign flush_cacop = EX_cacop_finish_i | EX_cacop_finish_d;
    assign addrs_cacop = EX_pc_b + 4;
    
  
    `ifdef DIFFTEST_EN
    // signs for difftest
    logic [31: 0] regs[31: 0];

    `endif

    
    // assign pc_predict = ~(|pred0_br_type) ? {pred1_br_target, 2'b00} : {pred0_br_target, 2'b00};
    assign pc_predict = ~(is_valid) ? pc_IF1 :{predict_br_target,2'b00};
    IF1  IF1_inst (
        .clk(clk),
        .rstn(rstn),
        .pc_predict(pc_predict),
        .pc_BR(MEM_pc_br),
        .MEM_br(MEM_br),
        .plv(plv),
        .BR_predecoder(BR_predecoder),
        .PC_predecoder(PC_predecoder),
        .PC_era(era_out),
        .WB_era_en(WB_era_en),
        .PC_eentry(eentry),
        .WB_eentry_en(WB_eentry_en),
        .WB_flush_csr_pc(WB_flush_csr_pc),
        .WB_flush_csr(WB_flush_csr),
        .stall_ICache(stall_ICache),
        .stall_full_instr(stall_full_instr),
        .flush_cacop(flush_cacop),
        .addrs_cacop(addrs_cacop),
        .pc_IF1(pc_IF1),
        .ecode(IF1_ecode),
        .is_valid(is_valid)
    );
    
    br_pre_top  br_pre_top_inst (
        .clk(clk),
        .rstn(rstn),
        .pc(pc_IF1[31: 2]),
        .pred0_br_target(pred0_br_target),
        .pred0_br_type(pred0_br_type),
        .pred1_br_target(pred1_br_target),
        .pred1_br_type(pred1_br_type),
        .predict_br_target(predict_br_target),

        .branch_pc(branch_pc[31: 2]),
        .branch_br_type(branch_br_type),
        .branch_br_target(branch_br_target[31: 2]),
        .branch_jump(branch_jump)
    );

    IF1_IF2  IF1_IF2_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC1(pc_IF1),
        .i_PC2(pc_IF1+4),
        .i_brtype_pcpre_1({pred0_br_type, pred0_br_target, 2'b00}),
        .i_brtype_pcpre_2({pred1_br_type, pred1_br_target, 2'b00}), 
        .i_ecode(IF1_ecode),
        .flush_BR(flush_of_ALL),
        .i_is_valid(is_valid),
        .stall_ICache(stall_ICache),
        .stall_full_instr(stall_full_instr),
        .BR_predecoder(BR_predecoder),
        .o_PC1(i_PC1),
        .o_PC2(i_PC2),
        .o_brtype_pcpre_1(IF2_brtype_pcpre_1),
        .o_brtype_pcpre_2(IF2_brtype_pcpre_2),
        .o_ecode_1(IF2_ecode_1),
        .o_ecode_2(IF2_ecode_2),
        .o_signFor_ADEF_ALE(o_signFor_ADEF_ALE),
        .o_is_valid(IF1_IF2_valid)
    );

    inst_mmu_lite  inst_mmu_lite_inst (
        .addr(EX_cacop_en_i == 1'b1 ? EX_cacop_va_i : pc_IF1 ),
        .plv(plv),
        .translate_mode(translate_mode),
        .direct_i_mat(direct_i_mat),
        .dmw0_plv0(dmw0_plv0),
        .dmw0_plv3(dmw0_plv3),
        .dmw0_mat(dmw0_mat),
        .dmw0_vseg(dmw0_vseg),
        .dmw0_pseg(dmw0_pseg),
        .dmw1_plv0(dmw1_plv0),
        .dmw1_plv3(dmw1_plv3),
        .dmw1_mat(dmw1_mat),
        .dmw1_vseg(dmw1_vseg),
        .dmw1_pseg(dmw1_pseg),
        .paddr(p_addr_IF1),
        .uncache(uncache_i)
    );

    Icache  Icache_inst (
        .clk(clk),
        .rstn(rstn),
        .rvalid(is_valid & ~(IF1_ecode[7])),
        .pc(p_addr_IF1),
        .Is_flush(flush_of_ALL | BR_predecoder),
        .uncache(uncache_i),
        .cacop_en(EX_cacop_en_i), //
        .cacop_code(EX_cacop_code_i),
        .cacop_va(EX_cacop_va_i),
        .cacop_pa(p_addr_IF1),
        .cacop_finish(EX_cacop_finish_i), //
        .rready(stall_iCache), // 1-> normal, 0-> stall
        .rdata({i_IR2, i_IR1}),
        .flag_valid(ICache_valid),
        .data_valid(data_valid),
        .i_rready (i_axi_rready),
        .i_rvalid (i_axi_rvalid),
        .i_rdata (i_axi_rdata),
        .i_rlast (i_axi_rlast),
        .i_arvalid (i_axi_arvalid),
        .i_araddr (i_axi_araddr),
        .i_arready (i_axi_arready),
        .i_arlen (i_axi_arlen)
      );
    logic [ 0: 0] data_reg;
    logic [31: 0] IR1_reg;
    logic [31: 0] IR2_reg;
    logic [ 0: 0] ICache_valid_reg;
    logic [ 0: 0] sign; // 是否第一次遇到stall 
    always @(posedge clk) begin
        if(flush_of_ALL) begin
            data_reg <= 1'b0;
            IR1_reg <= 1'b0;
            IR2_reg <= 1'b0;
            ICache_valid_reg <= 1'b0;
        end 
        else if(stall_full_instr | stall_ICache)  begin
            if(sign == 1'b1) begin
                data_reg <= data_reg;
                IR1_reg <= IR1_reg;
                IR2_reg <= IR2_reg;
                ICache_valid_reg <= ICache_valid_reg;
                sign <= sign;
            end
            else begin
                data_reg <= data_valid;
                IR1_reg <= i_IR1;
                IR2_reg <= i_IR2;
                ICache_valid_reg <= ICache_valid;
                sign <= 1'b1;
            end
        end
        else begin
            data_reg <= 0;
            IR1_reg <= 0;
            IR2_reg <= 0;
            ICache_valid_reg <= 0;
            sign <= 0;
        end
    end

    wire [31: 0] IR1_fac ;
    assign IR1_fac = (data_reg & ~data_valid) ? IR1_reg : i_IR1;
    wire [31: 0] IR2_fac ; 
    assign IR2_fac = (data_reg & ~data_valid) ? IR2_reg : i_IR2;
    wire [ 0: 0] ICache_valid_fac ;
    assign ICache_valid_fac = (data_reg & ~data_valid) ? ICache_valid_reg : ICache_valid;

    
    assign i_is_valid = IF1_IF2_valid & {1'b1, ICache_valid_fac} & {2{data_valid | data_reg | o_signFor_ADEF_ALE}};
    IF2_ID1  IF2_ID1_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC1(i_PC1),
        .i_IR1(IR1_fac),
        .i_brtype_pcpre_1(IF2_brtype_pcpre_1),
        .i_ecode_1(IF2_ecode_1),
        .i_PC2(i_PC2),
        .i_IR2(IR2_fac),
        .i_brtype_pcpre_2(IF2_brtype_pcpre_2),
        .i_ecode_2(IF2_ecode_2),
        .i_is_valid(i_is_valid),
        .flush_BR(flush_of_ALL),
        .stall_full_instr(stall_full_instr),
        .o_PC1(ID1_PC1),
        .o_PC1_plus_4(ID1_PC1_plus_4),
        .o_IR1(ID1_IR1),
        .o_brtype_pcpre_1(ID1_brtype_pcpre_1),
        .o_ecode_1(ID1_ecode_1),
        .o_PC2(ID1_PC2),
        .o_PC2_plus_4(ID1_PC2_plus_4),
        .o_IR2(ID1_IR2),
        .o_brtype_pcpre_2(ID1_brtype_pcpre_2),
        .o_ecode_2(ID1_ecode_2),
        .o_is_valid(ID1_is_valid)
    );

    
    IF2_predecoder_TOP  IF2_predecoder_TOP_inst (
        .IR1(ID1_IR1),
        .IR2(ID1_IR2),
        .PC1(ID1_PC1),
        .PC2(ID1_PC2),
        .PC1_plus_4(ID1_PC1_plus_4),
        .PC2_plus_4(ID1_PC2_plus_4),
        .brtype_pcpre1(ID1_brtype_pcpre_1),
        .brtype_pcpre2(ID1_brtype_pcpre_2),
        .i_is_valid(ID1_is_valid),
        .o_is_valid(predecoder_valid),
        .PC_fact(PC_predecoder),
        .predecoder_BR(BR_predecoder),
        .type_pcpre_1(type_pcpre_1),
        .type_pcpre_2(type_pcpre_2)
    );

    assign fact_valid = ID1_is_valid & predecoder_valid;   

    ID1_ID2  ID1_ID2_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC1(ID1_PC1),
        .i_IR1(ID1_IR1),
        .i_brtype_pcpre_1(type_pcpre_1),
        .i_ecode_1(ID1_ecode_1),
        .i_ecode_2(ID1_ecode_2),
        .i_PC2(ID1_PC2),
        .i_IR2(ID1_IR2),
        .i_brtype_pcpre_2(type_pcpre_2),
        .i_is_valid(fact_valid),
        .flush_BR(flush_of_ALL),
        .stall_full_issue(stall_full_issue),
        .o_PC1(o_PC1),
        .o_IR1(o_IR1),
        .o_brtype_pcpre_1(o_brtype_pcpre_1),
        .o_ecode_1(ID2_ecode_1),
        .o_PC2(o_PC2),
        .o_IR2(o_IR2),
        .o_brtype_pcpre_2(o_brtype_pcpre_2),
        .o_ecode_2(ID2_ecode_2),
        .o_is_valid(o_is_valid),
        .o_is_full(o_is_full),
        .ID_status(ID_status)
    );

    ID_Decode_edi_2  ID_Decode_edi_2_inst_1 (
        .IF_IR(o_IR1),
        .PC(o_PC1),
        .brtype_pcpre(o_brtype_pcpre_1),
        .ecode(ID2_ecode_1),
        .plv(plv),
        .ID_status(ID_status),
        .data_valid(o_is_valid[1]),
        .PC_set(PC_set1_front)
    );
    ID_Decode_edi_2  ID_Decode_edi_2_inst_2 (
        .IF_IR(o_IR2),
        .PC(o_PC2),
        .brtype_pcpre(o_brtype_pcpre_2),
        .ecode(ID2_ecode_2),
        .plv(plv),
        .ID_status(ID_status),
        .data_valid(o_is_valid[0]),
        .PC_set(PC_set2_front)
    );

    ID_REG  ID_REG_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC_set1(PC_set1_front),
        .i_PC_set2(PC_set2_front),
        .i_usingNUM(i_usingNUM),
        .flush_BR(flush_of_ALL),
        .stall_DCache(stall_DCache),
        .stall_EX(stall_ex),
        .o_PC_set1(PC_set1_back),
        .o_PC_set2(PC_set2_back),
        .a_rf_raddr1(raddr_a1),
        .a_rf_raddr2(raddr_a2),
        .b_rf_raddr1(raddr_b1),
        .b_rf_raddr2(raddr_b2),
        .csr_raddr_1(csr_raddr_1),
        .csr_raddr_2(csr_raddr_2),
        .o_is_valid(o_is_valid_2),
        .o_is_full(o_is_full_2)
    );
    
    

    RF # (
        .ADDR_WIDTH(5),
        .DATA_WIDTH(32)
    )
    RF_inst (
        .clk(clk),
        .raddr_a1(raddr_a1),
        .raddr_a2(raddr_a2),
        .raddr_b1(raddr_b1),
        .raddr_b2(raddr_b2),
        .rdata_a1(rdata_a1),
        .rdata_a2(rdata_a2),
        .rdata_b1(rdata_b1),
        .rdata_b2(rdata_b2),
        .waddr_a(WB_rf_waddr_a),
        .waddr_b(WB_rf_waddr_b),
        .wdata_a(WB_rf_wdata_a),
        .wdata_b(WB_rf_wdata_b),
        .we_a(WB_rf_we_a),
        .we_b(WB_rf_we_b)
        `ifdef DIFFTEST_EN
        ,.regs(regs)
        `endif
    );

   
    CSR  CSR_inst (
        .clk(clk),
        .stable_clk(stable_clk),
        .rstn(rstn),
        .software_we((plv == 2'b00)),
        .raddr_a(csr_raddr_1),
        .raddr_b(csr_raddr_2),
        .rdata_a(csr_rdata_1),
        .rdata_b(csr_rdata_2),
        .waddr(WB_csr_waddr),
        .we(WB_csr_we),
        .wdata(WB_csr_wdata),
        .plv(plv),
        .ecode(ecode), // TODO:
        .store_state(WB_store_state),
        .restore_state(WB_restore_state),
        .ecode_in(WB_ecode_in),
        .ecode_we(WB_ecode_we),
        .era_out(era_out), 
        .era_in(WB_era_in),
        .era_we(WB_era_we),
        .badv_in(WB_badv_in),
        .badv_we(WB_badv_we),
        .eentry(eentry), // TODO: pc for what?
        .has_interrupt_cpu(has_interrupt_cpu), // TODO:
        .has_interrupt_idle(has_interrupt_idle),// TODO:
        .hardware_int(hardware_int), 
        .translate_mode(translate_mode), // 
        .direct_i_mat(direct_i_mat), //
        .direct_d_mat(direct_d_mat), //
        .tid(csr_tid),
        .dmw0_plv0 (dmw0_plv0),
        .dmw0_plv3 (dmw0_plv3),
        .dmw0_mat (dmw0_mat),
        .dmw0_vseg (dmw0_vseg),
        .dmw0_pseg (dmw0_pseg),
        .dmw1_plv0 (dmw1_plv0),
        .dmw1_plv3 (dmw1_plv3),
        .dmw1_mat (dmw1_mat),
        .dmw1_vseg (dmw1_vseg),
        .dmw1_pseg (dmw1_pseg)
    );

    Issue_dispatch  Issue_dispatch_inst (
        .clk(clk),
        .i_set1(PC_set1_back),
        .i_set2(PC_set2_back),
        .i_is_valid(o_is_valid_2),
        .flush(flush_of_ALL),
        .stall(stall_DCache | stall_ex),
        .o_set1(set_final_1),
        .o_set2(set_final_2),
        .o_usingNUM(i_usingNUM)
    );


    Issue_EXE  Issue_EXE_inst (
        .clk(clk),
        .rstn(rstn),
        .i_set1(set_final_1),
        .i_set2(set_final_2),
        .rdata_a1(rdata_a1),
        .rdata_a2(rdata_a2),
        .rdata_b1(rdata_b1),
        .rdata_b2(rdata_b2),
        .csr_rdata_1(csr_rdata_1),
        .csr_rdata_2(csr_rdata_2),
        .csr_tid(csr_tid),
        .flush_BR(flush_of_ALL),
        .stall_DCache(stall_DCache),
        .stall_EX(stall_ex),
        .EX_a_enable(EX_a_enable),
        .EX_b_enable(EX_b_enable),
        .type_predict_a(type_predict_a),
        .type_predict_b(type_predict_b),
        .EX_PC_pre_a(EX_PC_pre_a),
        .EX_PC_pre_b(EX_PC_pre_b),
        .EX_pc_a(EX_pc_a),
        .EX_pc_b(EX_pc_b),
        .EX_rf_raddr_a1(EX_rf_raddr_a1),
        .EX_rf_raddr_a2(EX_rf_raddr_a2),
        .EX_rf_raddr_b1(EX_rf_raddr_b1),
        .EX_rf_raddr_b2(EX_rf_raddr_b2),
        .EX_rf_rdata_a1(EX_rf_rdata_a1),
        .EX_rf_rdata_a2(EX_rf_rdata_a2),
        .EX_rf_rdata_b1(EX_rf_rdata_b1),
        .EX_rf_rdata_b2(EX_rf_rdata_b2),
        .EX_imm_a(EX_imm_a),
        .EX_imm_b(EX_imm_b),
        .EX_alu_src_sel_a1(EX_alu_src_sel_a1),
        .EX_alu_src_sel_a2(EX_alu_src_sel_a2),
        .EX_alu_src_sel_b1(EX_alu_src_sel_b1),
        .EX_alu_src_sel_b2(EX_alu_src_sel_b2),
        .EX_alu_op_a(EX_alu_op_a),
        .EX_alu_op_b(EX_alu_op_b),
        .EX_br_type_a(EX_br_type_a),
        .EX_br_type_b(EX_br_type_b),
        .EX_br_pd_a(EX_br_pd_a),
        .EX_br_pd_b(EX_br_pd_b),
        .EX_rf_we_a(EX_rf_we_a),
        .EX_rf_we_b(EX_rf_we_b),
        .EX_mux_sel(EX_mux_select),
        .EX_rf_waddr_a(EX_rf_waddr_a),
        .EX_rf_waddr_b(EX_rf_waddr_b),
        .EX_mem_we_a(EX_mem_we_a),
        .EX_mem_we_b(EX_mem_we_b),
        .EX_mem_type_a(EX_mem_type_a),
        .EX_mem_type_b(EX_mem_type_b),
        .EX_sign_bit(EX_signed),
        .EX_div_en(EX_div_en),
        .EX_mul_en(EX_mul_en),
        .csr_type(EX_csr_type),
        .csr_raddr(EX_csr_waddr),
        .csr_rdata(EX_csr_rdata),
        .EX_tid(EX_tid),
        .ecode_in_a(EX_ecode_in_a),
        .ecode_we_a(EX_ecode_we_a),
        .ecode_in_b(EX_ecode_in_b),
        .ecode_we_b(EX_ecode_we_b),
        .ertn_check(EX_ertn),
        .code_for_cacop(EX_cacop_code),
        .cacop_en(EX_cacop_en)
    );

    ex_mem_wb  ex_mem_wb_inst (
        .clk(clk),
        .rstn(rstn),
        .EX_a_enable(EX_a_enable),
        .EX_b_enable(EX_b_enable),
        .EX_pc_a(EX_pc_a),
        .EX_pc_b(EX_pc_b),
        .EX_rf_rdata_a1(EX_rf_rdata_a1),
        .EX_rf_rdata_a2(EX_rf_rdata_a2),
        .EX_rf_rdata_b1(EX_rf_rdata_b1),
        .EX_rf_rdata_b2(EX_rf_rdata_b2),
        .EX_imm_a(EX_imm_a),
        .EX_imm_b(EX_imm_b),
        .EX_rf_raddr_a1(EX_rf_raddr_a1),
        .EX_rf_raddr_a2(EX_rf_raddr_a2),
        .EX_rf_raddr_b1(EX_rf_raddr_b1),
        .EX_rf_raddr_b2(EX_rf_raddr_b2),
        .EX_alu_src_sel_a1(EX_alu_src_sel_a1),
        .EX_alu_src_sel_a2(EX_alu_src_sel_a2),
        .EX_alu_src_sel_b1(EX_alu_src_sel_b1),
        .EX_alu_src_sel_b2(EX_alu_src_sel_b2),
        .EX_alu_op_a(EX_alu_op_a),
        .EX_alu_op_b(EX_alu_op_b),
        .EX_signed(EX_signed),
        .EX_div_en(EX_div_en),
        .EX_mul_en(EX_mul_en),
        .stall_ex(stall_ex),
        .EX_rf_we_a(EX_rf_we_a),
        .EX_rf_we_b(EX_rf_we_b),
        .EX_rf_waddr_a(EX_rf_waddr_a),
        .EX_rf_waddr_b(EX_rf_waddr_b),
        .EX_wb_mux_select_b(EX_mux_select),
        .WB_rf_we_a(WB_rf_we_a),
        .WB_rf_we_b(WB_rf_we_b),
        .WB_rf_waddr_a(WB_rf_waddr_a),
        .WB_rf_waddr_b(WB_rf_waddr_b),
        .WB_rf_wdata_a(WB_rf_wdata_a),
        .WB_rf_wdata_b(WB_rf_wdata_b),
        .EX_mem_we_a(EX_mem_we_a),
        .EX_mem_we_b(EX_mem_we_b),
        .EX_mem_type_a(EX_mem_type_a),
        .EX_mem_type_b(EX_mem_type_b),
        .EX_mem_rvalid(EX_mem_rvalid),
        .EX_mem_wvalid(EX_mem_wvalid),
        .MEM_mem_rready(MEM_mem_rready),
        .MEM_mem_wready(MEM_mem_wready),
        .EX_mem_addr(EX_mem_addr),
        .EX_mem_type(EX_mem_type),
        .EX_mem_wdata(EX_mem_wdata),
        .MEM_mem_rdata(MEM_mem_rdata),
        .EX_csr_type(EX_csr_type), // begin
        .EX_csr_rdata(EX_csr_rdata),
        .EX_csr_waddr(EX_csr_waddr),
        .EX_tid(EX_tid),
        .WB_csr_waddr(WB_csr_waddr),
        .WB_csr_we(WB_csr_we),
        .WB_csr_wdata(WB_csr_wdata),
        .EX_ertn(EX_ertn),
        .EX_ecode_in_a(EX_ecode_in_a),
        .EX_ecode_in_b(EX_ecode_in_b),
        .EX_ecode_we_a(EX_ecode_we_a),
        .EX_ecode_we_b(EX_ecode_we_b),
        .MEM_interrupt(MEM_interrupt),
        .WB_ecode_in(WB_ecode_in),
        .WB_ecode_we(WB_ecode_we),
        .WB_badv_in(WB_badv_in),
        .WB_badv_we(WB_badv_we),
        .WB_era_in(WB_era_in),
        .WB_era_we(WB_era_we),
        .WB_era_en(WB_era_en),
        .WB_eentry_en(WB_eentry_en),
        .WB_store_state(WB_store_state),
        .WB_restore_state(WB_restore_state),
        .WB_flush_csr(WB_flush_csr),
        .WB_flush_csr_pc(WB_flush_csr_pc), // end
        .EX_br_type_a(EX_br_type_a),
        .EX_br_type_b(EX_br_type_b),
        .EX_br_pd_a(EX_br_pd_a),
        .EX_br_pd_b(EX_br_pd_b),
        .EX_pc_pd_a(EX_PC_pre_a),
        .EX_pc_pd_b(EX_PC_pre_b),
        .MEM_br(MEM_br),
        .MEM_pc_br(MEM_pc_br),
        .MEM_pc_of_br(branch_pc),
        .EX_pd_type_a(type_predict_a),
        .EX_pd_type_b(type_predict_b),
        .MEM_pd_type(branch_br_type),
        .MEM_br_target(branch_br_target),
        .MEM_br_jump(branch_jump),
        // cacop
        .EX_cacop_en(EX_cacop_en),
        .EX_cacop_code(EX_cacop_code),
        .EX_cacop_finish_i(EX_cacop_finish_i),
        .EX_cacop_finish_d(EX_cacop_finish_d),
        .EX_cacop_en_i(EX_cacop_en_i),
        .EX_cacop_en_d(EX_cacop_en_d),
        .EX_cacop_code_i(EX_cacop_code_i),
        .EX_cacop_code_d(EX_cacop_code_d),
        .EX_cacop_va_i(EX_cacop_va_i),

        .EX_UnCache(EX_UnCache),
        .debug0_wb_pc(debug0_wb_pc),
        .debug0_wb_rf_we(debug0_wb_rf_we),
        .debug0_wb_rf_wnum(debug0_wb_rf_wnum),
        .debug0_wb_rf_wdata(debug0_wb_rf_wdata),
        .debug1_wb_pc(debug1_wb_pc),
        .debug1_wb_rf_we(debug1_wb_rf_we),
        .debug1_wb_rf_wnum(debug1_wb_rf_wnum),
        .debug1_wb_rf_wdata(debug1_wb_rf_wdata)
    );

    data_mmu_lite  data_mmu_lite_inst (
        .addr(EX_mem_addr),
        .plv(plv),
        .translate_mode(translate_mode),
        .direct_d_mat(direct_d_mat),
        .dmw0_plv0(dmw0_plv0),
        .dmw0_plv3(dmw0_plv3),
        .dmw0_mat(dmw0_mat),
        .dmw0_vseg(dmw0_vseg),
        .dmw0_pseg(dmw0_pseg),
        .dmw1_plv0(dmw1_plv0),
        .dmw1_plv3(dmw1_plv3),
        .dmw1_mat(dmw1_mat),
        .dmw1_vseg(dmw1_vseg),
        .dmw1_pseg(dmw1_pseg),
        .paddr(p_addr_EX),
        .uncache(uncache_d)
    );

    dcache  dcache_inst (
        .clk(clk),
        .rstn(rstn),
        .rvalid(EX_mem_rvalid),
        .wvalid(EX_mem_wvalid),
        .uncache(uncache_d),
        .wdata(EX_mem_wdata),
        .paddr(p_addr_EX),
        .mem_type(EX_mem_type),
        .cacop_en (EX_cacop_en_d),
        .cacop_code (EX_cacop_code_d),
        .cacop_va (EX_mem_addr),
        .cacop_finish (EX_cacop_finish_d),
        .rdata(MEM_mem_rdata),
        .rready(MEM_mem_rready),
        .wready(MEM_mem_wready),
        .d_arready(d_axi_arready),
        .d_rvalid(d_axi_rvalid),
        .d_rlast(d_axi_rlast),
        .d_rdata(d_axi_rdata),
        .d_rready(d_axi_rready),
        .d_arvalid(d_axi_arvalid),
        .d_araddr(d_axi_araddr),
        .d_arlen(d_axi_arlen),
        .d_arsize(d_axi_arsize),
        .d_awready(d_axi_awready),
        .d_wready(d_axi_wready),
        .d_bvalid(d_axi_bvalid),
        .d_awvalid(d_axi_awvalid),
        .d_awsize(d_axi_awsize),
        .d_awlen(d_axi_awlen),
        .d_wstrb(d_axi_wstrb),
        .d_awaddr(d_axi_awaddr),
        .d_wdata(d_axi_wdata),
        .d_wvalid(d_axi_wvalid),
        .d_wlast(d_axi_wlast),
        .d_bready(d_axi_bready)
    );

    // AXI
    axi_interconnect #(
        .S_COUNT(2),
        .M_COUNT(1),
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .ID_WIDTH(4)
    )
    the_axi_interconnect(
        .clk(clk),.rst(~rstn),

        //master
        .m_axi_awid(awid),
        .m_axi_awaddr(awaddr),
        .m_axi_awlen(awlen),
        .m_axi_awsize(awsize),
        .m_axi_awburst(awburst),
        .m_axi_awlock(awlock[0]),
        .m_axi_awcache(awcache),
        .m_axi_awprot(awprot),
        //https://developer.arm.com/documentation/ihi0022/e/AMBA-AXI3-and-AXI4-Protocol-Specification/AXI4-Additional-Signaling/QoS-signaling/QoS-interface-signals?lang=en
        .m_axi_awqos(),
        .m_axi_awregion(),
        .m_axi_awvalid(awvalid),
        .m_axi_awready(awready),

        //wid was removed in AXI4
        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),
        .m_axi_wvalid(wvalid),
        .m_axi_wready(wready),

        .m_axi_bid(bid),
        .m_axi_bresp(bresp),
        .m_axi_bvalid(bvalid),
        .m_axi_bready(bready),

        .m_axi_arid(arid),
        .m_axi_araddr(araddr),
        .m_axi_arlen(arlen),
        .m_axi_arsize(arsize),
        .m_axi_arburst(arburst),
        .m_axi_arlock(arlock[0]),
        .m_axi_arcache(arcache),
        .m_axi_arprot(arprot),
        .m_axi_arqos(),
        .m_axi_arregion(),
        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),

        .m_axi_rid(rid),
        .m_axi_rdata(rdata),
        .m_axi_rresp(rresp),
        .m_axi_rlast(rlast),
        .m_axi_rvalid(rvalid),
        .m_axi_rready(rready),

        //slave
        .s_axi_awid     ({ i_axi_awid     ,  d_axi_awid     }),
        .s_axi_awaddr   ({ i_axi_awaddr   ,  d_axi_awaddr   }),
        .s_axi_awlen    ({ i_axi_awlen    ,  d_axi_awlen    }),
        .s_axi_awsize   ({ i_axi_awsize   ,  d_axi_awsize   }),
        .s_axi_awburst  ({ i_axi_awburst  ,  d_axi_awburst  }),
        .s_axi_awlock   ({ i_axi_awlock   ,  d_axi_awlock   }),
        .s_axi_awcache  ({ i_axi_awcache  ,  d_axi_awcache  }),
        .s_axi_awprot   ({ i_axi_awprot   ,  d_axi_awprot   }),
        .s_axi_awqos    (0),
        .s_axi_awvalid  ({ i_axi_awvalid  ,  d_axi_awvalid  }),
        .s_axi_awready  ({ i_axi_awready  ,  d_axi_awready  }),
        .s_axi_wdata    ({ i_axi_wdata    ,  d_axi_wdata    }),
        .s_axi_wstrb    ({ i_axi_wstrb    ,  d_axi_wstrb    }),
        .s_axi_wlast    ({ i_axi_wlast    ,  d_axi_wlast    }),
        .s_axi_wvalid   ({ i_axi_wvalid   ,  d_axi_wvalid   }),
        .s_axi_wready   ({ i_axi_wready   ,  d_axi_wready   }),
        .s_axi_bid      ({ i_axi_bid      ,  d_axi_bid      }),
        .s_axi_bresp    ({ i_axi_bresp    ,  d_axi_bresp    }),
        .s_axi_bvalid   ({ i_axi_bvalid   ,  d_axi_bvalid   }),
        .s_axi_bready   ({ i_axi_bready   ,  d_axi_bready   }),
        .s_axi_arid     ({ i_axi_arid     ,  d_axi_arid     }),
        .s_axi_araddr   ({ i_axi_araddr   ,  d_axi_araddr   }),
        .s_axi_arlen    ({ i_axi_arlen    ,  d_axi_arlen    }),
        .s_axi_arsize   ({ i_axi_arsize   ,  d_axi_arsize   }),
        .s_axi_arburst  ({ i_axi_arburst  ,  d_axi_arburst  }),
        .s_axi_arlock   ({ i_axi_arlock   ,  d_axi_arlock   }),
        .s_axi_arcache  ({ i_axi_arcache  ,  d_axi_arcache  }),
        .s_axi_arprot   ({ i_axi_arprot   ,  d_axi_arprot   }),
        .s_axi_arqos    (0),
        .s_axi_arvalid  ({ i_axi_arvalid  ,  d_axi_arvalid  }),
        .s_axi_arready  ({ i_axi_arready  ,  d_axi_arready  }),
        .s_axi_rid      ({ i_axi_rid      ,  d_axi_rid      }),
        .s_axi_rdata    ({ i_axi_rdata    ,  d_axi_rdata    }),
        .s_axi_rresp    ({ i_axi_rresp    ,  d_axi_rresp    }),
        .s_axi_rlast    ({ i_axi_rlast    ,  d_axi_rlast    }),
        .s_axi_rvalid   ({ i_axi_rvalid   ,  d_axi_rvalid   }),
        .s_axi_rready   ({ i_axi_rready   ,  d_axi_rready   })
    );

    `ifdef DIFFTEST_EN
    DifftestGRegState DifftestGRegState(
        .clock              (aclk       ),
        .coreid             (0          ),
        .gpr_0              (0          ),
        .gpr_1              (regs[1]    ),
        .gpr_2              (regs[2]    ),
        .gpr_3              (regs[3]    ),
        .gpr_4              (regs[4]    ),
        .gpr_5              (regs[5]    ),
        .gpr_6              (regs[6]    ),
        .gpr_7              (regs[7]    ),
        .gpr_8              (regs[8]    ),
        .gpr_9              (regs[9]    ),
        .gpr_10             (regs[10]   ),
        .gpr_11             (regs[11]   ),
        .gpr_12             (regs[12]   ),
        .gpr_13             (regs[13]   ),
        .gpr_14             (regs[14]   ),
        .gpr_15             (regs[15]   ),
        .gpr_16             (regs[16]   ),
        .gpr_17             (regs[17]   ),
        .gpr_18             (regs[18]   ),
        .gpr_19             (regs[19]   ),
        .gpr_20             (regs[20]   ),
        .gpr_21             (regs[21]   ),
        .gpr_22             (regs[22]   ),
        .gpr_23             (regs[23]   ),
        .gpr_24             (regs[24]   ),
        .gpr_25             (regs[25]   ),
        .gpr_26             (regs[26]   ),
        .gpr_27             (regs[27]   ),
        .gpr_28             (regs[28]   ),
        .gpr_29             (regs[29]   ),
        .gpr_30             (regs[30]   ),
        .gpr_31             (regs[31]   )
    );

    `endif

endmodule
