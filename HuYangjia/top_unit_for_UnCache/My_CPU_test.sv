`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 15:17:16
// Design Name: 
// Module Name: My_CPU_test
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

`include "Public_Info.sv"
import Public_Info::*;
module My_CPU_test(
    input           clk,
    input           rstn,
    input    [ 7:0] intrpt, 
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
  
    // ICache
    logic [ 0: 0] ICache_valid;
    logic         i_rvalid;
    logic [31: 0] i_araddr;
    logic         i_rready;
    logic         i_rlast;
    logic [31: 0] i_rdata;
    logic         rready_icache;
    logic         i_arvalid;
    logic         i_arready;
    logic [ 7: 0] i_arlen;



    // IF1_IF2
    logic [ 1: 0] IF1_IF2_valid;


    // IF2_ID1
    logic [31: 0] i_PC1;
    logic [31: 0] i_IR1;
    logic [31: 0] i_PC2;
    logic [31: 0] i_IR2;
    logic [ 1: 0] i_is_valid;
    logic [31: 0] o_PC1;
    logic [31: 0] o_IR1;
    logic [31: 0] o_PC2;
    logic [31: 0] o_IR2;
    logic [ 1: 0] o_is_valid;
    logic [ 0: 0] o_is_full;
    logic [ 0: 0] ID_status;


    // RegFile中的信号
    logic [ 4: 0] raddr_a1;
    logic [ 4: 0] raddr_a2;
    logic [ 4: 0] raddr_b1;
    logic [ 4: 0] raddr_b2;
    logic [31: 0] rdata_a1;
    logic [31: 0] rdata_a2;
    logic [31: 0] rdata_b1;
    logic [31: 0] rdata_b2;
    logic [ 4: 0] addr = 0;
    logic [31: 0] dout_rf;
    logic [ 4: 0] waddr_a;
    logic [ 4: 0] waddr_b;
    logic [31: 0] wdata_a;
    logic [31: 0] wdata_b;
    logic we_a;
    logic we_b;


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
    logic [ 2: 0] EX_alu_src_sel_a1;
    logic [ 2: 0] EX_alu_src_sel_a2;
    logic [ 2: 0] EX_alu_src_sel_b1;
    logic [ 2: 0] EX_alu_src_sel_b2;
    logic [11: 0] EX_alu_op_a;
    logic [11: 0] EX_alu_op_b;
    logic [ 3: 0] EX_br_type_a;
    logic [ 3: 0] EX_br_type_b;
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
    logic [ 5: 0] EX_mux_select;
    logic [ 0: 0] EX_signed;
    logic [ 0: 0] EX_div_en;


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
    assign i_axi_bid = 0;
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
    assign d_axi_bid = 1;
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
    logic [ 0: 0] EX_br;
    logic [31: 0] EX_pc_br;
    logic [ 0: 0] EX_mem_rvalid;
    logic [ 0: 0] EX_mem_wvalid;
    logic [ 0: 0] MEM_mem_rready;
    logic [ 0: 0] MEM_mem_wready;
    logic [31: 0] EX_mem_addr;
    logic [ 2: 0] EX_mem_type;
    logic [31: 0] EX_mem_wdata;
    logic [31: 0] MEM_mem_rdata;
    logic [ 0: 0] EX_UnCache;
    
    // stall && flush
    logic [ 0: 0] stall_DCache; // 由于Dcache缺失带来的逻辑的stall信号，只作用于issue Buffer
    // logic [ 0: 0] stall_dcache; // 由于Dcache缺失带来的真正的stall信号
    logic [ 0: 0] stall_full_issue; // 由于issue Buffer满带来的stall信号，只作用于Instruction Buffer
    logic [ 0: 0] stall_full_instr; // 由于Instruction Buffer满带来的stall信号，作用于IF1
    logic [ 0: 0] stall_ICache; // 由于Icache缺失带来的逻辑的stall信号，作用于IF1的取值模块和IF1_IF2段间寄存器
    logic [ 0: 0] stall_iCache; // 由于Icache缺失带来的真正的stall信号
    logic [ 0: 0] stall_div;// 由于除法器忙带来的stall信号
    logic [ 0: 0] flush_BR; // 由于分支预测错误带来的flush信号，作用于两个Buffer和IF1_IF2段间寄存器，作用于ICache(在Miss则停止操作)

    // temp测试
    assign stall_ICache = ~stall_iCache;
    assign stall_DCache = ~(MEM_mem_rready | MEM_mem_wready);
    assign flush_BR = EX_br;
    assign stall_full_issue = o_is_full_2;
    assign stall_full_instr = o_is_full;
    
  
    assign pc_predict = pc_IF1 + ((~is_valid) ? 0 : ((pc_IF1[ 3: 2] == 2'b11) ? 4: 8));

    IF1  IF1_inst (
        .clk(clk),
        .rstn(rstn),
        .pc_predict(pc_predict),
        .pc_BR(EX_pc_br),
        .EX_BR(EX_br),
        .stall_ICache(stall_ICache),
        .stall_full_instr(stall_full_instr),
        .pc_IF1(pc_IF1),
        .is_valid(is_valid)
    );
 

    // temp IMeM (
    //     .clka(clk),    // input logic clka
    //     .wea(0),      // input logic [0 : 0] wea
    //     .addra(pc_IF1[14: 2]),  // input logic [12 : 0] addra
    //     .dina(0),    // input logic [31 : 0] dina
    //     .douta(i_IR1),  // output logic [31 : 0] douta
    //     .clkb(clk),    // input logic clkb
    //     .web(0),      // input logic [0 : 0] web
    //     .addrb(pc_IF1[14: 2]+1),  // input logic [12 : 0] addrb
    //     .dinb(0),    // input logic [31 : 0] dinb
    //     .doutb(i_IR2)  // output logic [31 : 0] doutb
    // );

    Icache  Icache_inst (
        .clk(clk),
        .rstn(rstn),
        .rvalid(is_valid),
        .raddr(pc_IF1),
        .Is_flush(flush_BR), // TODO: 中断例外需要给flush
        .rready(stall_iCache), // 1-> normal, 0-> stall
        .rdata({i_IR2, i_IR1}),
        .flag_valid(ICache_valid),
        .i_rready (i_axi_rready),
        .i_rvalid (i_axi_rvalid),
        .i_rdata (i_axi_rdata),
        .i_rlast (i_axi_rlast),
        .i_arvalid (i_axi_arvalid),
        .i_araddr (i_axi_araddr),
        .i_arready (i_axi_arready),
        .i_arlen (i_axi_arlen)
    );
    IF1_IF2  IF1_IF2_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC1(pc_IF1),
        .i_PC2(pc_IF1+4),
        .flush_BR(flush_BR),
        .i_is_valid(is_valid),
        .stall_ICache(stall_ICache),
        .o_PC1(i_PC1),
        .o_PC2(i_PC2),
        .o_is_valid(IF1_IF2_valid)
    );
    assign i_is_valid = IF1_IF2_valid & {1'b1, ICache_valid} & {2{stall_iCache}};
    
    IF2_ID1  IF2_ID1_inst (
        .clk(clk),
        .rstn(rstn),
        .i_PC1(i_PC1),
        .i_IR1(i_IR1),
        .i_PC2(i_PC2),
        .i_IR2(i_IR2),
        .i_is_valid(i_is_valid),
        .flush_BR(flush_BR),
        .stall_ICache(stall_ICache),
        .stall_full_issue(stall_full_issue),
        .o_PC1(o_PC1),
        .o_IR1(o_IR1),
        .o_PC2(o_PC2),
        .o_IR2(o_IR2),
        .o_is_valid(o_is_valid),
        .o_is_full(o_is_full),
        .ID_status(ID_status)
    );
    // logic [ 0: 0] ID_status;
    ID_Decode_edi_2  ID_Decode_edi_2_inst_1 (
        .IF_IR(o_IR1),
        .PC(o_PC1),
        .ID_status(ID_status),
        .data_valid(o_is_valid[1]),
        .PC_set(PC_set1_front)
    );
    ID_Decode_edi_2  ID_Decode_edi_2_inst_2 (
        .IF_IR(o_IR2),
        .PC(o_PC2),
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
        .flush_BR(flush_BR),
        .stall_DCache(stall_DCache),
        .stall_div(stall_div),
        .o_PC_set1(PC_set1_back),
        .o_PC_set2(PC_set2_back),
        .a_rf_raddr1(raddr_a1),
        .a_rf_raddr2(raddr_a2),
        .b_rf_raddr1(raddr_b1),
        .b_rf_raddr2(raddr_b2),
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
        .addr(addr),
        .dout_rf(dout_rf),
        .waddr_a(WB_rf_waddr_a),
        .waddr_b(WB_rf_waddr_b),
        .wdata_a(WB_rf_wdata_a),
        .wdata_b(WB_rf_wdata_b),
        .we_a(WB_rf_we_a),
        .we_b(WB_rf_we_b)
    );

    Issue_dispatch  Issue_dispatch_inst (
        .clk(clk),
        .i_set1(PC_set1_back),
        .i_set2(PC_set2_back),
        .i_is_valid(o_is_valid_2),
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
        .flush_BR(flush_BR),
        .stall_DCache(stall_DCache),
        .stall_div(stall_div),
        .EX_a_enable(EX_a_enable),
        .EX_b_enable(EX_b_enable),
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
        .EX_div_en(EX_div_en)
    );

    

    ex_mem_wb  ex_mem_wb_inst (
        .clk(clk),
        .rstn(rstn),
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
        .EX_br_type_a(EX_br_type_a),
        .EX_br_type_b(EX_br_type_b),
        .EX_br_pd_a(EX_br_pd_a),
        .EX_br_pd_b(EX_br_pd_b),
        .EX_rf_we_a(EX_rf_we_a),
        .EX_rf_we_b(EX_rf_we_b),
        .EX_rf_waddr_a(EX_rf_waddr_a),
        .EX_rf_waddr_b(EX_rf_waddr_b),
        .EX_mem_we_a(EX_mem_we_a),
        .EX_mem_we_b(EX_mem_we_b),
        .EX_mem_type_a(EX_mem_type_a),
        .EX_mem_type_b(EX_mem_type_b),
        .EX_signed(EX_signed),
        .EX_wb_mux_select_b(EX_mux_select),
        .WB_rf_we_a(WB_rf_we_a),
        .WB_rf_we_b(WB_rf_we_b),
        .WB_rf_waddr_a(WB_rf_waddr_a),
        .WB_rf_waddr_b(WB_rf_waddr_b),
        .WB_rf_wdata_a(WB_rf_wdata_a),
        .WB_rf_wdata_b(WB_rf_wdata_b),
        .EX_br(EX_br),
        .EX_pc_br(EX_pc_br),
        .EX_mem_rvalid(EX_mem_rvalid),
        .EX_mem_wvalid(EX_mem_wvalid),
        .MEM_mem_rready(MEM_mem_rready),
        .MEM_mem_wready(MEM_mem_wready),
        .EX_mem_addr(EX_mem_addr),
        .EX_mem_type(EX_mem_type),
        .EX_mem_wdata(EX_mem_wdata),
        .MEM_mem_rdata(MEM_mem_rdata),
        .EX_div_en(EX_div_en),
        .stall_div(stall_div),
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
    

    dcache  dcache_inst (
        .clk(clk),
        .rstn(rstn),
        .rvalid(EX_mem_rvalid),
        .wvalid(EX_mem_wvalid),
        .uncache(EX_UnCache),
        .wdata(EX_mem_wdata),
        .addr(EX_mem_addr),
        .mem_type(EX_mem_type),
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


endmodule
