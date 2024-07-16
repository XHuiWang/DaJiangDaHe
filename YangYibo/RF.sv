`timescale 1ns / 1ps
module RF #(
    parameter ADDR_WIDTH  = 5,              //地址宽度
    parameter DATA_WIDTH  = 32              //数据宽度
)(
    input                           clk,     
    input       [ADDR_WIDTH -1:0]   raddr_a1, raddr_a2,raddr_b1,raddr_b2,   //读地址
    output  reg [DATA_WIDTH -1:0]   rdata_a1, rdata_a2,rdata_b1,rdata_b2,   //读数据
    input       [ADDR_WIDTH -1:0]   addr,                                   //额外读地址
    output  reg [DATA_WIDTH -1:0]   dout_rf,                                //额外读数据
    input       [ADDR_WIDTH -1:0]   waddr_a, waddr_b,                       //写地址
    input       [DATA_WIDTH -1:0]   wdata_a, wdata_b,                       //写数据
    input                           we_a,we_b                               //写使能
);
    reg [DATA_WIDTH -1:0]  rf [0:(1<<ADDR_WIDTH)-1];    //寄存器堆
    //异步读
    assign rdata_a1 = (raddr_a1 == waddr_b) ? wdata_b : ((raddr_a1 == waddr_a) ? wdata_a : rf[raddr_a1]);   
    assign rdata_a2 = (raddr_a2 == waddr_b) ? wdata_b : ((raddr_a2 == waddr_a) ? wdata_a : rf[raddr_a2]);   
    assign rdata_b1 = (raddr_b1 == waddr_b) ? wdata_b : ((raddr_b1 == waddr_a) ? wdata_a : rf[raddr_b1]);   
    assign rdata_b2 = (raddr_b2 == waddr_b) ? wdata_b : ((raddr_b2 == waddr_a) ? wdata_a : rf[raddr_b2]);   
    assign dout_rf  = (addr     == waddr_b) ? wdata_b : ((addr     == waddr_a) ? wdata_a : rf[addr    ]);   

    initial begin
        foreach (rf[i]) rf[i] = 32'h0000_0000;      //初始化寄存器堆
    end
    //同步写 A、B写入相同地址时仅B有效
    always@ (posedge clk) begin
        if (we_a && waddr_a != 5'd0 && (!we_b || waddr_a!=waddr_b))     rf[waddr_a] <= wdata_a;
        if (we_b && waddr_b != 5'd0)                                    rf[waddr_b] <= wdata_b;
    end
endmodule
