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
    input [ 0: 0] MEM_br,
    input [ 1: 0] plv,

    // 来自预译码的信号
    input [ 0: 0] BR_predecoder,
    input [31: 0] PC_predecoder,

    // 来自特权和例外
    input [31: 0] PC_era,
    input [ 0: 0] WB_era_en,
    input [31: 0] PC_eentry,
    input [ 0: 0] WB_eentry_en,
    input [31: 0] WB_flush_csr_pc,
    input [ 0: 0] WB_flush_csr,


    // stall信号
    input [ 0: 0] stall_ICache,
    input [ 0: 0] stall_full_instr,

    output logic [31: 0] pc_IF1,
    output logic [ 7: 0] ecode, // 7位Ecode编码+1位we位
    output logic [ 0: 0] is_valid

    );

    logic [ 0: 0] BR_era;
    logic [ 0: 0] BR_eentry;
    logic [ 0: 0] stall;
    logic [ 0: 0] is_valid_temp;
    assign stall = stall_ICache | stall_full_instr;
    assign BR_era = WB_era_en;
    assign BR_eentry = WB_eentry_en;


    assign ecode = (pc_IF1[ 1: 0] == 2'b00) ? 8'd0 : 8'b1_000_1000;
    // assign ecode = (pc_IF1[ 1: 0] == 2'b00) ? (plv == 2'b11 && pc_IF1[31] == 1'b1) ? 8'b1_000_1000 : 8'd0 : 8'b1_000_1001;

    always @(posedge clk) begin
        if( !rstn ) begin
            is_valid_temp <= 0;
        end
        else begin
            is_valid_temp <= 1;
        end
    end
    assign is_valid = ~stall & is_valid_temp & ~BR_predecoder & ~MEM_br & ~BR_era & ~BR_eentry;

    always @(posedge clk) begin
        if( !rstn ) begin
            pc_IF1 <= 32'h1c00_0000;
        end
        else if(BR_era) begin
            pc_IF1 <= PC_era;
        end
        else if(BR_eentry) begin
            pc_IF1 <= PC_eentry;
        end
        else if(WB_flush_csr) begin
            pc_IF1 <= WB_flush_csr_pc;
        end
        else if(MEM_br) begin
            pc_IF1 <= pc_BR;
        end
        else if(BR_predecoder) begin
            pc_IF1 <= PC_predecoder;
        end
        else if( stall ) begin
            pc_IF1 <= pc_IF1;
        end
        else begin
            pc_IF1 <= pc_predict;
        end
    end

endmodule
