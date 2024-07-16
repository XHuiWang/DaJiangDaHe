`timescale 1ns / 1ps
module Mux
#(
    parameter WIDTH = 32
)(
    input    [WIDTH-1:0]    a,b,c,
    input    [      1:0]    s,//选择信号
    output   reg[WIDTH-1:0]    y
);
always @(*)begin
    case(s)
        2'b00:y=a;
        2'b01:y=b;
        2'b10:y=c;
        default:y=c;
    endcase
end
endmodule

