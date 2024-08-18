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

    assign a_tail_PC =  a_PC_Buffer[ 0] & {32{a_tail[ 0]}} | 
                        a_PC_Buffer[ 1] & {32{a_tail[ 1]}} |
                        a_PC_Buffer[ 2] & {32{a_tail[ 2]}} |
                        a_PC_Buffer[ 3] & {32{a_tail[ 3]}} |
                        a_PC_Buffer[ 4] & {32{a_tail[ 4]}} |
                        a_PC_Buffer[ 5] & {32{a_tail[ 5]}} |
                        a_PC_Buffer[ 6] & {32{a_tail[ 6]}} |
                        a_PC_Buffer[ 7] & {32{a_tail[ 7]}} |
                        a_PC_Buffer[ 8] & {32{a_tail[ 8]}} |
                        a_PC_Buffer[ 9] & {32{a_tail[ 9]}} |
                        a_PC_Buffer[10] & {32{a_tail[10]}} |
                        a_PC_Buffer[11] & {32{a_tail[11]}} |
                        a_PC_Buffer[12] & {32{a_tail[12]}} |
                        a_PC_Buffer[13] & {32{a_tail[13]}} |
                        a_PC_Buffer[14] & {32{a_tail[14]}} |
                        a_PC_Buffer[15] & {32{a_tail[15]}};
    assign a_tail_IR =  a_IR_Buffer[ 0] & {32{a_tail[ 0]}} | 
                        a_IR_Buffer[ 1] & {32{a_tail[ 1]}} |
                        a_IR_Buffer[ 2] & {32{a_tail[ 2]}} |
                        a_IR_Buffer[ 3] & {32{a_tail[ 3]}} |
                        a_IR_Buffer[ 4] & {32{a_tail[ 4]}} |
                        a_IR_Buffer[ 5] & {32{a_tail[ 5]}} |
                        a_IR_Buffer[ 6] & {32{a_tail[ 6]}} |
                        a_IR_Buffer[ 7] & {32{a_tail[ 7]}} |
                        a_IR_Buffer[ 8] & {32{a_tail[ 8]}} |
                        a_IR_Buffer[ 9] & {32{a_tail[ 9]}} |
                        a_IR_Buffer[10] & {32{a_tail[10]}} |
                        a_IR_Buffer[11] & {32{a_tail[11]}} |
                        a_IR_Buffer[12] & {32{a_tail[12]}} |
                        a_IR_Buffer[13] & {32{a_tail[13]}} |
                        a_IR_Buffer[14] & {32{a_tail[14]}} |
                        a_IR_Buffer[15] & {32{a_tail[15]}};
    assign a_tail_brtype_pcpre = a_brtype_pcpre_Buffer[ 0] & {34{a_tail[ 0]}} | 
                                 a_brtype_pcpre_Buffer[ 1] & {34{a_tail[ 1]}} |
                                 a_brtype_pcpre_Buffer[ 2] & {34{a_tail[ 2]}} |
                                 a_brtype_pcpre_Buffer[ 3] & {34{a_tail[ 3]}} |
                                 a_brtype_pcpre_Buffer[ 4] & {34{a_tail[ 4]}} |
                                 a_brtype_pcpre_Buffer[ 5] & {34{a_tail[ 5]}} |
                                 a_brtype_pcpre_Buffer[ 6] & {34{a_tail[ 6]}} |
                                 a_brtype_pcpre_Buffer[ 7] & {34{a_tail[ 7]}} |
                                 a_brtype_pcpre_Buffer[ 8] & {34{a_tail[ 8]}} |
                                 a_brtype_pcpre_Buffer[ 9] & {34{a_tail[ 9]}} |
                                 a_brtype_pcpre_Buffer[10] & {34{a_tail[10]}} |
                                 a_brtype_pcpre_Buffer[11] & {34{a_tail[11]}} |
                                 a_brtype_pcpre_Buffer[12] & {34{a_tail[12]}} |
                                 a_brtype_pcpre_Buffer[13] & {34{a_tail[13]}} |
                                 a_brtype_pcpre_Buffer[14] & {34{a_tail[14]}} |
                                 a_brtype_pcpre_Buffer[15] & {34{a_tail[15]}};
    assign a_tail_ecode =   a_ecode_Buffer[ 0] & { 8{a_tail[ 0]}} |
                            a_ecode_Buffer[ 1] & { 8{a_tail[ 1]}} |
                            a_ecode_Buffer[ 2] & { 8{a_tail[ 2]}} |
                            a_ecode_Buffer[ 3] & { 8{a_tail[ 3]}} |
                            a_ecode_Buffer[ 4] & { 8{a_tail[ 4]}} |
                            a_ecode_Buffer[ 5] & { 8{a_tail[ 5]}} |
                            a_ecode_Buffer[ 6] & { 8{a_tail[ 6]}} |
                            a_ecode_Buffer[ 7] & { 8{a_tail[ 7]}} |
                            a_ecode_Buffer[ 8] & { 8{a_tail[ 8]}} |
                            a_ecode_Buffer[ 9] & { 8{a_tail[ 9]}} |
                            a_ecode_Buffer[10] & { 8{a_tail[10]}} |
                            a_ecode_Buffer[11] & { 8{a_tail[11]}} |
                            a_ecode_Buffer[12] & { 8{a_tail[12]}} |
                            a_ecode_Buffer[13] & { 8{a_tail[13]}} |
                            a_ecode_Buffer[14] & { 8{a_tail[14]}} |
                            a_ecode_Buffer[15] & { 8{a_tail[15]}}; 

    assign b_tail_PC =  b_PC_Buffer[ 0] & {32{b_tail[ 0]}} | 
                        b_PC_Buffer[ 1] & {32{b_tail[ 1]}} |
                        b_PC_Buffer[ 2] & {32{b_tail[ 2]}} |
                        b_PC_Buffer[ 3] & {32{b_tail[ 3]}} |
                        b_PC_Buffer[ 4] & {32{b_tail[ 4]}} |
                        b_PC_Buffer[ 5] & {32{b_tail[ 5]}} |
                        b_PC_Buffer[ 6] & {32{b_tail[ 6]}} |
                        b_PC_Buffer[ 7] & {32{b_tail[ 7]}} |
                        b_PC_Buffer[ 8] & {32{b_tail[ 8]}} |
                        b_PC_Buffer[ 9] & {32{b_tail[ 9]}} |
                        b_PC_Buffer[10] & {32{b_tail[10]}} |
                        b_PC_Buffer[11] & {32{b_tail[11]}} |
                        b_PC_Buffer[12] & {32{b_tail[12]}} |
                        b_PC_Buffer[13] & {32{b_tail[13]}} |
                        b_PC_Buffer[14] & {32{b_tail[14]}} |
                        b_PC_Buffer[15] & {32{b_tail[15]}};
    assign b_tail_IR =  b_IR_Buffer[ 0] & {32{b_tail[ 0]}} | 
                        b_IR_Buffer[ 1] & {32{b_tail[ 1]}} |
                        b_IR_Buffer[ 2] & {32{b_tail[ 2]}} |
                        b_IR_Buffer[ 3] & {32{b_tail[ 3]}} |
                        b_IR_Buffer[ 4] & {32{b_tail[ 4]}} |
                        b_IR_Buffer[ 5] & {32{b_tail[ 5]}} |
                        b_IR_Buffer[ 6] & {32{b_tail[ 6]}} |
                        b_IR_Buffer[ 7] & {32{b_tail[ 7]}} |
                        b_IR_Buffer[ 8] & {32{b_tail[ 8]}} |
                        b_IR_Buffer[ 9] & {32{b_tail[ 9]}} |
                        b_IR_Buffer[10] & {32{b_tail[10]}} |
                        b_IR_Buffer[11] & {32{b_tail[11]}} |
                        b_IR_Buffer[12] & {32{b_tail[12]}} |
                        b_IR_Buffer[13] & {32{b_tail[13]}} |
                        b_IR_Buffer[14] & {32{b_tail[14]}} |
                        b_IR_Buffer[15] & {32{b_tail[15]}};
    assign b_tail_brtype_pcpre =    b_brtype_pcpre_Buffer[ 0] & {34{b_tail[ 0]}} | 
                                    b_brtype_pcpre_Buffer[ 1] & {34{b_tail[ 1]}} |
                                    b_brtype_pcpre_Buffer[ 2] & {34{b_tail[ 2]}} |
                                    b_brtype_pcpre_Buffer[ 3] & {34{b_tail[ 3]}} |
                                    b_brtype_pcpre_Buffer[ 4] & {34{b_tail[ 4]}} |
                                    b_brtype_pcpre_Buffer[ 5] & {34{b_tail[ 5]}} |
                                    b_brtype_pcpre_Buffer[ 6] & {34{b_tail[ 6]}} |
                                    b_brtype_pcpre_Buffer[ 7] & {34{b_tail[ 7]}} |
                                    b_brtype_pcpre_Buffer[ 8] & {34{b_tail[ 8]}} |
                                    b_brtype_pcpre_Buffer[ 9] & {34{b_tail[ 9]}} |
                                    b_brtype_pcpre_Buffer[10] & {34{b_tail[10]}} |
                                    b_brtype_pcpre_Buffer[11] & {34{b_tail[11]}} |
                                    b_brtype_pcpre_Buffer[12] & {34{b_tail[12]}} |
                                    b_brtype_pcpre_Buffer[13] & {34{b_tail[13]}} |
                                    b_brtype_pcpre_Buffer[14] & {34{b_tail[14]}} |
                                    b_brtype_pcpre_Buffer[15] & {34{b_tail[15]}};
    assign b_tail_ecode =   b_ecode_Buffer[ 0] & { 8{b_tail[ 0]}} |
                            b_ecode_Buffer[ 1] & { 8{b_tail[ 1]}} |
                            b_ecode_Buffer[ 2] & { 8{b_tail[ 2]}} |
                            b_ecode_Buffer[ 3] & { 8{b_tail[ 3]}} |
                            b_ecode_Buffer[ 4] & { 8{b_tail[ 4]}} |
                            b_ecode_Buffer[ 5] & { 8{b_tail[ 5]}} |
                            b_ecode_Buffer[ 6] & { 8{b_tail[ 6]}} |
                            b_ecode_Buffer[ 7] & { 8{b_tail[ 7]}} |
                            b_ecode_Buffer[ 8] & { 8{b_tail[ 8]}} |
                            b_ecode_Buffer[ 9] & { 8{b_tail[ 9]}} |
                            b_ecode_Buffer[10] & { 8{b_tail[10]}} |
                            b_ecode_Buffer[11] & { 8{b_tail[11]}} |
                            b_ecode_Buffer[12] & { 8{b_tail[12]}} |
                            b_ecode_Buffer[13] & { 8{b_tail[13]}} |
                            b_ecode_Buffer[14] & { 8{b_tail[14]}} |
                            b_ecode_Buffer[15] & { 8{b_tail[15]}}; 

endmodule
