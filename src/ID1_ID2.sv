`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/15 16:47:11
// Design Name: 
// Module Name: IF2_ID1
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

/*
    * 该模块用于IF2_ID1阶段的数据传递
    * 输入：Fetch阶段的两对PC值、IR值、is_valid信号决定哪一对有效，用于Buffer的填充
        is_valid: 11 双有效
                    10 第一对有效
                    01 无效
                    00 无效
    * 输出：传递给Decoder阶段的；两对PC值、IR值、o_is_valid决定哪一对有效
            o_is_full传递给IF阶段，使之在能够继续取指令的情况下（同时Cache没有Miss）停驻————希望只缓存一个周期

    * 缓存数组： 32位*N个元素，PC和IR分别一个
*/
module ID1_ID2(
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

    logic [ 1: 0] is_valid;
    assign is_valid = i_is_valid;



    parameter NUM = 16;

    logic [ 0: 0] stall; // 停驻信号
    logic [ 0: 0] flush; // 清空信号
    assign flush = flush_BR;
    assign stall = stall_full_issue;

    logic [ 4: 0] head; // 指针,指示FIFO的队头，即下一个要写入的位置
    logic [ 4: 0] tail; // 指针,指示FIFO的队尾，即下一个要写取的位置
    logic [ 4: 0] next_head; // 下一个队头
    logic [ 4: 0] next_tail; // 下一个队尾
    logic [ 4: 0] head_plus_1; // 第1个装填位置
    logic [ 4: 0] head_plus_2; // 第2个装填位置
    logic [ 4: 0] tail_plus_1; // 第1个取用位置
    logic [ 4: 0] tail_plus_2; // 第2个取用位置
    
    logic [ 6: 0] length; // 缓存数组的长度+将要存入的数据的长度
    logic [ 6: 0] length_left; // 缓存数组的长度
    logic [ 1: 0] length_add; // 将要存入的数据的长度
    logic [ 6: 0] temp_length; // 临时长度,队头减队尾，有可能为负数



    // 使用数组循环队列实现
    logic [31: 0] PC_Buffer[0:NUM-1];
    logic [31: 0] IR_Buffer[0:NUM-1];
    logic [33: 0] brtype_pcpre_Buffer[0:NUM-1];
    logic [ 7: 0] ecode_Buffer[0:NUM-1];
    

    assign next_head   = (head + length_add) - (((head + length_add) >= NUM ? NUM : 0));
    assign head_plus_1 = (head + 1) - ((head + 1 >= NUM ? NUM : 0));
    assign head_plus_2 = (head + 2) - ((head + 2 >= NUM ? NUM : 0));
    assign tail_plus_1 = (tail + 1) - ((tail + 1 >= NUM ? NUM : 0));
    assign tail_plus_2 = (tail + 2) - ((tail + 2 >= NUM ? NUM : 0));

    assign temp_length = head - tail;
    assign length_left = temp_length + ((temp_length[6] == 0) ? 0 : NUM);
    assign length_add  = (is_valid[1] ? (is_valid[0] ? 2 : 1) : 0 );
    assign length = length_left + length_add;

    logic [ 0: 0] signal_length_eq_1; // 信号长度是否等于1
    assign signal_length_eq_1 = (length == 1);
    assign ID_status = (|o_is_valid);


    // head
    always @(posedge clk) begin
        if( !rstn ) begin
            head <= 5'd0;
        end
        else if(flush) begin
            head <= 5'd0;
        end
        else if(stall) begin
            head <= next_head;
        end
        else begin
            if( !(|length) || signal_length_eq_1 || length == 2) begin
                head <= 5'd0;
            end
            else if(length == 3 && length_add == 2) begin
                head <= head;
            end
            else begin
                head <= next_head;
            end
        end
    end

    // tail
    always @(posedge clk) begin
        if( !rstn ) begin
            tail <= 5'd0;
        end
        else if(flush) begin
            tail <= 5'd0;
        end
        else if(stall) begin
            tail <= tail;
        end
        else begin
            if( !(|length) || signal_length_eq_1 || length == 2) begin
                tail <= 5'd0;
            end
            else if(length == 3 && length_add == 2) begin
                tail <= tail;
            end
            else begin
                tail <= tail_plus_2;
            end
        end
    end

    // output
    always @(posedge clk) begin
        if( !rstn ) begin
            o_PC1 <= 32'h0000_0000;
            o_IR1 <= 32'h0000_0000;
            o_PC2 <= 32'h0000_0000;
            o_IR2 <= 32'h0000_0000;
            o_brtype_pcpre_1 <= 34'h0_0000_0000;
            o_brtype_pcpre_2 <= 34'h0_0000_0000;
            o_ecode_1 <= 8'h00;
            o_ecode_2 <= 8'h00;
        end
        else if(stall | !(|length)) begin
            o_PC1 <= o_PC1;
            o_IR1 <= o_IR1;
            o_PC2 <= o_PC2;
            o_IR2 <= o_IR2;
            o_brtype_pcpre_1 <= o_brtype_pcpre_1;
            o_brtype_pcpre_2 <= o_brtype_pcpre_2;
            o_ecode_1 <= o_ecode_1;
            o_ecode_2 <= o_ecode_2;
        end
        else begin
            if(signal_length_eq_1) begin
                if(!(|length_left)) begin
                    o_PC1 <= i_PC1;
                    o_IR1 <= i_IR1;
                    o_brtype_pcpre_1 <= i_brtype_pcpre_1;
                    o_ecode_1 <= i_ecode_1;
                end
                else begin
                    o_PC1 <= PC_Buffer[tail];
                    o_IR1 <= IR_Buffer[tail];
                    o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
                    o_ecode_1 <= ecode_Buffer[tail];
                end
            end
            else if(length == 2) begin
                // 2对有效
                if(is_valid[1]) begin
                    if(is_valid[0]) begin
                        o_PC1 <= i_PC1;
                        o_IR1 <= i_IR1;
                        o_brtype_pcpre_1 <= i_brtype_pcpre_1;
                        o_ecode_1 <= i_ecode_1;
                        o_PC2 <= i_PC2;
                        o_IR2 <= i_IR2;
                        o_brtype_pcpre_2 <= i_brtype_pcpre_2;
                        o_ecode_2 <= i_ecode_2;
                    end
                    else begin
                        o_PC1 <= PC_Buffer[tail];
                        o_IR1 <= IR_Buffer[tail];
                        o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
                        o_ecode_1 <= ecode_Buffer[tail];
                        o_PC2 <= i_PC1;
                        o_IR2 <= i_IR1;
                        o_brtype_pcpre_2 <= i_brtype_pcpre_1;
                        o_ecode_2 <= i_ecode_1;
                    end
                end
                else begin
                    o_PC1 <= PC_Buffer[tail];
                    o_IR1 <= IR_Buffer[tail];
                    o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
                    o_ecode_1 <= ecode_Buffer[tail];
                    o_PC2 <= PC_Buffer[tail_plus_1];
                    o_IR2 <= IR_Buffer[tail_plus_1];
                    o_brtype_pcpre_2 <= brtype_pcpre_Buffer[tail_plus_1];
                    o_ecode_2 <= ecode_Buffer[tail_plus_1];
                end
            end
            else if(length == 3 && length_add == 2) begin
                o_PC1 <= PC_Buffer[tail];
                o_IR1 <= IR_Buffer[tail];
                o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
                o_ecode_1 <= ecode_Buffer[tail];
                o_PC2 <= i_PC1;
                o_IR2 <= i_IR1;
                o_brtype_pcpre_2 <= i_brtype_pcpre_1;
                o_ecode_2 <= i_ecode_1;
            end
            else begin
                // 有剩余
                o_PC1 <= PC_Buffer[tail];
                o_IR1 <= IR_Buffer[tail];
                o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
                o_ecode_1 <= ecode_Buffer[tail];
                o_PC2 <= PC_Buffer[tail_plus_1];
                o_IR2 <= IR_Buffer[tail_plus_1];
                o_brtype_pcpre_2 <= brtype_pcpre_Buffer[tail_plus_1];
                o_ecode_2 <= ecode_Buffer[tail_plus_1];
            end
        end
    end

    // Buffer
    always @(posedge clk) begin
        if( !rstn ) begin
            // Reset condition
            for(integer i = 0; i < NUM; i++) begin
                PC_Buffer[i] <= 32'h0000_0000;
                IR_Buffer[i] <= 32'h0000_0000;
                brtype_pcpre_Buffer[i] <= 34'h0_0000_0000;
                ecode_Buffer[i] <= 8'h00;
            end
        end
        else if(stall) begin
            // 写入，不写出
            case (length_add)
                2'd0: begin
                    // 无效
                end
                2'd1: begin
                    // 1对有效
                    PC_Buffer[head] <= i_PC1;
                    IR_Buffer[head] <= i_IR1;
                    brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
                    ecode_Buffer[head] <= i_ecode_1;
                end
                2'd2: begin
                    // 2对有效
                    PC_Buffer[head] <= i_PC1;
                    IR_Buffer[head] <= i_IR1;
                    brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
                    ecode_Buffer[head] <= i_ecode_1;
                    PC_Buffer[head_plus_1] <= i_PC2;
                    IR_Buffer[head_plus_1] <= i_IR2;
                    brtype_pcpre_Buffer[head_plus_1] <= i_brtype_pcpre_2;
                    ecode_Buffer[head_plus_1] <= i_ecode_2;
                end
                default: begin
                    // 无效
                end
                
            endcase
        end
        else begin
            if(signal_length_eq_1 || length == 2 || !(|length)) begin
                
            end
            else if(length == 3 && length_add == 2)begin
                PC_Buffer[tail] <= i_PC2;
                IR_Buffer[tail] <= i_IR2;
                brtype_pcpre_Buffer[tail] <= i_brtype_pcpre_2;
                ecode_Buffer[tail] <= i_ecode_2;
            end
            else begin
                case (length_add)
                2'd0: begin
                    // 无效
                end
                2'd1: begin
                    // 1对有效
                    PC_Buffer[head] <= i_PC1;
                    IR_Buffer[head] <= i_IR1;
                    brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
                    ecode_Buffer[head] <= i_ecode_1;
                end
                2'd2: begin
                    // 2对有效
                    PC_Buffer[head] <= i_PC1;
                    IR_Buffer[head] <= i_IR1;
                    brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
                    ecode_Buffer[head] <= i_ecode_1;
                    PC_Buffer[head_plus_1] <= i_PC2;
                    IR_Buffer[head_plus_1] <= i_IR2;
                    brtype_pcpre_Buffer[head_plus_1] <= i_brtype_pcpre_2;
                    ecode_Buffer[head_plus_1] <= i_ecode_2;
                end
                default: begin
                    // 无效
                end
                endcase
            end
        
        end
    end


    // o_is_valid 是否有效
    always @(posedge clk) begin
        if( !rstn ) begin
            o_is_valid <= 2'b00;
        end
        else if ( stall || flush ) begin
            o_is_valid <= 2'b00;
        end
        else begin
            // 要写入
            if( !(|length) ) begin
                // length == 0
                o_is_valid <= 2'b00;
            end
            else if( signal_length_eq_1 ) begin
                // length == 1
                o_is_valid <= 2'b10;
            end
            else begin
                // length == 2
                o_is_valid <= 2'b11;
            end
        end
    end

    // o_is_full 是否满
    always @(posedge clk) begin
        if( !rstn ) begin
            o_is_full <= 1'b0;
        end
        else if(length_left >= NUM - 6) begin
            o_is_full <= 1'b1;
        end
        else begin
            o_is_full <= 1'b0;
        end
        
    end

endmodule

    // always @(posedge clk) begin
    //     if( !rstn ) begin
    //         // Reset condition
    //         head <= 5'd0;
    //         tail <= 5'd0;
    //         o_PC1 <= 32'h0000_0000;
    //         o_IR1 <= 32'h0000_0000;
    //         o_PC2 <= 32'h0000_0000;
    //         o_IR2 <= 32'h0000_0000;
    //         o_brtype_pcpre_1 <= 34'h0_0000_0000;
    //         o_brtype_pcpre_2 <= 34'h0_0000_0000;
    //         for(integer i = 0; i < NUM; i++) begin
    //             PC_Buffer[i] <= 32'h0000_0000;
    //             IR_Buffer[i] <= 32'h0000_0000;
    //             brtype_pcpre_Buffer[i] <= 34'h0_0000_0000;
    //         end
    //     end
    //     else if(flush) begin
    //         tail <= 5'd0;
    //         head <= 5'd0;
    //     end
    //     else if(stall) begin
    //         // 写入，不写出
    //         head <= next_head;
    //         case (length_add)
    //             2'd0: begin
    //                 // 无效
    //             end
    //             2'd1: begin
    //                 // 1对有效
    //                 PC_Buffer[head] <= i_PC1;
    //                 IR_Buffer[head] <= i_IR1;
    //                 brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
    //             end
    //             2'd2: begin
    //                 // 2对有效
    //                 PC_Buffer[head] <= i_PC1;
    //                 IR_Buffer[head] <= i_IR1;
    //                 brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
    //                 PC_Buffer[head_plus_1] <= i_PC2;
    //                 IR_Buffer[head_plus_1] <= i_IR2;
    //                 brtype_pcpre_Buffer[head_plus_1] <= i_brtype_pcpre_2;
    //             end
    //             default: begin
    //                 // 无效
    //             end
                
    //         endcase
    //     end
    //     else begin
    //         // 写入，根据总数写出
    //         if(!(|length)) begin
    //             // 无效
    //             head <= 0;
    //             tail <= 0;
    //         end
    //         else if(signal_length_eq_1 || length == 2 ) begin
    //             head <= 0;
    //             tail <= 0;
    //             if(signal_length_eq_1) begin
    //                 // 1对有效
    //                 if(!(|length_left)) begin
    //                     o_PC1 <= i_PC1;
    //                     o_IR1 <= i_IR1;
    //                     o_brtype_pcpre_1 <= i_brtype_pcpre_1;
    //                 end
    //                 else begin
    //                     o_PC1 <= PC_Buffer[tail];
    //                     o_IR1 <= IR_Buffer[tail];
    //                     o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
    //                 end
    //             end
    //             else begin
    //                 // 2对有效
    //                 if(is_valid[1]) begin
    //                     if(is_valid[0]) begin
    //                         o_PC1 <= i_PC1;
    //                         o_IR1 <= i_IR1;
    //                         o_brtype_pcpre_1 <= i_brtype_pcpre_1;
    //                         o_PC2 <= i_PC2;
    //                         o_IR2 <= i_IR2;
    //                         o_brtype_pcpre_2 <= i_brtype_pcpre_2;
    //                     end
    //                     else begin
    //                         o_PC1 <= PC_Buffer[tail];
    //                         o_IR1 <= IR_Buffer[tail];
    //                         o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
    //                         o_PC2 <= i_PC1;
    //                         o_IR2 <= i_IR1;
    //                         o_brtype_pcpre_2 <= i_brtype_pcpre_1;
    //                     end
    //                 end
    //                 else begin
    //                     o_PC1 <= PC_Buffer[tail];
    //                     o_IR1 <= IR_Buffer[tail];
    //                     o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
    //                     o_PC2 <= PC_Buffer[tail_plus_1];
    //                     o_IR2 <= IR_Buffer[tail_plus_1];
    //                     o_brtype_pcpre_2 <= brtype_pcpre_Buffer[tail_plus_1];
    //                 end
    //             end
    //         end
                // else if (length == 3 && length_add == 2) begin
                //     head <= head;
                //     tail <= tail;
                //     o_PC1 <= PC_Buffer[tail];
                //     o_PC2 <= i_PC1;
                //     PC_Buffer[tail] <= i_PC2;
                // end
    //         else begin
    //             // 有剩余
    //             head <= next_head;
    //             tail <= tail_plus_2;
    //             // 写入抉择
    //             case (length_add)
    //             2'd0: begin
    //                 // 无效
    //             end
    //             2'd1: begin
    //                 // 1对有效
    //                 PC_Buffer[head] <= i_PC1;
    //                 IR_Buffer[head] <= i_IR1;
    //                 brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
    //             end
    //             2'd2: begin
    //                 // 2对有效
    //                 PC_Buffer[head] <= i_PC1;
    //                 IR_Buffer[head] <= i_IR1;
    //                 brtype_pcpre_Buffer[head] <= i_brtype_pcpre_1;
    //                 PC_Buffer[head_plus_1] <= i_PC2;
    //                 IR_Buffer[head_plus_1] <= i_IR2;
    //                 brtype_pcpre_Buffer[head_plus_1] <= i_brtype_pcpre_2;
    //             end
    //             default: begin
    //                 // 无效
    //             end
    //             endcase
    //             //写出抉择
    //             o_PC1 <= PC_Buffer[tail];
    //             o_IR1 <= IR_Buffer[tail];
    //             o_brtype_pcpre_1 <= brtype_pcpre_Buffer[tail];
    //             o_PC2 <= PC_Buffer[tail_plus_1];
    //             o_IR2 <= IR_Buffer[tail_plus_1];
    //             o_brtype_pcpre_2 <= brtype_pcpre_Buffer[tail_plus_1];
    //         end
    //     end
    // end
