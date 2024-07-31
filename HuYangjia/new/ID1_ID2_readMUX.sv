`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/31 10:54:46
// Design Name: 
// Module Name: ID1_ID2_readMUX
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


module ID1_ID2_readMUX #(
    parameter NUM = 16
)(
    input [15: 0] a_tail,
    input [15: 0] b_tail,
    input [31: 0] a_PC_Buffer[0:NUM-1],
    input [31: 0] a_IR_Buffer[0:NUM-1],
    input [33: 0] a_brtype_pcpre_Buffer[0:NUM-1],
    input [ 7: 0] a_ecode_Buffer[0:NUM-1],
    input [31: 0] b_PC_Buffer[0:NUM-1],
    input [31: 0] b_IR_Buffer[0:NUM-1],
    input [33: 0] b_brtype_pcpre_Buffer[0:NUM-1],
    input [ 7: 0] b_ecode_Buffer[0:NUM-1],
    output logic [31: 0] a_tail_PC,
    output logic [31: 0] a_tail_IR,
    output logic [33: 0] a_tail_brtype_pcpre,
    output logic [ 7: 0] a_tail_ecode,
    output logic [31: 0] b_tail_PC,
    output logic [31: 0] b_tail_IR,
    output logic [33: 0] b_tail_brtype_pcpre,
    output logic [ 7: 0] b_tail_ecode
    );
endmodule
