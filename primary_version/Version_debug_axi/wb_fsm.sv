`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/05 12:39:36
// Design Name: 
// Module Name: wb_fsm
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


module wb_fsm(
    input               clk,
    input               rstn,
    input               wfsm_en,
    input               wfsm_rset,
    input               d_wready,
    input               d_bvalid,
    input               d_awready,
    input               dirty,
    input               uncache_pipe,
    output   reg        write_finish,
    output   reg        d_awvalid,
    output   reg        d_wvalid,
    output   reg        d_wlast,
    output   reg        d_bready
    );

    reg [1:0]  current_state;
    reg [1:0]  next_state;
    //FSM_ENCODE
    parameter IDLE = 3'h0;
    parameter WRITE = 3'h1;
    parameter FINISH = 3'h2;
    parameter WRITE_A = 3'h3;
    //state change
    always @(posedge clk)begin
        if(!rstn) current_state <= IDLE;
        else current_state <= next_state;
    end


    reg [5:0]  q;
    always @(posedge clk) begin
        if(current_state == IDLE) q <= 6'd0;
        else if(d_wready) q <= q+1;
    end

    always @(*) begin
        case(current_state)
            IDLE:begin
                if(wfsm_en&&(dirty||uncache_pipe)) next_state = WRITE_A;
                else next_state = IDLE;
                write_finish = 1'b1;
                d_wvalid = 1'b0;
                d_wlast = 1'b0;
                d_bready = 1'b0;
                d_awvalid = 1'b0;
            end
            WRITE_A:begin
                if(d_awready) next_state = WRITE;
                else next_state = WRITE_A;
                write_finish = 1'b0;
                d_wvalid = 1'b0;
                d_wlast = 1'b0;
                d_bready = 1'b0;
                d_awvalid = 1'b1;   
            end
            WRITE:begin
                if(d_bready&&d_bvalid) next_state = FINISH;
                else next_state = WRITE;
                write_finish = 1'b0;
                d_wvalid = 1'b1;
                d_awvalid = 1'b0;
                if(uncache_pipe) begin
                    if(q == 6'd0)begin
                        //q == 0 发送最后一个数据
                        d_wlast = 1'b1;
                        d_bready = 1'b0;
                    end
                    else if (q == 6'd1)begin
                        //q == 1 拉高d_bready 
                        d_wlast = 1'b0;
                        d_bready = 1'b1;
                    end
                    else begin
                        d_wlast = 1'b0;
                        d_bready = 1'b0;
                    end
                end
                else begin
                    if(q == 6'd3)begin
                        //q == 3 发送最后一个数据
                        d_wlast = 1'b1;
                        d_bready = 1'b0;
                    end
                    else if (q == 6'd4)begin
                        //q == 4 拉高d_bready 
                        d_wlast = 1'b0;
                        d_bready = 1'b1;
                    end
                    else begin
                        d_wlast = 1'b0;
                        d_bready = 1'b0;
                    end
                end
            end
            FINISH:begin
                if(wfsm_rset) next_state = IDLE;
                else next_state = FINISH;
                write_finish = 1'b1;
                d_wvalid = 1'b0;
                d_wlast = 1'b0;
                d_bready = 1'b0;
                d_awvalid = 1'b0;
            end
        endcase
    end
endmodule
