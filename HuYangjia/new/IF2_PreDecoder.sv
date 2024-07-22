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

    
    assign beq_inst       = (IF_IR [31:26] == 6'h16)     ? 1'b1 : 1'b0;
    assign bne_inst       = (IF_IR [31:26] == 6'h17)     ? 1'b1 : 1'b0;
    assign blt_inst       = (IF_IR [31:26] == 6'h18)     ? 1'b1 : 1'b0;
    assign bge_inst       = (IF_IR [31:26] == 6'h19)     ? 1'b1 : 1'b0;
    assign bltu_inst      = (IF_IR [31:26] == 6'h1a)     ? 1'b1 : 1'b0;
    assign bgeu_inst      = (IF_IR [31:26] == 6'h1b)     ? 1'b1 : 1'b0;
    assign b_inst         = (IF_IR [31:26] == 6'h14)     ? 1'b1 : 1'b0;
    assign bl_inst        = (IF_IR [31:26] == 6'h15)     ? 1'b1 : 1'b0;
    assign jirl_inst      = (IF_IR [31:26] == 6'h13)     ? 1'b1 : 1'b0;



    logic [ 8: 0] br_type_temp;
    assign br_type_temp =   (beq_inst  )  ? 4'b0110 : 
                            (bne_inst  )  ? 4'b0111 :
                            (blt_inst  )  ? 4'b1000 :
                            (bge_inst  )  ? 4'b1001 :
                            (bltu_inst )  ? 4'b1010 :
                            (bgeu_inst )  ? 4'b1011 :
                            (b_inst    )  ? 4'b0100 :
                            (bl_inst   )  ? 4'b0101 :
                            (jirl_inst )  ? 4'b0011 : 4'b0000;
    assign br_type = (data_valid) ? br_type_temp : 4'b0000;

    assign imm =        (beq_inst | bne_inst | blt_inst | bge_inst | bltu_inst | bgeu_inst | jirl_inst) ? ({(IF_IR[25] == 1'b1 ? 14'hffff: 14'd0), IF_IR[25:10], 2'h0}):
                        (b_inst | bl_inst) ? ({(IF_IR[9] == 1'b1 ? 4'hf : 4'd0), IF_IR[ 9: 0], IF_IR[25:10], 2'h0}) : 0;
 

endmodule
