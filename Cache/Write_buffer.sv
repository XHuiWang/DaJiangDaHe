`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/05 12:41:25
// Design Name: 
// Module Name: Write_buffer
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


module Write_buffer(
    input                        clk,
    input                        way_sel,
    input          [127:0]       r_data1,
    input          [127:0]       r_data2,
    input                        wbuf_we,
    input                        d_wready,
    output  wire   [31:0]        d_wdata
    );
    wire [127:0]  d_wdata_4;
    assign d_wdata_4 = way_sel == 1'b1 ? r_data2 : r_data1;

    reg  [127:0]  d_wdata_4_reg; 
    always @(posedge clk) begin
        if(wbuf_we) d_wdata_4_reg <= d_wdata_4;
        else if(d_wready) d_wdata_4_reg <= {32'b0, d_wdata_4_reg[127:32]};
    end

    assign d_wdata = d_wdata_4_reg[31:0];
endmodule
