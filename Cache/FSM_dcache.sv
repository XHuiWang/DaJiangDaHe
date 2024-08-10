`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/05 12:39:18
// Design Name: 
// Module Name: FSM_dcache
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


module FSM_dcache(
    input                clk,
    input                rstn,
    input                wvalid,
    input                rvalid,
    input                wvalid_pipe,
    input                rvalid_pipe,
    input                way_sel,
    input                write_finish,
    input                d_rlast,
    input                d_rvalid,
    output   reg         d_rready,
    input         [1:0]      hit,
    input         [31:0]     address,
    input         [2:0]      mem_type_pipe,
    input                    uncache_pipe,
    input                    cacop_en,
    input         [1:0]      cacop_code_pipe,
    output   reg             cacop_finish,
    output   reg  [31:0]     mem_we,
    output   reg  [1:0]      TagDV_we,
    output   reg             d_arvalid,
    input                    d_arready,
    output   reg             rbuf_we,
    output   reg             mbuf_we,
    output   reg             wbuf_we,
    output   reg             data_from_mem_sel,
    output   reg   [31:0]    d_araddr,
    output   reg             rready,
    output   reg             wready,
    output   reg             LRU_update,
    output   reg             miss_LRU_update,
    output   reg             miss_lru_way,
    output   reg             wfsm_en,
    output   reg             wfsm_rset
    );

    reg [2:0]  current_state;
    reg [2:0]  next_state;
    //FSM_ENCODE
    parameter IDLE = 3'h0;
    parameter LOOKUP = 3'h1;
    parameter MISS_A = 3'h5;
    parameter MISS = 3'h2;
    parameter REFILL = 3'h3;
    parameter WAIT_WRITE = 3'h4;
    parameter CACOP_EX = 3'h6;
    parameter CACOP_EX_WAIT = 3'h7;
    //state change
    always @(posedge clk,negedge rstn)begin
        if(!rstn) current_state <= IDLE;
        else current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            IDLE:begin
                if(cacop_en) next_state = CACOP_EX;
                if(rvalid||wvalid) next_state = LOOKUP;
                else next_state = IDLE;
                mem_we = 32'h0;
                TagDV_we = 2'h0;
                d_arvalid = 1'b0;
                rbuf_we = 1'b1;
                mbuf_we = 1'b0;
                wbuf_we = 1'b0;
                data_from_mem_sel = 1'b1;
                d_araddr = 32'h0;
                rready = 1'b1;
                wready = 1'b1;
                LRU_update = 1'b0;
                wfsm_en = 1'b0;
                wfsm_rset = 1'b1;
                miss_LRU_update = 1'b0;
                miss_lru_way = 1'b0;
                d_rready  = 1'b0;
                cacop_finish = 1'b0;
            end
            LOOKUP:begin
                if(uncache_pipe) begin
                    if(rvalid_pipe) begin
                        next_state = MISS_A;
                        mem_we = 32'h0;
                        TagDV_we = 2'h0;
                        d_arvalid = 1'b0;
                        rbuf_we = 1'b0;
                        mbuf_we = 1'b0;
                        wbuf_we = 1'b0;
                        data_from_mem_sel = 1'b1;
                        d_araddr = 32'h0;
                        rready = 1'b0;
                        wready = 1'b0;
                        LRU_update = 1'b0;
                        wfsm_en = 1'b0;
                        wfsm_rset = 1'b0;
                        miss_LRU_update = 1'b0;
                        miss_lru_way = 1'b0;
                        d_rready  = 1'b0;
                        cacop_finish = 1'b0;
                    end
                    else begin
                        next_state = WAIT_WRITE;
                        mem_we = 32'h0;
                        TagDV_we = 2'h0;
                        d_arvalid = 1'b0;
                        rbuf_we = 1'b0;
                        mbuf_we = 1'b0;
                        wbuf_we = 1'b0;
                        data_from_mem_sel = 1'b1;
                        d_araddr = 32'h0;
                        rready = 1'b0;
                        wready = 1'b0;
                        LRU_update = 1'b0;
                        wfsm_en = 1'b1;
                        wfsm_rset = 1'b0;
                        miss_LRU_update = 1'b0;
                        miss_lru_way = 1'b0;
                        d_rready  = 1'b0;
                        cacop_finish = 1'b0;
                    end
                end
                else if((hit != 2'h0)&&(wvalid||rvalid))begin
                    next_state = LOOKUP;
                    if(wvalid_pipe)begin
                        case(mem_type_pipe)
                        3'b001:begin//st.w
                            case(address[3:2])
                            2'b00: mem_we = hit[0] == 0 ? 32'h000f0000 : 32'h0000000f;
                            2'b01: mem_we = hit[0] == 0 ? 32'h00f00000 : 32'h000000f0;
                            2'b10: mem_we = hit[0] == 0 ? 32'h0f000000 : 32'h00000f00;
                            2'b11: mem_we = hit[0] == 0 ? 32'hf0000000 : 32'h0000f000;
                        endcase
                        end
                        3'b110:begin//st.b
                            case(address[3:0])
                            4'b0000: mem_we = hit[0] == 0 ? 32'h00010000 : 32'h00000001;
                            4'b0001: mem_we = hit[0] == 0 ? 32'h00020000 : 32'h00000002;
                            4'b0010: mem_we = hit[0] == 0 ? 32'h00040000 : 32'h00000004;
                            4'b0011: mem_we = hit[0] == 0 ? 32'h00080000 : 32'h00000008;
                            4'b0100: mem_we = hit[0] == 0 ? 32'h00100000 : 32'h00000010;
                            4'b0101: mem_we = hit[0] == 0 ? 32'h00200000 : 32'h00000020;
                            4'b0110: mem_we = hit[0] == 0 ? 32'h00400000 : 32'h00000040;
                            4'b0111: mem_we = hit[0] == 0 ? 32'h00800000 : 32'h00000080;
                            4'b1000: mem_we = hit[0] == 0 ? 32'h01000000 : 32'h00000100;
                            4'b1001: mem_we = hit[0] == 0 ? 32'h02000000 : 32'h00000200;
                            4'b1010: mem_we = hit[0] == 0 ? 32'h04000000 : 32'h00000400;
                            4'b1011: mem_we = hit[0] == 0 ? 32'h08000000 : 32'h00000800;
                            4'b1100: mem_we = hit[0] == 0 ? 32'h10000000 : 32'h00001000;
                            4'b1101: mem_we = hit[0] == 0 ? 32'h20000000 : 32'h00002000;
                            4'b1110: mem_we = hit[0] == 0 ? 32'h40000000 : 32'h00004000;
                            default: mem_we = hit[0] == 0 ? 32'h80000000 : 32'h00008000;
                        endcase
                        end
                        3'b111:begin//st.h
                            case(address[3:0])
                            4'b0000: mem_we = hit[0] == 0 ? 32'h00030000 : 32'h00000003;
                            4'b0010: mem_we = hit[0] == 0 ? 32'h000c0000 : 32'h0000000c;
                            4'b0100: mem_we = hit[0] == 0 ? 32'h00300000 : 32'h00000030;
                            4'b0110: mem_we = hit[0] == 0 ? 32'h00c00000 : 32'h000000c0;
                            4'b1000: mem_we = hit[0] == 0 ? 32'h03000000 : 32'h00000300;
                            4'b1010: mem_we = hit[0] == 0 ? 32'h0c000000 : 32'h00000c00;
                            4'b1100: mem_we = hit[0] == 0 ? 32'h30000000 : 32'h00003000;
                            4'b1110: mem_we = hit[0] == 0 ? 32'hc0000000 : 32'h0000c000;

                            //exception
                            default: mem_we = 32'h00000000;
                        endcase
                        end

                        //wvalid and ld (impossible)
                        default: mem_we = 32'h00000000;
                    endcase
                        TagDV_we = hit[0] == 1'b1 ? 2'b01 : 2'b10;
                    end
                    else begin
                        mem_we = 32'h0;
                        TagDV_we = 2'b00;
                    end
                    if(wvalid_pipe) begin
                        rready = 1'b0;
                        wready = 1'b1;
                    end
                    else begin
                        rready = 1'b1;
                        wready = 1'b0;
                    end
                    d_arvalid = 1'b0;
                    rbuf_we = 1'b1;
                    mbuf_we = 1'b0;
                    wbuf_we = 1'b0;
                    data_from_mem_sel = 1'b0;
                    d_araddr = 32'h0;
                    LRU_update = 1'b1;
                    wfsm_en = 1'b0;
                    wfsm_rset = 1'b0;
                    miss_LRU_update = 1'b0;
                    miss_lru_way = 1'b0;
                    d_rready  = 1'b0;
                    cacop_finish = 1'b0;
                end
                else if((hit != 2'h0)&&!wvalid&&!rvalid)begin
                    next_state = IDLE;
                    if(wvalid_pipe)begin
                        case(mem_type_pipe)
                        3'b001:begin//st.w
                            case(address[3:2])
                            2'b00: mem_we = hit[0] == 0 ? 32'h000f0000 : 32'h0000000f;
                            2'b01: mem_we = hit[0] == 0 ? 32'h00f00000 : 32'h000000f0;
                            2'b10: mem_we = hit[0] == 0 ? 32'h0f000000 : 32'h00000f00;
                            2'b11: mem_we = hit[0] == 0 ? 32'hf0000000 : 32'h0000f000;
                        endcase
                        end
                        3'b110:begin//st.b
                            case(address[3:0])
                            4'b0000: mem_we = hit[0] == 0 ? 32'h00010000 : 32'h00000001;
                            4'b0001: mem_we = hit[0] == 0 ? 32'h00020000 : 32'h00000002;
                            4'b0010: mem_we = hit[0] == 0 ? 32'h00040000 : 32'h00000004;
                            4'b0011: mem_we = hit[0] == 0 ? 32'h00080000 : 32'h00000008;
                            4'b0100: mem_we = hit[0] == 0 ? 32'h00100000 : 32'h00000010;
                            4'b0101: mem_we = hit[0] == 0 ? 32'h00200000 : 32'h00000020;
                            4'b0110: mem_we = hit[0] == 0 ? 32'h00400000 : 32'h00000040;
                            4'b0111: mem_we = hit[0] == 0 ? 32'h00800000 : 32'h00000080;
                            4'b1000: mem_we = hit[0] == 0 ? 32'h01000000 : 32'h00000100;
                            4'b1001: mem_we = hit[0] == 0 ? 32'h02000000 : 32'h00000200;
                            4'b1010: mem_we = hit[0] == 0 ? 32'h04000000 : 32'h00000400;
                            4'b1011: mem_we = hit[0] == 0 ? 32'h08000000 : 32'h00000800;
                            4'b1100: mem_we = hit[0] == 0 ? 32'h10000000 : 32'h00001000;
                            4'b1101: mem_we = hit[0] == 0 ? 32'h20000000 : 32'h00002000;
                            4'b1110: mem_we = hit[0] == 0 ? 32'h40000000 : 32'h00004000;
                            default: mem_we = hit[0] == 0 ? 32'h80000000 : 32'h00008000;
                        endcase
                        end
                        3'b111:begin//st.h
                            case(address[3:0])
                            4'b0000: mem_we = hit[0] == 0 ? 32'h00030000 : 32'h00000003;
                            4'b0010: mem_we = hit[0] == 0 ? 32'h000c0000 : 32'h0000000c;
                            4'b0100: mem_we = hit[0] == 0 ? 32'h00300000 : 32'h00000030;
                            4'b0110: mem_we = hit[0] == 0 ? 32'h00c00000 : 32'h000000c0;
                            4'b1000: mem_we = hit[0] == 0 ? 32'h03000000 : 32'h00000300;
                            4'b1010: mem_we = hit[0] == 0 ? 32'h0c000000 : 32'h00000c00;
                            4'b1100: mem_we = hit[0] == 0 ? 32'h30000000 : 32'h00003000;
                            4'b1110: mem_we = hit[0] == 0 ? 32'hc0000000 : 32'h0000c000;

                            //exception
                            default: mem_we = 32'h00000000;
                        endcase
                        end

                        //wvalid and ld (impossible)
                        default: mem_we = 32'h00000000;
                    endcase
                        TagDV_we = hit[0] == 1'b1 ? 2'b01 : 2'b10;
                    end
                    else begin
                        mem_we = 32'h0;
                        TagDV_we = 2'b00;
                    end
                    if(wvalid_pipe) begin
                        rready = 1'b0;
                        wready = 1'b1;
                    end
                    else begin
                        rready = 1'b1;
                        wready = 1'b0;
                    end
                    d_arvalid = 1'b0;
                    rbuf_we = 1'b1;
                    mbuf_we = 1'b0;
                    wbuf_we = 1'b0;
                    data_from_mem_sel = 1'b0;
                    d_araddr = 32'h0;
                    LRU_update = 1'b1;
                    wfsm_en = 1'b0;
                    wfsm_rset = 1'b0;
                    miss_LRU_update = 1'b0;
                    miss_lru_way = 1'b0;
                    d_rready  = 1'b0;
                    cacop_finish = 1'b0;
                end
                else if(hit == 2'b0)begin
                    next_state = MISS_A;
                    mem_we = 32'h0;
                    TagDV_we = 2'h0;
                    d_arvalid = 1'b0;
                    rbuf_we = 1'b0;
                    mbuf_we = 1'b1;
                    wbuf_we = 1'b1;
                    data_from_mem_sel = 1'b1;
                    d_araddr = 32'h0;
                    rready = 1'b0;
                    wready = 1'b0;
                    LRU_update = 1'b0;
                    wfsm_en = 1'b1;
                    wfsm_rset = 1'b0;
                    miss_LRU_update = 1'b0;
                    miss_lru_way = 1'b0;
                    d_rready  = 1'b0;
                    cacop_finish = 1'b0;
                end
                else begin
                    next_state = MISS_A;
                    mem_we = 32'h0;
                    TagDV_we = 2'h0;
                    d_arvalid = 1'b0;
                    rbuf_we = 1'b0;
                    mbuf_we = 1'b0;
                    wbuf_we = 1'b0;
                    data_from_mem_sel = 1'b1;
                    d_araddr = 32'h0;
                    rready = 1'b0;
                    wready = 1'b0;
                    LRU_update = 1'b0;
                    wfsm_en = 1'b0;
                    wfsm_rset = 1'b0;
                    miss_LRU_update = 1'b0;
                    miss_lru_way = 1'b0;
                    d_rready  = 1'b0;
                    cacop_finish = 1'b0;
                end

            end
            MISS_A:begin
                if(d_arready) next_state = MISS;
                else next_state = MISS_A;
                mem_we = 32'h0;
                TagDV_we = 2'h0;
                d_arvalid = 1'b1;
                rbuf_we = 1'b0;
                mbuf_we = 1'b0;
                wbuf_we = 1'b0;
                data_from_mem_sel = 1'b1;
                d_araddr = uncache_pipe ? {address[31:2],2'b0} : {address[31:4],4'b0};
                rready = 1'b0;
                wready = 1'b0;
                LRU_update = 1'b0;
                wfsm_en = 1'b0;
                wfsm_rset = 1'b0;
                miss_LRU_update = 1'b0;
                miss_lru_way = 1'b0;
                d_rready  = 1'b0;   
                cacop_finish = 1'b0; 
            end
            MISS:begin
                if(d_rlast&&d_rvalid)begin
                    if(uncache_pipe) next_state = WAIT_WRITE;
                    else next_state = REFILL;
                end
                else begin
                    next_state = MISS;
                end
                    mem_we = 32'h0;
                    TagDV_we = 2'h0;
                    d_arvalid = 1'b0;
                    rbuf_we = 1'b0;
                    mbuf_we = 1'b0;
                    wbuf_we = 1'b0;
                    data_from_mem_sel = 1'b1;
                    d_araddr = 32'd0;
                    rready = 1'b0;
                    wready = 1'b0;
                    LRU_update = 1'b0;
                    wfsm_en = 1'b0;
                    wfsm_rset = 1'b0;
                    miss_LRU_update = 1'b0;
                    miss_lru_way = 1'b0;
                    d_rready  = 1'b1;
                    cacop_finish = 1'b0;
            end
            REFILL:begin
                next_state = WAIT_WRITE;
                    mem_we = way_sel == 1'b1 ? 32'hffff0000 : 32'h0000ffff;
                    TagDV_we = way_sel == 1'b1 ? 2'b10:2'b01;
                    d_arvalid = 1'b0;
                    rbuf_we = 1'b0;
                    mbuf_we = 1'b0;
                    wbuf_we = 1'b0;
                    data_from_mem_sel = 1'b1;
                    d_araddr = 32'd0;
                    rready = 1'b0;
                    wready = 1'b0;
                    LRU_update = 1'b0;
                    wfsm_en = 1'b0;
                    wfsm_rset = 1'b0;
                    miss_LRU_update = 1'b1;
                    miss_lru_way = way_sel == 1'b0 ? 1'b0 : 1'b1;
                    d_rready  = 1'b0; 
                    cacop_finish = 1'b0;
            end
            WAIT_WRITE:begin
                if(write_finish)begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_WRITE;
                end
                    mem_we = 32'h0;
                    TagDV_we = 2'b00;
                    d_arvalid = 1'b0;
                    rbuf_we = 1'b0;
                    mbuf_we = 1'b0;
                    wbuf_we = 1'b0;
                    data_from_mem_sel = 1'b1;
                    d_araddr = 32'd0;
                    rready = 1'b0;
                    wready = 1'b0;
                    LRU_update = 1'b0;
                    wfsm_en = 1'b0;
                    wfsm_rset = 1'b0;
                    miss_LRU_update = 1'b0;
                    miss_lru_way = 1'b0;
                    d_rready  = 1'b0; 
                    cacop_finish = 1'b0;
            end
            CACOP_EX:begin
                if(cacop_code_pipe == 2'b00) begin
                    next_state = IDLE;
                    cacop_finish = 1'b1;
                    TagDV_we = address[0] == 1'b0 ? 2'b01 : 2'b10;
                    mbuf_we = 1'b0;
                    wbuf_we = 1'b0;
                    wfsm_en = 1'b0;
                end
                else begin
                    if(cacop_code_pipe == 2'b01) begin
                        next_state = CACOP_EX_WAIT;
                        cacop_finish = 1'b0;
                        TagDV_we = address[0] == 1'b0 ? 2'b01 : 2'b10;
                        mbuf_we = 1'b1;
                        wbuf_we = 1'b1;
                        wfsm_en = 1'b1;
                    end
                    else begin
                        TagDV_we = hit;
                        if(hit != 2'b00) begin
                            mbuf_we = 1'b1;
                            wbuf_we = 1'b1;
                            wfsm_en = 1'b1;
                            next_state = CACOP_EX_WAIT;
                            cacop_finish = 1'b0;
                        end
                        else begin
                            mbuf_we = 1'b0;
                            wbuf_we = 1'b0;
                            wfsm_en = 1'b0;
                            next_state = IDLE;
                            cacop_finish = 1'b1;
                        end
                    end
                end
                mem_we = 32'h0;
                d_arvalid = 1'b0;
                rbuf_we = 1'b0;
                data_from_mem_sel = 1'b1;
                d_araddr = 32'd0;
                rready = 1'b0;
                wready = 1'b0;
                LRU_update = 1'b0;
                wfsm_rset = 1'b0;
                miss_LRU_update = 1'b0;
                miss_lru_way = 1'b0;
                d_rready  = 1'b0;
            end
            CACOP_EX_WAIT:begin
                if(write_finish) begin
                    next_state = IDLE;
                    cacop_finish = 1'b1;
                end
                else begin
                    next_state = CACOP_EX_WAIT;
                    cacop_finish = 1'b0;
                end
                mem_we = 32'h0;
                TagDV_we = 2'b00;
                d_arvalid = 1'b0;
                rbuf_we = 1'b0;
                mbuf_we = 1'b0;
                wbuf_we = 1'b0;
                data_from_mem_sel = 1'b1;
                d_araddr = 32'd0;
                rready = 1'b0;
                wready = 1'b0;
                LRU_update = 1'b0;
                wfsm_en = 1'b0;
                wfsm_rset = 1'b0;
                miss_LRU_update = 1'b0;
                miss_lru_way = 1'b0;
                d_rready  = 1'b0;
            end
            default: begin
                next_state = IDLE;
                mem_we = 32'h0;
                TagDV_we = 2'b00;
                d_arvalid = 1'b0;
                rbuf_we = 1'b0;
                mbuf_we = 1'b0;
                wbuf_we = 1'b0;
                data_from_mem_sel = 1'b1;
                d_araddr = 32'd0;
                rready = 1'b0;
                wready = 1'b0;
                LRU_update = 1'b0;
                wfsm_en = 1'b0;
                wfsm_rset = 1'b0;
                miss_LRU_update = 1'b0;
                miss_lru_way = 1'b0;
                d_rready  = 1'b0;
                cacop_finish = 1'b0;
        end
        endcase
    end

endmodule
