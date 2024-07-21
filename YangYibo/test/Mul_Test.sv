module  Mul_test(
    input        clk,
    input        rstn,
    input   [31:0]  a,b,
    input           mul_signed,
    output  wire [63:0]  res
);
logic   [63:0]  EX_tmp1,EX_tmp2;
logic   [63:0]  MEM_tmp1,MEM_tmp2;
Mul mul1(
    .EX_mul_x(a),
    .EX_mul_y(b),
    .EX_mul_signed(mul_signed),
    .EX_mul_tmp1(EX_tmp1),
    .EX_mul_tmp2(EX_tmp2)
);
always @(posedge clk or negedge rstn)begin
    if(!rstn)begin
        MEM_tmp1<=64'b0;
        MEM_tmp2<=64'b0;
    end
    else begin
        MEM_tmp1<=EX_tmp1;
        MEM_tmp2<=EX_tmp2;
    end
end
Mul2 mul2(
    .MEM_mul_tmp1(MEM_tmp1),
    .MEM_mul_tmp2(MEM_tmp2),
    .MEM_mul_res(res)
);
endmodule