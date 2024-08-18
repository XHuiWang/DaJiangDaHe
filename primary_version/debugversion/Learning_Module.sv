`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/31 10:24:02
// Design Name: 
// Module Name: Learning_Module
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



module Learning_Module(
    input [ 0: 0] clk,
    input [15: 0] pointer,
    input [ 0: 0] we
    );

    logic [ 0: 0] number1 [0:15];
    logic [ 0: 0] number2 [0:15];
    initial begin
        for(integer i = 0; i < 16; i = i + 1) begin
            number1[i] = 0;
            number2[i] = 0;
        end
    end



    function void  adder(
        input [ 0: 0] we,
        input [15: 0] pointer,
        input [ 0: 0] number [0:15]
    );
        begin
            for(integer i = 0; i < 16; i = i + 1) begin
                if(we && pointer[i]) begin
                    number2[i] = 1;
                end
            end
        end
    endfunction

    always @(posedge clk) begin
        adder(we, pointer,number2);
    end
endmodule
