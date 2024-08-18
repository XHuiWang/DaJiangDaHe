`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/13 13:04:13
// Design Name: 
// Module Name: Return_buffer_dcache
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


module Return_buffer_dcache(
    input              clk,
    input     [1:0]    offset,
    input              d_arvalid,
    input              d_rvalid,
    input              d_rlast,
    input     [31:0]   d_rdata,
    output  reg  [127:0]  w_data,
    output  reg  [31:0]   data_from_retbuf
    );

    always @(posedge clk) begin
        if(d_rvalid)begin
            w_data <= {d_rdata,w_data[127:32]};
        end
    end

    always @(*) begin
        case(offset)
            2'b00: data_from_retbuf = w_data[31:0];
            2'b01: data_from_retbuf = w_data[63:32];
            2'b10: data_from_retbuf = w_data[95:64];
            2'b11: data_from_retbuf = w_data[127:96];
        endcase
    end


endmodule
