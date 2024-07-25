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
    input [ 0: 0] ID_status,
    input [ 0: 0] data_valid,
    
    output logic [ 0: 0] o_valid,
    output logic [31: 0] o_PC,
    output logic [31: 0] PC_pre,
    output logic [ 1: 0] br_type
    );
    
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
    // 01 beq,bne,blt,bge,bltu,bgeu
    // 10 b,bl
    // 11 jirl

    assign o_valid = data_valid;
    assign br_type =    (beq_inst  )  ? 2'b01 : 
                        (bne_inst  )  ? 2'b01 :
                        (blt_inst  )  ? 2'b01 :
                        (bge_inst  )  ? 2'b01 :
                        (bltu_inst )  ? 2'b01 :
                        (bgeu_inst )  ? 2'b01 :
                        (b_inst    )  ? 2'b10 :
                        (bl_inst   )  ? 2'b10 :
                        (jirl_inst )  ? 2'b11 : 2'b00;


    assign imm =    (beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst | bgeu_inst | jirl_inst) ? ({(IF_IR[25] == 1'b1 ? 14'hffff: 14'd0), IF_IR[25:10], 2'h0}):
                    (b_inst | bl_inst) ? ({(IF_IR[9] == 1'b1 ? 4'hf : 4'd0), IF_IR[ 9: 0], IF_IR[25:10], 2'h0}) : 32'd0;

    assign PC_pre = PC + imm;
    assign o_PC   = PC;

endmodule
