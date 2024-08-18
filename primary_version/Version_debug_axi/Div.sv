`timescale 1ns / 1ps
module Div(//除法器，共33个周期，1个EX初始准备，32个EX计算，然后流入MEM输出结果
    input                       clk_div,
    input                       rstn,
    input                       div_en,                 //除法器使能，stall使其在33个EX有效
    input           [31:0]      div_x, div_y,           //dividend 被除数, divisor 除数
    input                       div_signed,             //是否有符号，stall使其在33个EX不变
    output  wire                stall_div,              //发给EX前的段间寄存器，用于暂停流水线
    output  wire    [31:0]      MEM_div_quo, MEM_div_rem    //quotient 商, remainder 余数
);
logic   [31:0]      x_abs;      //被除数的绝对值 32位无符号整数
logic   [31:0]      y_abs;      //除数的绝对值 32位无符号整数

logic   [32:0]      loop_cnt;   //独热，通过左移计数，最高位为1代表除法已完成
//loop_cnt为1的位的序号+1代表当前正在进行第几次计算，下个时钟上升沿给出本次计算的结果
//共32次计算，完成计算后、无除法指令时，loop_cnt[32]保持为1

logic   [31:0]      dvs;        //除数 divisor
logic   [63:0]      dvd_rmd;    //高位为被除数，低位为余数，初始被除数在低位，逐步左移填入余数
//每轮计算dvd_rmd[62:31]与dvs[31:0]做比较
//初始dvd_rmd[31]与dvs[0]对齐，最后一轮计算前dvd_rmd[62:31]与dvs[31:0]对齐，
//最后一轮计算后，dvd_rmd[63:32]为余数，dvd_rmd[31:0]为商

logic               signed_buf; //留存一级符号指示，MEM段使用
logic               x_sign_buf; //留存一级div_x[31]，MEM段使用
logic               y_sign_buf; //留存一级div_y[31]，MEM段使用
assign stall_div = div_en & !loop_cnt[31];//前32EX stall，第33EX不stall，第34已进入MEM，不影响
assign x_abs = div_signed ? (div_x[31] ? (~div_x + 32'b1) : div_x) : div_x;
assign y_abs = div_signed ? (div_y[31] ? (~div_y + 32'b1) : div_y) : div_y;
assign dvs = y_abs[31:0];
always @(posedge clk_div)begin
    signed_buf <= div_signed;           //留存一级符号指示，MEM段使用
    x_sign_buf <= div_x[31];            //留存一级div_x[31]，MEM段使用
    y_sign_buf <= div_y[31];            //留存一级div_y[31]，MEM段使用
end
always @(posedge clk_div) begin
    if (!rstn)begin
        loop_cnt <= 33'h1_0000_0000;
        dvd_rmd <= 64'b0;
    end
    else if (loop_cnt[32]&&!div_en)begin    //上一次计算完成后，没有新的除法指令进入EX
        loop_cnt <= 33'h1_0000_0000;
        dvd_rmd <= 64'b0;
    end
    else if (loop_cnt[32]&&div_en)begin   //上一次计算完成后，可以开始新的计算
        loop_cnt <= 33'b1;
        dvd_rmd <= {32'b0,x_abs[31:0]};
    end
    else if(dvd_rmd[62:31]<dvs)begin    //计算未完成->本次计算对应位为0
        loop_cnt <= loop_cnt<<1;
        dvd_rmd <= {dvd_rmd[62:0],1'b0};
    end
    else /*if (dvd_rmd[62:31]>=dvs)*/begin  //计算未完成->本次计算对应位为1
        loop_cnt <= loop_cnt<<1;
        dvd_rmd <= { (dvd_rmd[62:31]-dvs) , dvd_rmd[30:0], 1'b1};
    end
end
assign MEM_div_quo = signed_buf ? 
    ( (x_sign_buf==y_sign_buf) ? dvd_rmd[31:0] : ~(dvd_rmd[31:0]-1'b1))
    : dvd_rmd[31:0]; //商
assign MEM_div_rem = signed_buf ?
    ( x_sign_buf ? ~(dvd_rmd[63:32]-1'b1) : dvd_rmd[63:32] )
    : dvd_rmd[63:32]; //余数

//符号关系
//x[31]  y[31]  q[31]  r[31]
//  0      0      0      0
//  0      1      1      0
//  1      0      1      1
//  1      1      0      1

endmodule