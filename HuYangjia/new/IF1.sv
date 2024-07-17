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
    input [31: 0] EX_BR,

    output logic [31: 0] pc_IF1,
    output logic [ 0: 0] is_valid

    );

    logic [ 0: 0] flush;
    logic [ 0: 0] stall;


    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            is_valid <= 0;
        end
        else if(stall || flush) begin
            is_valid <= 0;
        end
        else begin
            is_valid <= 1;
        end
    end

    always @(posedge clk) begin
        pc_IF1 <= (EX_BR) ? pc_BR : pc_predict;
    end
endmodule
