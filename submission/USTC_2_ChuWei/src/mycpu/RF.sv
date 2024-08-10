`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 20:57:30
// Design Name: 
// Module Name: RF
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


module RF #(
    parameter ADDR_WIDTH  = 5,              //地址宽度
    parameter DATA_WIDTH  = 32              //数据宽度
)(
    input                           clk,     
    input       [ADDR_WIDTH -1:0]   raddr_a1  , raddr_a2  , raddr_b1  , raddr_b2,   //读地址
    output  reg [DATA_WIDTH -1:0]   rdata_a1  , rdata_a2  , rdata_b1  , rdata_b2,   //读数据
    input       [ADDR_WIDTH -1:0]   waddr_a, waddr_b,                       //写地址
    input       [DATA_WIDTH -1:0]   wdata_a, wdata_b,                       //写数据
    input                           we_a,we_b,                              //写使能
    output logic [ADDR_WIDTH -1:0]  regs1, regs2, regs3, regs4,
                                    regs5, regs6, regs7, regs8,
                                    regs9, regs10, regs11, regs12,
                                    regs13, regs14, regs15, regs16,
                                    regs17, regs18, regs19, regs20,
                                    regs21, regs22, regs23, regs24,
                                    regs25, regs26, regs27, regs28,
                                    regs29, regs30, regs31                       //寄存器堆

);
    reg [DATA_WIDTH -1:0]  rf [0:(1<<ADDR_WIDTH)-1];    //寄存器堆
    //异步读
    assign rdata_a1   = (raddr_a1 == waddr_b && we_b) ? wdata_b : ((raddr_a1 == waddr_a && we_a) ? wdata_a : rf[raddr_a1]);   
    assign rdata_a2   = (raddr_a2 == waddr_b && we_b) ? wdata_b : ((raddr_a2 == waddr_a && we_a) ? wdata_a : rf[raddr_a2]);   
    assign rdata_b1   = (raddr_b1 == waddr_b && we_b) ? wdata_b : ((raddr_b1 == waddr_a && we_a) ? wdata_a : rf[raddr_b1]);   
    assign rdata_b2   = (raddr_b2 == waddr_b && we_b) ? wdata_b : ((raddr_b2 == waddr_a && we_a) ? wdata_a : rf[raddr_b2]);    

    initial begin
        foreach (rf[i]) rf[i] = 32'h0000_0000;      //初始化寄存器堆
    end
    //同步写 A、B写入相同地址时仅B有效
    always@ (posedge clk) begin
        if (we_a && (!we_b || waddr_a!=waddr_b))     rf[waddr_a] <= wdata_a;
        if (we_b)                                    rf[waddr_b] <= wdata_b;
    end

    always @(*) begin
        regs1 = rf[1];
        regs2 = rf[2];
        regs3 = rf[3];
        regs4 = rf[4];
        regs5 = rf[5];
        regs6 = rf[6];
        regs7 = rf[7];
        regs8 = rf[8];
        regs9 = rf[9];
        regs10 = rf[10];
        regs11 = rf[11];
        regs12 = rf[12];
        regs13 = rf[13];
        regs14 = rf[14];
        regs15 = rf[15];
        regs16 = rf[16];
        regs17 = rf[17];
        regs18 = rf[18];
        regs19 = rf[19];
        regs20 = rf[20];
        regs21 = rf[21];
        regs22 = rf[22];
        regs23 = rf[23];
        regs24 = rf[24];
        regs25 = rf[25];
        regs26 = rf[26];
        regs27 = rf[27];
        regs28 = rf[28];
        regs29 = rf[29];
        regs30 = rf[30];
        regs31 = rf[31];
    end
endmodule
