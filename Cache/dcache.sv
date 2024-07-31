`timescale 1ns / 1ps

module dcache(
    input                  clk,
    input                  rstn,

    //from cpu
    input                  rvalid,
    input                  wvalid,
    input      [31:0]      wdata,
    input      [31:0]      addr,
    input      [2:0]       mem_type,
    input                  uncache,
    //来自cpu的flush信号,好像不需要？
    //input                  flush,
    /* mem_type */
    // support h/b operation
    // 000 others or ld.w
    // 001 st.w
    // 010 ld.b
    // 011 ld.h
    // 100 ld.bu
    // 101 ld.hu
    // 110 st.b
    // 111 st.h

    //to cpu
    output reg [31:0]      rdata,
    output reg             rready,
    output reg             wready,

    /*axi*/
    //read
    input                  d_arready,
    input                  d_rvalid,
    input                  d_rlast,
    input      [31:0]      d_rdata,
    output reg             d_rready,
    output reg             d_arvalid,
    output reg [31:0]      d_araddr,
    output wire [7:0]      d_arlen,
    output wire [2:0]      d_arsize,

    //write
    input                  d_awready,
    input                  d_wready,
    input                  d_bvalid,
    output reg             d_awvalid,
    output wire  [2:0]     d_awsize,
    output wire  [7:0]     d_awlen,
    output reg   [3:0]     d_wstrb,
    output wire  [31:0]    d_awaddr,
    output reg   [31:0]    d_wdata,
    output reg             d_wvalid,
    output reg             d_wlast,
    output reg             d_bready

    );

    wire  [31:0]  address ;
    wire  [2:0]   mem_type_pipe ;
    wire  [31:0]  wdata_pipe ;
    wire          rbuf_we ;
    wire  [1:0]   TagDV_we ;
    wire  [31:0]  mem_we ;
    wire  [7:0]   r_index ;
    wire  [7:0]   w_index ;
    wire  [21:0]  w_tagdv ;
    wire  [21:0]  r_tagdv1 ;
    wire  [21:0]  r_tagdv2 ;
    wire  [19:0]  Tag ;
    wire          hit1 ;
    wire          hit2 ;
    wire  [1:0]   hit ;
    wire  [127:0] r_data1 ;
    wire  [127:0] r_data2 ;
    wire  [127:0] r_data_mem ;
    wire  [127:0] w_data ;
    wire  [127:0] w_data_rbuf ;
    wire  [1:0]   offset ;
    wire  [31:0]  data_from_dcache ;
    wire  [31:0]  data_from_retbuf ;
    wire          data_from_mem_sel ;
    wire          way_sel ;
    wire          LRU_update ;
    wire          dirty ;
    wire  [31:0]  rdata_temp ;
    wire          mbuf_we ;
    wire          wbuf_we ;
    wire          miss_LRU_update ;
    wire          miss_lru_way ;
    wire          wfsm_en ;
    wire          wfsm_rset ;
    wire          write_finish ;
    
    //valid信号流水
    wire          wvalid_pipe ;
    wire          rvalid_pipe ;
    wire          uncache_pipe ;
    wire  [31:0]  d_awaddr_cache ;
    wire  [31:0]  d_wdata_cache ;
    reg   [31:0]  wdata_pipe_temp ;
    reg   [3:0]   d_wstrb_temp ;
    assign d_awlen = uncache_pipe ? 8'd0 : 8'd3;
    assign d_awsize = 3'd4;
    assign d_wstrb = uncache_pipe ? d_wstrb_temp : 4'b1111;
    assign d_arlen = uncache_pipe ? 8'd0 : 8'd3;
    assign d_arsize = 3'd4;
    assign d_awaddr = uncache_pipe ? {address[31:2],2'b00} : d_awaddr_cache;
    assign d_wdata = uncache_pipe ? wdata_pipe_temp : d_wdata_cache;

    assign r_index = addr[11:4];
    assign w_index = address[11:4];
    assign Tag = address[31:12];
    assign hit1 = r_tagdv1[0] & (Tag == r_tagdv1[21:2]);
    assign hit2 = r_tagdv2[0] & (Tag == r_tagdv2[21:2]);
    assign hit = {hit2,hit1};
    assign offset = address[3:2];

    //产生w_tagdv的逻辑,决定是否写dirty
    assign w_tagdv = {address[31:12],(wvalid_pipe == 1'b1 ? 1'b1:1'b0),1'b1};
    //产生dirty的逻辑
    assign dirty = way_sel == 1'b1 ? r_tagdv2[1] : r_tagdv1[1];

    always @(*)begin
        case(mem_type_pipe)
            3'b000: wdata_pipe_temp = wdata_pipe;//others or ld.w 
            3'b001: wdata_pipe_temp = wdata_pipe;//st.w
            3'b010: wdata_pipe_temp = wdata_pipe;//ld.b
            3'b011: wdata_pipe_temp = wdata_pipe;//lb.h
            3'b100: wdata_pipe_temp = wdata_pipe;//ld.bu
            3'b101: wdata_pipe_temp = wdata_pipe;//ld.hu
            3'b110: begin
                case(address[1:0])//st.b
                    2'b00: wdata_pipe_temp = {24'h0, wdata_pipe[7:0]};
                    2'b01: wdata_pipe_temp = {16'h0, wdata_pipe[7:0], 8'h0};
                    2'b10: wdata_pipe_temp = {8'h0, wdata_pipe[7:0], 16'h0};
                    2'b11: wdata_pipe_temp = {wdata_pipe[7:0], 24'h0};
                endcase
            end
            3'b111: begin
                case(address[1:0])//st.h
                    2'b00: wdata_pipe_temp = {16'h0, wdata_pipe[15:0]};
                    2'b10: wdata_pipe_temp = {wdata_pipe[15:0], 16'h0};
                    default: wdata_pipe_temp = wdata_pipe;
                endcase
            end
        endcase
    end

    always @(*)begin
        case(mem_type_pipe)
            3'b000: d_wstrb_temp = 4'b1111;//others or ld.w 
            3'b001: d_wstrb_temp = 4'b1111;//st.w
            3'b010: d_wstrb_temp = 4'b1111;//ld.b
            3'b011: d_wstrb_temp = 4'b1111;//lb.h
            3'b100: d_wstrb_temp = 4'b1111;//ld.bu
            3'b101: d_wstrb_temp = 4'b1111;//ld.hu
            3'b110: begin
                case(address[1:0])//st.b
                    2'b00: d_wstrb_temp = 4'b0001;
                    2'b01: d_wstrb_temp = 4'b0010;
                    2'b10: d_wstrb_temp = 4'b0100;
                    2'b11: d_wstrb_temp = 4'b1000;
                endcase
            end
            3'b111: begin
                case(address[1:0])//st.h
                    2'b00: d_wstrb_temp = 4'b0011;
                    2'b10: d_wstrb_temp = 4'b1100;
                    default: d_wstrb_temp = 4'b1111;
                endcase
            end
        endcase
    end

    register# ( .WIDTH(70), .RST_VAL(0))
    request_buffer (              
        .clk    (clk),
        .rstn   (rstn),
        .en     (rbuf_we),
        .d      ({addr,wdata,mem_type,wvalid,rvalid,uncache}),
        .q      ({address,wdata_pipe,mem_type_pipe,wvalid_pipe,rvalid_pipe,uncache_pipe})
    );

    TagDV_mem TagDV_mem1(
        .addra(w_index),
        .clka(clk),
        .dina(w_tagdv),
        .addrb(r_index),
        .doutb(r_tagdv1),
        .wea(TagDV_we[0])
    );

    TagDV_mem TagDV_mem2(
        .addra(w_index),
        .clka(clk),
        .dina(w_tagdv),
        .addrb (r_index),
        .doutb(r_tagdv2),
        .wea(TagDV_we[1])
    );

    Data_mem_data Data_mem1(
        .addra(w_index),
        .clka(clk),
        .dina(w_data),
        .addrb (r_index),
        .doutb(r_data1),
        .ena (1'b1),
        .wea(mem_we[15:0])
    );

    Data_mem_data Data_mem2(
        .addra(w_index),
        .clka(clk),
        .dina(w_data),
        .addrb (r_index),
        .doutb(r_data2),
        .ena (1'b1),
        .wea(mem_we[31:16])
    );

    MUX_hit_dcache mux_hit1_dcache(
        .hit (hit),
        .r_data1 (r_data1),
        .r_data2 (r_data2),
        .r_data_mem (r_data_mem)
    );

    read_manage_dcache read_manage1_dcache(
        .r_data_mem (r_data_mem),
        .offset (offset),
        .data_from_dcache (data_from_dcache)
    );

    mux2_1 mux2_1_data(
        .din1 (data_from_dcache),
        .din2 (data_from_retbuf),
        .sel  (data_from_mem_sel),
        .dout (rdata_temp)
    );


    //根据mem_type_pipe  实现 rdata_temp--> rdata 的转变
    always@(*)begin//支持ld b, h, bu, hu
        case(mem_type_pipe)
        3'b000: rdata = rdata_temp;//others or ld.w 
        3'b001: rdata = rdata_temp;//st.w
        3'b010: //ld.b
            case(address[1:0])
            2'b00: rdata = {{24{rdata_temp[7]}},rdata_temp[7:0]};
            2'b01: rdata = {{24{rdata_temp[15]}},rdata_temp[15:8]};
            2'b10: rdata = {{24{rdata_temp[23]}},rdata_temp[23:16]};
            2'b11: rdata = {{24{rdata_temp[31]}},rdata_temp[31:24]};
        endcase
        3'b011: //lb.h
            case(address[1:0])
            2'b00: rdata = {{16{rdata_temp[15]}},rdata_temp[15:0]};
            2'b10: rdata = {{16{rdata_temp[31]}},rdata_temp[31:16]};
            //exception
            default: rdata = rdata_temp;
        endcase
        3'b100: //ld.bu
            case(address[1:0])
            2'b00: rdata = {{24{1'b0}},rdata_temp[7:0]};
            2'b01: rdata = {{24{1'b0}},rdata_temp[15:8]};
            2'b10: rdata = {{24{1'b0}},rdata_temp[23:16]};
            2'b11: rdata = {{24{1'b0}},rdata_temp[31:24]};
        endcase
        3'b101: //ld.hu
            case(address[1:0])
            2'b00: rdata = {{16{1'b0}},rdata_temp[15:0]};
            2'b10: rdata = {{16{1'b0}},rdata_temp[31:16]};
            //exception
            default: rdata = rdata_temp;
        endcase
        3'b110: rdata = rdata_temp;//st.b
        3'b111: rdata = rdata_temp;//st.h
    endcase
    end
    //后面如果flush则送出nop


    LRU_dcache LRU1_dcache(
        .clk (clk),
        .LRU_update (LRU_update),
        .w_index (w_index),
        .hit (hit),
        .way_sel (way_sel),
        .miss_LRU_update (miss_LRU_update),
        .miss_lru_way (miss_lru_way)
    );

    Return_buffer_dcache Return_buffer1_dcache(
        .clk (clk),
        .offset (offset),
        .uncache_pipe (uncache_pipe),
        .d_rvalid (d_rvalid),
        .d_arvalid (d_arvalid),
        .d_rlast (d_rlast),
        .d_rdata (d_rdata),
        .w_data (w_data_rbuf),
        .data_from_retbuf (data_from_retbuf)
    );

    Write_manage Write_manage1(
        .address (address),
        .wdata_pipe (wdata_pipe),
        .w_data_rbuf (w_data_rbuf),
        .mem_type_pipe (mem_type_pipe),
        .w_data (w_data)
    );

    Miss_buffer_dcache Miss_buffer_dcache1(
        .clk (clk),
        .address (address),
        .way_sel (way_sel),
        .r_tagv1 (r_tagdv1[21:2]),
        .r_tagv2 (r_tagdv2[21:2]),
        .mbuf_we (mbuf_we),
        .d_awaddr_cache (d_awaddr_cache)
    );

    Write_buffer Write_buffer1(
        .clk (clk),
        .way_sel (way_sel),
        .r_data1 (r_data1),
        .r_data2 (r_data2),
        .wbuf_we (wbuf_we),
        .d_wready (d_wready),
        .d_wdata_cache (d_wdata_cache)
    );

    FSM_dcache FSM_dcache1(
        .clk (clk),
        .rstn (rstn),
        .wvalid (wvalid),
        .rvalid (rvalid),
        .wvalid_pipe (wvalid_pipe),
        .rvalid_pipe (rvalid_pipe),
        .way_sel (way_sel),
        .write_finish (write_finish),
        .d_rlast (d_rlast),
        .d_rready (d_rready),
        .d_rvalid (d_rvalid),
        .hit (hit),
        .address (address),
        .mem_type_pipe (mem_type_pipe),
        .uncache_pipe (uncache_pipe),
        .mem_we (mem_we),
        .TagDV_we (TagDV_we),
        .d_arvalid (d_arvalid),
        .d_arready (d_arready),
        .rbuf_we (rbuf_we),
        .mbuf_we (mbuf_we),
        .wbuf_we (wbuf_we),
        .data_from_mem_sel (data_from_mem_sel),
        .d_araddr (d_araddr),
        .rready (rready),
        .wready (wready),
        .LRU_update (LRU_update),
        .miss_LRU_update (miss_LRU_update),
        .miss_lru_way (miss_lru_way),
        .wfsm_en (wfsm_en),
        .wfsm_rset (wfsm_rset)
    );

    wb_fsm wb_fsm1(
        .clk (clk),
        .rstn (rstn),
        .wfsm_en (wfsm_en),
        .wfsm_rset (wfsm_rset),
        .uncache_pipe (uncache_pipe),
        .d_wready (d_wready),
        .d_wvalid (d_wvalid),
        .d_bvalid (d_bvalid),
        .dirty (dirty),
        .write_finish (write_finish),
        .d_awvalid (d_awvalid),
        .d_awready (d_awready),
        .d_wlast (d_wlast),
        .d_bready (d_bready)
    );





endmodule
