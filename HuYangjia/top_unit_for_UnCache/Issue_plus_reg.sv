`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 22:51:17
// Design Name: 
// Module Name: Issue_plus_reg
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



import Public_Info::*;
module Issue_plus_reg(
    input PC_set i_set1,
    input PC_set i_set2,
    input [ 1: 0] i_is_valid,
    input [31: 0] rdata_1_1,
    input [31: 0] rdata_1_2,
    input [31: 0] rdata_2_1,
    input [31: 0] rdata_2_2,


    output PC_set o_set1,
    output PC_set o_set2,
    output [ 1: 0] o_usingNUM

    );


    

endmodule
