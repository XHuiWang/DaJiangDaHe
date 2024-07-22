`timescale 1ns / 1ps
module Div_Test(
    input   clk,
    input   rstn,
    input   [31:0] ISS_a, // a/b
    input   [31:0] ISS_b,
    input   ISS_div_signed,
    input   ISS_div_en,
    output  wire [31:0] quo,rem
);
logic   stall_div;
logic   EX_div_signed;
logic   EX_div_en;
logic   [31:0] EX_a,EX_b;
always @(posedge clk, negedge rstn)begin
    if(!rstn)begin
        EX_a<=32'b0;
        EX_b<=32'b0;
        EX_div_signed<=1'b0;
        EX_div_en<=1'b0;
    end
    else if(stall_div)begin
        //所有信号保持不变
    end
    else begin
        EX_a<=ISS_a;
        EX_b<=ISS_b;
        EX_div_signed<=ISS_div_signed;
        EX_div_en<=ISS_div_en;
    end

end
Div div_inst(
    .clk_div(clk),
    .rstn(rstn),
    .div_en(EX_div_en),
    .div_x(EX_a),
    .div_y(EX_b),
    .div_signed(EX_div_signed),
    .stall_div(stall_div),
    .MEM_div_quo(quo),
    .MEM_div_rem(rem)
);
endmodule