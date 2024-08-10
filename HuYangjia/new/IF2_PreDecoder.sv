`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/22 18:20:28
// Design Name: 
// Module Name: IF2_PreDecoder
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


module IF2_PreDecoder(
    input [31: 0] IF_IR,
    input [31: 0] PC,
    input [31: 0] PC_plus_4,
    input [33: 0] brtype_pcpre,
    input [ 0: 0] data_valid,
    
    output logic [ 0: 0] o_valid, // 是否跳转
    output logic [31: 0] PC_fact,
    output logic [33: 0] type_pcpre
    );
    logic [ 1: 0] br_type;
    logic [31: 0] PC_pre;
    logic [ 1: 0] type_predict;
    logic [31: 0] PC_pre_already; // 用于预测分支时得到的预测PC
    assign type_predict = brtype_pcpre[33:32];
    assign PC_pre_already = brtype_pcpre[31: 0];
    
    logic [ 0: 0] beq_inst;
    logic [ 0: 0] bne_inst;
    logic [ 0: 0] blt_inst;
    logic [ 0: 0] bge_inst;
    logic [ 0: 0] bltu_inst;
    logic [ 0: 0] bgeu_inst;
    logic [ 0: 0] b_inst;
    logic [ 0: 0] bl_inst;
    logic [ 0: 0] jirl_inst;

    logic [31: 0] imm;

    
    assign beq_inst       = (IF_IR [31:26] == 6'h16)     ? 1'b1 : 1'b0;
    assign bne_inst       = (IF_IR [31:26] == 6'h17)     ? 1'b1 : 1'b0;
    assign blt_inst       = (IF_IR [31:26] == 6'h18)     ? 1'b1 : 1'b0;
    assign bge_inst       = (IF_IR [31:26] == 6'h19)     ? 1'b1 : 1'b0;
    assign bltu_inst      = (IF_IR [31:26] == 6'h1a)     ? 1'b1 : 1'b0;
    assign bgeu_inst      = (IF_IR [31:26] == 6'h1b)     ? 1'b1 : 1'b0;
    assign b_inst         = (IF_IR [31:26] == 6'h14)     ? 1'b1 : 1'b0;
    assign bl_inst        = (IF_IR [31:26] == 6'h15)     ? 1'b1 : 1'b0;
    assign jirl_inst      = (IF_IR [31:26] == 6'h13)     ? 1'b1 : 1'b0;

    // br_type
    // 00 others
    // 01 b,beq,bne,blt,bge,bltu,bgeu // 除去B类型的跳转指令外，低跳高不跳
    // 10 bl
    // 11 jirl

    // assign o_valid = data_valid;
    assign br_type =    (beq_inst  )  ? 2'b01 : 
                        (bne_inst  )  ? 2'b01 :
                        (blt_inst  )  ? 2'b01 :
                        (bge_inst  )  ? 2'b01 :
                        (bltu_inst )  ? 2'b01 :
                        (bgeu_inst )  ? 2'b01 :
                        (b_inst    )  ? 2'b01 :
                        (bl_inst   )  ? 2'b10 :
                        (jirl_inst )  ? 2'b11 : 2'b00;


    assign imm =    (beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst | bgeu_inst | jirl_inst) ? ({(IF_IR[25] ? 14'h3fff: 14'd0), IF_IR[25:10], 2'h0}):
                    (b_inst | bl_inst) ? ({(IF_IR[9] ? 4'hf : 4'd0), IF_IR[ 9: 0], IF_IR[25:10], 2'h0}) : 32'd4;

    assign PC_pre = PC + imm;
    // assign o_PC   = PC;
    // 预测检查,是否Flush检查
    
    
    logic [ 0: 0] type_right;
    logic [ 0: 0] PC_right;
    logic [ 0: 0] weither_to_flush; // 判断由于预测错误是否需要flush
    assign type_right = !(br_type ^ type_predict);
    assign PC_right   = !(PC_pre ^ PC_pre_already);
    always @(*) begin
        if(~data_valid) begin
            weither_to_flush = 1'b0;
        end
        else if(type_right) begin
            if(b_inst | bl_inst) begin
                weither_to_flush = ~(PC_right);
            end
            else begin
                if(!(PC_pre_already ^ PC_plus_4) | !type_predict) begin
                    weither_to_flush = 1'b0;
                end
                else begin
                    if(jirl_inst) begin
                        weither_to_flush = 1'b0;
                    end
                    else begin
                        weither_to_flush = ~(PC_right);
                    end
                end
            end

        end
        else begin
            weither_to_flush = 1'b1; // type不对一定跳转吗？ NO
        end
    end

    // 最终地址:
    // b,bl: PC_pre
    // jirl：PC_pre_already
    // beq,bne,blt,bge,bltu,bgeu: PC + 4(when predict not jump, and there won't change it)
    //                            PC_pre(when predict jump and addr right, and there won't change it)
    //                            PC_pre or PC + 4(when predict jump and addr wrong, and there will change it)
    // not BR,but predict jump: PC + 4
    // assign PC_fact = ~(b_inst | bl_inst | jirl_inst) ? (weither_to_flush ? (PC_pre < PC && ((beq_inst | bne_inst | blt_inst) | (bge_inst | bltu_inst | bgeu_inst)))? PC_pre : PC_plus_4 :  PC_pre_already) : (jirl_inst ? PC_pre_already : PC_pre);
    assign o_valid = weither_to_flush;
    assign type_pcpre = {br_type, PC_fact};

    always @(*) begin
        if(b_inst | bl_inst) begin
            PC_fact = PC_pre;
        end
        else if(jirl_inst) begin
            PC_fact = PC_pre_already;
        end
        else if((beq_inst | bne_inst | blt_inst) | (bge_inst | bltu_inst | bgeu_inst)) begin
            if(weither_to_flush) begin
                if(PC_pre < PC) begin
                    PC_fact = PC_pre;
                end
                else begin
                    PC_fact = PC_plus_4;
                end
            end
            else begin
                PC_fact = PC_pre_already;
            end
        end
        else begin
            PC_fact = PC_plus_4;
        end
    end

endmodule
