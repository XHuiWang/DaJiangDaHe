module Mul_Test_tb(

);
reg clk;
reg rstn;
reg [31:0] a;
reg [31:0] b;
reg mul_signed;
wire [63:0] res;
Mul_test mul_test(
    .clk(clk),
    .rstn(rstn),
    .a(a),
    .b(b),
    .mul_signed(mul_signed),
    .res(res)
);
initial begin
    rstn=1'b1;
    clk=1'b0;
    forever begin
        #10 clk=~clk;
    end
end
initial begin
    a=32'h0000_0100;
    b=32'h0000_0001;
    mul_signed=1'b0;
    #5 rstn=1'b0;
    #10 rstn=1'b1; 
    #20 mul_signed=1'b0;
        a=32'hFEDC_BA98;
        b=32'h7654_3210;
    #20 mul_signed=1'b1;

    #20 mul_signed=1'b0;
        a=32'h1234_5678;
        b=32'h9ABC_DEF0;
    #20 mul_signed=1'b1;
    
end
endmodule