module Mul(
    input           [31: 0]     EX_mul_x,EX_mul_y,
    input           [31: 0]     EX_mul_x_n, //预先取反加一的乘数
    // input           [31: 0]     EX_mul_y_n,
    input                       EX_mul_signed,      //1：有符号数乘法；0：无符号数乘法
    output  wire    [63: 0]     EX_mul_tmp1, EX_mul_tmp2    //最后一级CSA的输出      
);
logic   [63: 0]     x;          //乘数x，扩展至64位
logic   [63: 0]     x_n;          //   -x，扩展至64位
logic   [32: 0]     y;          //乘数y，扩展至33位
assign x = EX_mul_signed ? {{32{EX_mul_x[31]}},EX_mul_x} : {32'b0,EX_mul_x};
assign x_n = EX_mul_signed? {{32{EX_mul_x_n[31]}},EX_mul_x_n} : 
    ( |x ? {32'hFFFF_FFFF,EX_mul_x_n} : {32'h0, EX_mul_x_n}); //除非x为0，否则EX_mul_x取反加一不会产生进位
assign y = EX_mul_signed ? {EX_mul_y[31],EX_mul_y} : {1'b0,EX_mul_y};

//Booth编码
logic   [63: 0]     booth_res [16:0];   //booth编码的结果
Booth Booth_0(.y({y[1:0],1'b0}), .x(x), .x_n(x_n), .booth_res(booth_res[0]));
generate
    genvar i;
    for (i=2;i<32;i=i+2)begin:mul_booth
        Booth Booth_i(
            .y(y[i+1:i-1]),
            .x(x<<i),
            .x_n(x_n<<i),
            .booth_res(booth_res[i>>1])
        );
    end
endgenerate
Booth Booth_32(.y({y[32],y[32:31]}), .x(x<<32), .x_n(x_n<<32), .booth_res(booth_res[16]));

//CSA
//first stage 17->12 
logic   [63: 0]     fst_s [4:0];
logic   [63: 0]     fst_cout [4:0];
CSA CSA_fst_1(.a(booth_res[2]), .b(booth_res[1]), .cin(booth_res[0]), .s(fst_s[0]), .cout(fst_cout[0]));
CSA CSA_fst_2(.a(booth_res[5]), .b(booth_res[4]), .cin(booth_res[3]), .s(fst_s[1]), .cout(fst_cout[1]));
CSA CSA_fst_3(.a(booth_res[8]), .b(booth_res[7]), .cin(booth_res[6]), .s(fst_s[2]), .cout(fst_cout[2]));
CSA CSA_fst_4(.a(booth_res[11]), .b(booth_res[10]), .cin(booth_res[9]), .s(fst_s[3]), .cout(fst_cout[3]));
CSA CSA_fst_5(.a(booth_res[14]), .b(booth_res[13]), .cin(booth_res[12]), .s(fst_s[4]), .cout(fst_cout[4]));

//second stage 12->8
logic   [63: 0]     snd_s [3:0];
logic   [63: 0]     snd_cout [3:0];
CSA CSA_snd_1(.a(fst_s[1]), .b(fst_cout[0]<<1), .cin(fst_s[0]), .s(snd_s[0]), .cout(snd_cout[0]));
CSA CSA_snd_2(.a(fst_cout[2]<<1), .b(fst_s[2]), .cin(fst_cout[1]<<1), .s(snd_s[1]), .cout(snd_cout[1]));
CSA CSA_snd_3(.a(fst_s[4]), .b(fst_cout[3]<<1), .cin(fst_s[3]), .s(snd_s[2]), .cout(snd_cout[2]));
CSA CSA_snd_4(.a(booth_res[16]), .b(booth_res[15]), .cin(fst_cout[4]<<1), .s(snd_s[3]), .cout(snd_cout[3]));

//third stage 8->6
logic   [63: 0]     trd_s [1:0];
logic   [63: 0]     trd_cout [1:0];
CSA CSA_trd_1(.a(snd_s[1]), .b(snd_cout[0]<<1), .cin(snd_s[0]), .s(trd_s[0]), .cout(trd_cout[0]));
CSA CSA_trd_2(.a(snd_cout[2]<<1), .b(snd_s[2]), .cin(snd_cout[1]<<1), .s(trd_s[1]), .cout(trd_cout[1]));

//fourth stage 6->4
logic   [63: 0]     fth_s [1:0];
logic   [63: 0]     fth_cout [1:0];
CSA CSA_fth_1(.a(trd_s[1]), .b(trd_cout[0]<<1), .cin(trd_s[0]), .s(fth_s[0]), .cout(fth_cout[0]));
CSA CSA_fth_2(.a(snd_cout[3]<<1),  .b(snd_s[3]), .cin(trd_cout[1]<<1), .s(fth_s[1]), .cout(fth_cout[1]));

//fifth stage 4->3
logic   [63: 0]     fif_s;
logic   [63: 0]     fif_cout;
CSA CSA_fif(.a(fth_s[1]), .b(fth_cout[0]<<1), .cin(fth_s[0]), .s(fif_s), .cout(fif_cout));

//sixth stage 3->2
logic   [63: 0]     six_s;
logic   [63: 0]     six_cout;
CSA CSA_six(.a(fth_cout[1]<<1), .b(fif_cout<<1), .cin(fif_s), .s(six_s), .cout(six_cout));

assign EX_mul_tmp1=six_s;
assign EX_mul_tmp2=six_cout<<1;
endmodule


module Booth(
    input           [ 2: 0]     y,
    input           [63: 0]     x,
    input           [63: 0]     x_n,
    output  wire    [63: 0]     booth_res   //Booth算法计算结果
);
logic               p1,p2,n1,n2;        //x -> x/2x/-x/-2x
assign p1 = y==3'b001 || y==3'b010;
assign p2 = y==3'b011;
assign n1 = y==3'b101 || y==3'b110;
assign n2 = y==3'b100;
assign booth_res = (({64{p1}}&x) | ({64{p2}}&(x<<1))) | ({64{n1}}&x_n | {64{n2}}&{x_n<<1});
endmodule  

module CSA(
    input           [63: 0]     a,b,cin,
    output  wire    [63: 0]     s,cout
);
assign s=a^b^cin;
assign cout=(a&b)|(b&cin)|(a&cin);
endmodule

