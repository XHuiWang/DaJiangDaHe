`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/21 19:47:06
// Design Name: 
// Module Name: pht_table
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

//1024项 2位 复位为01 弱untaken

module pht_table(
    input  clk,
    input  rstn,
    //读口1，用于预测
    input  [9:0] addrb1,
    output logic [1:0] doutb1,
    //读口2，用于更新
    input  [9:0] addrb2,
    output logic [1:0] doutb2,

    //写口
    input  [9:0] addra,
    input  [1:0] dina,
    input  wea

    );

    //定义pht表，1024项 2位
    reg [1:0] pht_out [0:1023];
    //复位 以及 写入
    always @(posedge clk)
        if(!rstn)
            for(int i = 0; i < 1024; i++)
                pht_out[i] <= 2'b01;
        else if (wea)
            pht_out[addra] <= dina;
                

    //读取
    assign doutb1 = pht_out[addrb1];
    assign doutb2 = pht_out[addrb2];

        

endmodule
