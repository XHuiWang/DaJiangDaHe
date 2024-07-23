`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/20 10:29:18
// Design Name: 
// Module Name: basic_cpu_tb
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


module basic_cpu_tb(

    );


    logic clk;
    logic rstn;
    My_CPU_test  My_CPU_test_inst (
        .clk(clk),
        .rstn(rstn)
    );

    initial begin
        clk = 1'b0;
        forever begin
            #1 clk = ~clk;
        end
    end
    initial begin
        rstn = 1'b1;
        #10 rstn = 1'b0;
        #10 rstn = 1'b1;
    end

endmodule
