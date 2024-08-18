module Mul2(
    input           [63: 0]     MEM_mul_tmp1,MEM_mul_tmp2,  //Booth编码+华莱士树计算得到的临时结果
    output  wire    [63: 0]     MEM_mul_res                 //乘法结果
);
assign MEM_mul_res = MEM_mul_tmp1 + MEM_mul_tmp2;           //相加得到最终结果
endmodule