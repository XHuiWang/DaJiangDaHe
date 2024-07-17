`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 21:05:15
// Design Name: 
// Module Name: ID_REG
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

// ISSUE Buffer 
/*
    存储需要发射的解析的指令
    后面的组合逻辑决定怎么发射
*/
import Public_Info::*;

module ID_REG (
    input [ 0: 0] clk,
    input [ 0: 0] rstn,


    input PC_set i_PC_set1,
    input PC_set i_PC_set2,

    input [ 1: 0] i_usingNUM,


    output PC_set o_PC_set1,
    output PC_set o_PC_set2,
    output [ 4: 0] a_rf_raddr1,
    output [ 4: 0] a_rf_raddr2,
    output [ 4: 0] b_rf_raddr1,
    output [ 4: 0] b_rf_raddr2,

    output [ 1: 0] o_is_valid,
    output [ 0: 0] o_is_full
    );

    parameter NUM = 16;

    logic [ 1: 0] i_is_valid;
    assign i_is_valid = {i_PC_set1.o_valid, i_PC_set2.o_valid};

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;
    PC_set PC_set_Buffer[NUM];

    logic [ 6: 0] length; // 缓存数组的长度+将要存入的数据的长度
    logic [ 6: 0] length_left; // 缓存数组的长度
    logic [ 1: 0] length_add; // 将要存入的数据的长度
    logic [ 6: 0] temp_length; // 临时长度,队头减队尾，有可能为负数
    assign temp_length = head - (tail + i_usingNUM);
    assign length_left = temp_length + ((temp_length >= 0) ? 0 : NUM);
    assign length_add  = (i_is_valid[1] ? (i_is_valid[0] ? 2 : 1) : 0 );
    assign length = length_left + length_add;


    logic [ 4: 0] head; // 指针,指示FIFO的队头，即下一个要写入的位置
    logic [ 4: 0] tail; // 指针,指示FIFO的队尾，即下一个要写取的位置
    logic [ 4: 0] next_head; // 下一个队头
    logic [ 4: 0] next_tail; // 下一个队尾
    logic [ 4: 0] head_plus_1; // 第1个装填位置
    logic [ 4: 0] head_plus_2; // 第2个装填位置
    logic [ 4: 0] tail_plus_1; // 第1个取用位置 
    logic [ 4: 0] tail_plus_2; // 第2个取用位置    
    assign next_head   = (head + length_add) - (((head + length_add) >= NUM ? NUM : 0));
    assign head_plus_1 = (head + 1) - ((head + 1 >= NUM ? NUM : 0));
    assign head_plus_2 = (head + 2) - ((head + 2 >= NUM ? NUM : 0));
    assign tail_plus_1 = (tail + 1) - ((tail + 1 >= NUM ? NUM : 0));
    assign tail_plus_2 = (tail + 2) - ((tail + 2 >= NUM ? NUM : 0));


    always @(posedge clk) begin
        case (length_add)
            2'd1: begin
                PC_set_Buffer[head] <= i_PC_set1;
            end
            2'd2: begin
                PC_set_Buffer[head] <= i_PC_set1;
                PC_set_Buffer[head_plus_1] <= i_PC_set2;
            end
            default: begin
                
            end
        endcase
    end


    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            head <= 5'b0;
            tail <= 5'b0;
        end
        else if(flush) begin
            tail <= head;
        end
        else if(stall) begin
            tail <= tail;
            head <= next_head;
        end
        else begin
            tail <= tail + i_usingNUM;
            head <= next_head;
        end
    end

    // o_is_valid 是否有效
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            o_is_valid <= 2'b00;
        end
        else if(flush) begin
            o_is_valid <= 2'b00;
        end
        else if(stall) begin
            o_is_valid <= 2'b00;
        end
        else begin
            case (length)
                7'd0: begin
                    o_is_valid <= 2'b00;
                end
                7'd1: begin
                    o_is_valid <= 2'b10;
                end
                default: begin
                    o_is_valid <= 2'b11;
                end
            endcase
        end
    end

    // o_is_full 是否满
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            o_is_full <= 1'b0;
        end
        else if(length_left > NUM - 4) begin
            o_is_full <= 1'b1;
        end
        else begin
            o_is_full <= 1'b0;
        end
    end

    // 输出固定使用tail的两个，同时根据长度制定o_is_valid
    assign o_PC_set1 = PC_set_Buffer[tail];
    assign o_PC_set2 = PC_set_Buffer[tail_plus_1];

    assign a_rf_raddr1 = PC_set_Buffer[tail].rf_raddr1;
    assign a_rf_raddr2 = PC_set_Buffer[tail].rf_raddr2;
    assign b_rf_raddr1 = PC_set_Buffer[tail_plus_1].rf_raddr1;
    assign b_rf_raddr2 = PC_set_Buffer[tail_plus_1].rf_raddr2;


endmodule
