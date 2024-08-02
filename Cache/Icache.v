`timescale 1ns / 1ps
/*Icache with axi*/
module Icache(
    input                   clk,
    input                   rstn,
    //from cpu
    input                   rvalid,
    input       [31:0]      raddr,
    input                   Is_flush,
    input                   uncache,
    //input                   uncache,
    //cache操作
    //input       [31:0]      icache_opcode,//cache操作

    //0-正常访存 1-cache操作
    //input                   icache_opflag, 

    //to cpu
    output                  rready,
    //双发射，一次送出两条指令
    output      [63:0]      rdata,
    //用于指示[63:32]是否有效
    output       wire       flag_valid,
    output       wire       data_valid,



    //from axi
    input                   i_arready,
    input                   i_rlast,
    input       [31:0]      i_rdata,
    input                   i_rvalid,




    //to axi
    output                  i_arvalid,
    output      [31:0]      i_araddr,
    output      [7:0]       i_arlen,
    output                  i_rready

    );

    wire  [31:0]  addr ;
    wire          rbuf_we ;
    wire  [1:0]  TagV_we ;
    wire  [1:0]  mem_we ;
    wire  [7:0]   r_index ;
    wire  [7:0]   w_index ;
    wire  [20:0]  w_tagv ;
    wire  [20:0]  r_tagv1 ;
    wire  [20:0]  r_tagv2 ;
    wire  [19:0]  Tag ;
    wire          hit1 ;
    wire          hit2 ;
    wire  [1:0]   hit ;
    wire  [127:0] r_data1 ;
    wire  [127:0] r_data2 ;
    wire  [127:0] r_data_mem ;
    wire  [127:0] w_data ;
    wire  [1:0]   offset ;
    wire  [63:0]  inst_from_icache ;
    wire  [63:0]  inst_from_retbuf ;
    wire          data_from_mem_sel ;
    wire          way_sel ;
    wire          LRU_update ;
    reg           valid_reg ;
    wire          fbuf_clear ;
    wire          miss_LRU_update ;
    wire          miss_lru_way ;
    wire          uncache_pipe ;

    assign r_index = raddr[11:4];
    assign w_index = addr[11:4];
    assign Tag = addr[31:12];
    assign hit1 = r_tagv1[0] & (Tag == r_tagv1[20:1]); // TODO: && !(Tag ^ r_tagv1[20:1])
    assign hit2 = r_tagv2[0] & (Tag == r_tagv2[20:1]);
    assign hit = {hit2,hit1};
    assign offset = addr[3:2];
    assign w_tagv = {addr[31:12],1'b1};
    assign i_arlen = uncache_pipe ? 8'd1 : 8'd3;
    assign flag_valid = offset == 2'b11 ? 0 : 1;
    assign data_valid = valid_reg;

    always @(posedge clk) begin
        if(Is_flush) valid_reg <= 1'b0;
        else if(rbuf_we) valid_reg <= rvalid;
    end

    register# ( .WIDTH(33), .RST_VAL(0))
    request_buffer (              
        .clk    (clk),
        .rstn   (rstn),
        .en     (rbuf_we),
        .d      (raddr,uncache),
        .q      (addr,uncache_pipe)
    );

    TagV_mem TagV_mem1(
        .addra(TagV_we[0]==0 ? r_index : w_index),
        .clka(clk),
        .dina(w_tagv),
        .douta(r_tagv1),
        .wea(TagV_we[0])
    );

    TagV_mem TagV_mem2(
        .addra(TagV_we[1]==0 ? r_index : w_index),
        .clka(clk),
        .dina(w_tagv),
        .douta(r_tagv2),
        .wea(TagV_we[1])
    );

    Data_mem_inst Data_mem1(
        .addra(mem_we[0]==0 ? r_index : w_index),
        .clka(clk),
        .dina(w_data),
        .douta(r_data1),
        .wea(mem_we[0])
    );

    Data_mem_inst Data_mem2(
        .addra(mem_we[1]==0 ? r_index : w_index),
        .clka(clk),
        .dina(w_data),
        .douta(r_data2),
        .wea(mem_we[1])
    );

    MUX_hit mux_hit(
        .hit (hit),
        .r_data1 (r_data1),
        .r_data2 (r_data2),
        .r_data_mem (r_data_mem)
    );

    read_manage read_manage(
        .r_data_mem (r_data_mem),
        .offset (offset),
        .inst_from_icache (inst_from_icache)
    );

    mux_2_1_icache mux2_1_inst(
        .din1 (inst_from_icache),
        .din2 (inst_from_retbuf),
        .sel  (data_from_mem_sel),
        .dout (rdata)
    );

    LRU LRU1(
        .clk (clk),
        .LRU_update (LRU_update),
        .miss_LRU_update (miss_LRU_update),
        .miss_lru_way (miss_lru_way),
        .w_index (w_index),
        .hit (hit),
        .way_sel (way_sel)
    );

    FSM_icache FSM_icache1(
        .clk (clk),
        .rstn (rstn),
        .hit (hit),
        .rvalid (rvalid),
        .i_rready (i_rready),
        .i_rvalid (i_rvalid),
        .i_rlast (i_rlast),
        .addr (addr),
        .way_sel (way_sel),
        .uncache_pipe (uncache_pipe),
        .rready (rready),
        .i_arvalid (i_arvalid),
        .i_arready (i_arready),
        .mem_we (mem_we),
        .TagV_we (TagV_we),
        .rbuf_we (rbuf_we),
        .data_from_mem_sel (data_from_mem_sel),
        .i_araddr (i_araddr),
        .LRU_update (LRU_update),
        .fbuf_clear (fbuf_clear),
        .miss_LRU_update (miss_LRU_update),
        .miss_lru_way (miss_lru_way)
    );

    Return_buffer Return_buffer1(
        .clk (clk),
        .offset (offset),
        .i_arvalid (i_arvalid),
        .i_rvalid (i_rvalid),
        .i_rlast (i_rlast),
        .i_rdata (i_rdata),
        .uncache_pipe (uncache_pipe),
        .w_data (w_data),
        .inst_from_retbuf (inst_from_retbuf)
    );
    




endmodule
