`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 17:20:37
// Design Name: 
// Module Name: Return_buffer
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


module Return_buffer(
    input              clk,
    input     [1:0]    offset,
    input              i_arvalid,
    input              i_rvalid,
    input              i_rlast,
    input     [31:0]   i_rdata,
    input              uncache_pipe,
    output  reg  [127:0]  w_data,
    output  reg  [63:0]   inst_from_retbuf
    );

    always @(posedge clk) begin
        if(i_rvalid)begin
            w_data <= {i_rdata,w_data[127:32]};
        end
    end

    always @(*) begin
        if(uncache_pipe) inst_from_retbuf = w_data[127:64];
        else begin
            case(offset)
            2'b00: inst_from_retbuf = w_data[63:0];
            2'b01: inst_from_retbuf = w_data[95:32];
            2'b10: inst_from_retbuf = w_data[127:64];
            2'b11: inst_from_retbuf = {32'b0, w_data[127:96]};
        endcase
        end
    end


endmodule
