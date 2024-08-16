`timescale 1ns / 1ps
module Mux
#(
    parameter WIDTH = 32
)(
    input    [WIDTH-1:0]    a,b,c,d,
    input    [      3:0]    s,//选择信号,独热码
    output   wire [WIDTH-1:0]    y
);
assign  y = {WIDTH{s[0]}}&a | {WIDTH{s[1]}}&b | {WIDTH{s[2]}}&c | {WIDTH{s[3]}}&d;
endmodule

