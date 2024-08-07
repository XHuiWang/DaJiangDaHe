`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/30 10:08:01
// Design Name: 
// Module Name: ID1_ID2_edi2
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


module ID1_ID2_edi2(
    input [ 0: 0] clk,
    input [ 0: 0] rstn,

    input [31: 0] i_PC1,
    input [31: 0] i_IR1,
    input [33: 0] i_brtype_pcpre_1,
    input [ 7: 0] i_ecode_1,

    input [31: 0] i_PC2,
    input [31: 0] i_IR2,
    input [33: 0] i_brtype_pcpre_2,
    input [ 7: 0] i_ecode_2,

    input [ 1: 0] i_is_valid,

    // flush&stall信号
    input [ 0: 0] flush_BR,
    input [ 0: 0] stall_full_issue,

    output logic [31: 0] o_PC1,
    output logic [31: 0] o_IR1,
    output logic [33: 0] o_brtype_pcpre_1,
    output logic [ 7: 0] o_ecode_1,

    output logic [31: 0] o_PC2,
    output logic [31: 0] o_IR2,
    output logic [33: 0] o_brtype_pcpre_2,
    output logic [ 7: 0] o_ecode_2,

    output logic [ 1: 0] o_is_valid,
    output logic [ 0: 0] o_is_full,
    output logic [ 0: 0] ID_status
    );
    assign ID_status = (|o_is_valid);

    localparam NUM = 16;

    logic [ 0: 0] stall; // 停驻信号
    logic [ 0: 0] flush; // 清空信号
    assign flush = flush_BR;
    assign stall = stall_full_issue;

    // head,tail and there derivative signal
    // 每个时钟边缘，head,tail & plus12，length_left同步变化,随后length_Add&&lenth组合变化
    logic [15: 0] a_head;
    logic [15: 0] a_tail;
    logic [15: 0] a_head_plus_1;
    logic [15: 0] a_tail_plus_1;
    logic [ 6: 0] a_length; // 缓存数组的长度+将要存入的数据的长度
    logic [ 6: 0] a_length_left; // 缓存数组的长度
    logic [ 6: 0] a_length_add; // 将要存入的数据的长度
    logic [ 0: 0] a_is_full;

    logic [15: 0] b_head;
    logic [15: 0] b_tail;
    logic [15: 0] b_head_plus_1;
    logic [15: 0] b_tail_plus_1;
    logic [ 6: 0] b_length; // 缓存数组的长度+将要存入的数据的长度
    logic [ 6: 0] b_length_left; // 缓存数组的长度
    logic [ 6: 0] b_length_add; // 将要存入的数据的长度
    logic [ 0: 0] b_is_full;

    // 一些代表IO状态的信号
    logic [ 0: 0] Input_status;  // 0->a, 1->b,0代表首先要传向A通道
    logic [ 0: 0] Output_status; // 0->a, 1->b,0代表首先要从A通道取

    // 使用数组循环队列实现
    logic [31: 0] a_PC_Buffer[0:NUM-1];
    logic [31: 0] a_IR_Buffer[0:NUM-1];
    logic [33: 0] a_brtype_pcpre_Buffer[0:NUM-1];
    logic [ 7: 0] a_ecode_Buffer[0:NUM-1];

    logic [31: 0] b_PC_Buffer[0:NUM-1];
    logic [31: 0] b_IR_Buffer[0:NUM-1];
    logic [33: 0] b_brtype_pcpre_Buffer[0:NUM-1];
    logic [ 7: 0] b_ecode_Buffer[0:NUM-1];

    // 一些维护的信号
    assign a_length_add = ((i_is_valid == 2'b10 && ~Input_status) | (i_is_valid == 2'b11)) ? 7'd1 : 7'd0;
    assign b_length_add = ((i_is_valid == 2'b10 &&  Input_status) | (i_is_valid == 2'b11)) ? 7'd1 : 7'd0;
    assign a_length = a_length_left + a_length_add;
    assign b_length = b_length_left + b_length_add;
    assign a_is_full = |(a_length[ 6: 4]) ? 1'b1 : 1'b0;
    assign b_is_full = |(b_length[ 6: 4]) ? 1'b1 : 1'b0;

    assign a_head_plus_1 = {a_head[14: 0], a_head[15]};
    assign a_tail_plus_1 = {a_tail[14: 0], a_tail[15]};
    assign b_head_plus_1 = {b_head[14: 0], b_head[15]};
    assign b_tail_plus_1 = {b_tail[14: 0], b_tail[15]};

    // 读取数组和输入数组的实现
    logic [31: 0] a_tail_PC;
    logic [31: 0] a_tail_IR;
    logic [33: 0] a_tail_brtype_pcpre;
    logic [ 7: 0] a_tail_ecode;
    logic [31: 0] b_tail_PC;
    logic [31: 0] b_tail_IR;
    logic [33: 0] b_tail_brtype_pcpre;
    logic [ 7: 0] b_tail_ecode;

    function void Write_Array_A(
        input [15: 0] pointer,
        input [31: 0] PC,
        input [31: 0] IR,
        input [33: 0] brtype_pcpre,
        input [ 7: 0] ecode
    );
        for(integer i = 0; i < NUM; i++) begin
            if(pointer[i]) begin
                a_PC_Buffer[i] <= PC;
                a_IR_Buffer[i] <= IR;
                a_brtype_pcpre_Buffer[i] <= brtype_pcpre;
                a_ecode_Buffer[i] <= ecode;
            end
        end
    endfunction
    function void Write_Array_B(
        input [15: 0] pointer,
        input [31: 0] PC,
        input [31: 0] IR,
        input [33: 0] brtype_pcpre,
        input [ 7: 0] ecode
    );
        for(integer i = 0; i < NUM; i++) begin
            if(pointer[i]) begin
                b_PC_Buffer[i] <= PC;
                b_IR_Buffer[i] <= IR;
                b_brtype_pcpre_Buffer[i] <= brtype_pcpre;
                b_ecode_Buffer[i] <= ecode;
            end
        end
    endfunction

    ID1_ID2_readMUX # (
        .NUM(NUM)
    )
    ID1_ID2_readMUX_inst (
        .a_tail(a_tail),
        .b_tail(b_tail),
        .a_PC_Buffer(a_PC_Buffer),
        .a_IR_Buffer(a_IR_Buffer),
        .a_brtype_pcpre_Buffer(a_brtype_pcpre_Buffer),
        .a_ecode_Buffer(a_ecode_Buffer),
        .b_PC_Buffer(b_PC_Buffer),
        .b_IR_Buffer(b_IR_Buffer),
        .b_brtype_pcpre_Buffer(b_brtype_pcpre_Buffer),
        .b_ecode_Buffer(b_ecode_Buffer),
        .a_tail_PC(a_tail_PC),
        .a_tail_IR(a_tail_IR),
        .a_tail_brtype_pcpre(a_tail_brtype_pcpre),
        .a_tail_ecode(a_tail_ecode),
        .b_tail_PC(b_tail_PC),
        .b_tail_IR(b_tail_IR),
        .b_tail_brtype_pcpre(b_tail_brtype_pcpre),
        .b_tail_ecode(b_tail_ecode)
    );


    always @(posedge clk) begin
        if( !rstn ) begin
            a_head <= 0;
            a_tail <= 0;
            a_length_left <= 0;

            b_head <= 0;
            b_tail <= 0;
            b_length_left <= 0;

            o_PC1 <= 32'h0000_0000;
            o_IR1 <= 32'h0000_0000;
            o_PC2 <= 32'h0000_0000;
            o_IR2 <= 32'h0000_0000;
            o_brtype_pcpre_1 <= 34'h0_0000_0000;
            o_brtype_pcpre_2 <= 34'h0_0000_0000;
            o_ecode_1 <= 8'h00;
            o_ecode_2 <= 8'h00;

            for(integer i = 0; i < NUM; i++) begin
                a_PC_Buffer[i] <= 32'h0000_0000;
                a_IR_Buffer[i] <= 32'h0000_0000;
                a_brtype_pcpre_Buffer[i] <= 34'h0_0000_0000;
                a_ecode_Buffer[i] <= 8'h00;

                b_PC_Buffer[i] <= 32'h0000_0000;
                b_IR_Buffer[i] <= 32'h0000_0000;
                b_brtype_pcpre_Buffer[i] <= 34'h0_0000_0000;
                b_ecode_Buffer[i] <= 8'h00;
            end
        end
        else if (flush) begin
            a_head <= 0;
            a_tail <= 0;
            a_length_left <= 0;

            b_head <= 0;
            b_tail <= 0;
            b_length_left <= 0;            
        end

        else if(stall) begin
            // 写入，不写出
            a_tail <= a_tail;
            a_length_left <= a_length;
            b_tail <= b_tail;
            b_length_left <= b_length;
            if(a_length_add[0]) begin
                // 确认A通道写入
                a_head <= a_head_plus_1;
                if(Input_status) begin
                    // B先写，则一定从2号通道写
                    Write_Array_A(a_head, i_PC2, i_IR2, i_brtype_pcpre_2, i_ecode_2);
                end
                else begin
                    // 其他
                    Write_Array_A(a_head, i_PC1, i_IR1, i_brtype_pcpre_1, i_ecode_1);
                end
            end
            else begin
                a_head <= a_head;
            end
            if(b_length_add[0]) begin
                // 确认B通道写入
                b_head <= b_head_plus_1;
                if(~Input_status) begin
                    // A先写，则一定从2号通道写
                    Write_Array_B(b_head, i_PC2, i_IR2, i_brtype_pcpre_2, i_ecode_2);
                end
                else begin
                    // 其他
                    Write_Array_B(b_head, i_PC1, i_IR1, i_brtype_pcpre_1, i_ecode_1);
                end
            end
            else begin
                b_head <= b_head;
            end
        end
        else begin
            // 有进有出
            if(|a_length) begin
                a_tail <= a_tail_plus_1;
                a_length_left <= a_length - 1;
            end
            else begin
                a_tail <= a_tail;
                a_length_left <= a_length;
            end
            if(|b_length) begin
                b_tail <= b_tail_plus_1;
                b_length_left <= b_length - 1;
            end
            else begin
                b_tail <= b_tail;
                b_length_left <= b_length;
            end

            if(a_length_add[0]) begin
                // 确认A通道写入
                a_head <= a_head_plus_1;
                if(Input_status) begin
                    // B先写，则一定从2号通道写
                    Write_Array_A(a_head, i_PC2, i_IR2, i_brtype_pcpre_2, i_ecode_2);
                end
                else begin
                    // 其他
                    Write_Array_A(a_head, i_PC1, i_IR1, i_brtype_pcpre_1, i_ecode_1);
                end
            end
            else begin
                a_head <= a_head;
            end
            if(b_length_add[0]) begin
                // 确认B通道写入
                b_head <= b_head_plus_1;
                if(~Input_status) begin
                    // A先写，则一定从2号通道写
                    Write_Array_B(b_head, i_PC2, i_IR2, i_brtype_pcpre_2, i_ecode_2);
                end
                else begin
                    // 其他
                    Write_Array_B(b_head, i_PC1, i_IR1, i_brtype_pcpre_1, i_ecode_1);
                end
            end
            else begin
                b_head <= b_head;
            end
        end
    end


    // Input_status的确定,Output_status的确定
    always @(posedge clk) begin
        if( !rstn ) begin
            Input_status <= 0;
            Output_status <= 0;
        end
        else if(flush) begin
            Input_status <= 0;
            Output_status <= 0;
        end
        else if(stall) begin
            Input_status <= (&i_is_valid) ? Input_status : ~Input_status;
            Output_status <= Output_status;
        end
        else begin
            Input_status <= (&i_is_valid) ? Input_status : ~Input_status;
            Output_status <= ((|a_length) ^ (|b_length)) ? ~Output_status : Output_status;
        end
    end

    // o_is_full
    assign o_is_full = (a_is_full | b_is_full) ? 1'b1 : 1'b0;

    // o_is_valid 是否有效
    assign o_is_valid = (|a_length) ? (|b_length) ? 2'b11 : 2'b10 : (|b_length) ? 2'b10 : 2'b00;

    // 输出
    always @(*) begin
        if(~Output_status) begin
            // 从A通道取
            o_PC1 <= a_tail_PC;
            o_IR1 <= a_tail_IR;
            o_brtype_pcpre_1 <= a_tail_brtype_pcpre;
            o_ecode_1 <= a_tail_ecode;
            o_PC2 <= b_tail_PC;
            o_IR2 <= b_tail_IR;
            o_brtype_pcpre_2 <= b_tail_brtype_pcpre;
            o_ecode_2 <= b_tail_ecode;
        end
        else begin
            // 从B通道取
            o_PC1 <= b_tail_PC;
            o_IR1 <= b_tail_IR;
            o_brtype_pcpre_1 <= b_tail_brtype_pcpre;
            o_ecode_1 <= b_tail_ecode;
            o_PC2 <= a_tail_PC;
            o_IR2 <= a_tail_IR;
            o_brtype_pcpre_2 <= a_tail_brtype_pcpre;
            o_ecode_2 <= a_tail_ecode;
        end    
    end




endmodule
