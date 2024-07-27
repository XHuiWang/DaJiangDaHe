`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 17:20:54
// Design Name: 
// Module Name: FSM_icache
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


module FSM_icache(
    input                 clk,
    input                 rstn,
    input     [1:0]       hit,
    input                 rvalid,
    input                 i_rvalid,
    input                 i_rlast,
    input                 i_arready,
    input     [31:0]      addr,
    input                 way_sel,
    output   reg          rready,
    output   reg          i_arvalid,
    output   reg          i_rready,
    output   reg  [1:0]   mem_we,
    output   reg  [1:0]   TagV_we,
    output   reg          rbuf_we,
    output   reg          data_from_mem_sel,
    output   reg  [31:0]  i_araddr,
    output   reg          LRU_update,
    output   reg          fbuf_clear,
    output   reg          miss_lru_way,
    output   reg          miss_LRU_update
);

    reg [2:0]  current_state;
    reg [2:0]  next_state;
    //FSM_ENCODE
    parameter IDLE = 3'h0;
    parameter LOOKUP = 3'h1;
    parameter MISS = 3'h2;//数据确认状态
    parameter REFILL = 3'h3;
    parameter MISS_A = 3'h4;//地址确认状态
    //state change
    always @(posedge clk,negedge rstn)begin
        if(!rstn) current_state <= IDLE;
        else current_state <= next_state;
    end

    always @(*) begin
        case(current_state)
            IDLE:begin
                if(rvalid) next_state = LOOKUP;
                else next_state = IDLE;
                /*---*/
                rready = 1'b1;
                i_arvalid = 1'b0;
                mem_we = 2'b00;
                TagV_we = 2'b00;
                rbuf_we = 1'b1;
                data_from_mem_sel =  1'b1;
                i_araddr = 32'd0;
                i_rready = 1'b0;
                LRU_update = 1'b0;
                fbuf_clear = 1'b1;
                miss_lru_way = 1'b0;
                miss_LRU_update = 1'b0;
            end
            LOOKUP:begin
                if((hit!=2'h0) && rvalid) begin
                    next_state = LOOKUP;
                    rready = 1'b1;
                    i_arvalid = 1'b0;
                    mem_we = 2'b00;
                    TagV_we = 2'b00;
                    rbuf_we = 1'b1;
                    data_from_mem_sel =  1'b0;
                    i_araddr = 32'd0;
                    i_rready = 1'b0;
                    LRU_update = 1'b1;
                    fbuf_clear = 1'b1;
                    miss_lru_way = 1'b0;
                    miss_LRU_update = 1'b0;
                end
                else if((hit!=2'h0) && !rvalid) begin
                    next_state = IDLE;
                    rready = 1'b1;
                    i_arvalid = 1'b0;
                    mem_we = 2'b00;
                    TagV_we = 2'b00;
                    rbuf_we = 1'b1;
                    data_from_mem_sel =  1'b0;
                    i_araddr = 32'd0;
                    i_rready = 1'b0;
                    LRU_update = 1'b1;
                    fbuf_clear = 1'b1;
                    miss_lru_way = 1'b0;
                    miss_LRU_update = 1'b0;
                end
                else begin 
                    next_state = MISS_A;
                    rready = 1'b0;
                    i_arvalid = 1'b0;
                    mem_we = 2'b00;
                    TagV_we = 2'b00;
                    rbuf_we = 1'b0;
                    data_from_mem_sel =  1'b1;
                    i_araddr = 32'd0;
                    i_rready = 1'b0;
                    LRU_update = 1'b0;
                    fbuf_clear = 1'b0;
                    miss_lru_way = 1'b0;
                    miss_LRU_update = 1'b0;
                end
            end
            MISS_A:begin
                if(i_arready) next_state = MISS;
                else next_state = MISS_A;
                rready = 1'b0;
                i_arvalid = 1'b1;
                mem_we = 2'b00;
                TagV_we = 2'b00;
                rbuf_we = 1'b0;
                data_from_mem_sel =  1'b1;
                i_araddr = {addr[31:4],4'd0};
                i_rready = 1'b0;
                LRU_update = 1'b0;
                fbuf_clear = 1'b0;
                miss_lru_way = 1'b0;
                miss_LRU_update = 1'b0;
            end
            MISS:begin
                if(i_rvalid&&i_rlast)begin
                    next_state = REFILL;
                end 
                else begin 
                    next_state = MISS;
                end
                rready = 1'b0;
                i_arvalid = 1'b0;
                mem_we = 2'b00;
                TagV_we = 2'b00;
                rbuf_we = 1'b0;
                data_from_mem_sel =  1'b1;
                i_araddr = 32'd0;
                i_rready = 1'b1;
                LRU_update = 1'b0;
                fbuf_clear = 1'b0;
                miss_lru_way = 1'b0;
                miss_LRU_update = 1'b0;
            end
            REFILL:begin
                next_state = IDLE;
                rready = 1'b0;
                i_arvalid = 1'b0;
                mem_we = way_sel == 1'b0 ? 2'b01 : 2'b10;
                TagV_we = way_sel == 1'b0 ? 2'b01 : 2'b10;
                rbuf_we = 1'b0;
                data_from_mem_sel =  1'b1;
                i_araddr = 32'd0;
                i_rready = 1'b0;
                LRU_update = 1'b0;
                fbuf_clear = 1'b0;
                miss_lru_way = way_sel == 1'b0 ? 1'b0 : 1'b1;
                miss_LRU_update = 1'b1;
            end
            default:begin
                next_state = IDLE;
                rready = 1'b0;
                i_arvalid = 1'b0;
                mem_we = 2'b00;
                TagV_we = 2'b00;
                rbuf_we = 1'b0;
                data_from_mem_sel =  1'b1;
                i_araddr = 32'd0;
                i_rready = 1'b0;
                LRU_update = 1'b0;
                fbuf_clear = 1'b0;
                miss_lru_way = 1'b0;
                miss_LRU_update = 1'b0;
            end
        endcase
    end
endmodule
