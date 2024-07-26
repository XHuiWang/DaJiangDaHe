`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 15:56:36
// Design Name: 
// Module Name: IF1
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


module IF1(
    input [ 0: 0] clk,
    input [ 0: 0] rstn,

    input [31: 0] pc_predict,
    input [31: 0] pc_BR,
    input [ 0: 0] EX_BR,

    // 来自预译码的信号
    input [ 0: 0] BR_predecoder,
    input [31: 0] PC_predecoder,

    // stall信号
    input [ 0: 0] stall_ICache,
    input [ 0: 0] stall_full_instr,

    output logic [31: 0] pc_IF1,
    output logic [ 0: 0] is_valid

    );

    // logic stop_for_remember; // 用于在预译码得到跳转型号，但是同时得到IB满信号，导致PC_pre被跳过。所以使用这个信号作为记录。

    // logic [ 0: 0] flush;
    logic [ 0: 0] stall;
    logic [ 0: 0] is_valid_temp;
    assign stall = stall_ICache | stall_full_instr;

    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            is_valid_temp <= 0;
        end
        else begin
            is_valid_temp <= 1;
        end
    end
    assign is_valid = ~stall & is_valid_temp & ~BR_predecoder;

    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            pc_IF1 <= 32'h1c00_0000;
        end
        else if(EX_BR) begin
            pc_IF1 <= pc_BR;
        end
        else if(BR_predecoder) begin
            pc_IF1 <= PC_predecoder;
        end
        // else if(stop_for_remember) begin
        //     pc_IF1 <= pc_IF1;
        // end
        else if( stall ) begin
            pc_IF1 <= pc_IF1;
        end
        else begin
            pc_IF1 <= pc_predict;
        end
    end


    // always @(posedge clk, negedge rstn) begin
    //     if( !rstn ) begin
    //         stop_for_remember <= 0;
    //     end
    //     else if( stall_full_instr ) begin
    //         if ( BR_predecoder ) begin
    //             stop_for_remember <= 1;
    //         end
    //         else begin
    //             stop_for_remember <= stop_for_remember;
    //         end
    //     end
    //     else begin
    //         stop_for_remember <= 0;
    //     end
    // end
endmodule
