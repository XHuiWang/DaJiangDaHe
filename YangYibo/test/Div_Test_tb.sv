`timescale 1ns / 1ps
module Div_Test_tb(

);
logic clk;
logic rstn;
logic [31:0] ISS_a,ISS_b;
logic ISS_div_signed;
logic ISS_div_en;
wire [31:0] quo,rem;
Div_Test  Div_Test_inst (
    .clk(clk),
    .rstn(rstn),
    .ISS_a(ISS_a),
    .ISS_b(ISS_b),
    .ISS_div_signed(ISS_div_signed),
    .ISS_div_en(ISS_div_en),
    .quo(quo),
    .rem(rem)
  );
initial begin
    rstn=1'b1;
    clk=1'b0;
    forever begin
        #10 clk=~clk;
    end
end
initial begin
    ISS_a=32'h0000_0100;
    ISS_b=32'h0000_0011;
    ISS_div_signed=1'b0;
    ISS_div_en=1'b1;
    #5 rstn=1'b0;
    #10 rstn=1'b1;
        ISS_div_en=1'b1;
    #20 ISS_div_en=1'b0;
    // #640
    #100
        ISS_div_en=1'b1;
        ISS_div_signed=1'b1;
        ISS_a=32'h8A73_2000;
        ISS_b=32'hFFFF_F567;
    #640 ISS_div_signed=1'b0;
end
endmodule