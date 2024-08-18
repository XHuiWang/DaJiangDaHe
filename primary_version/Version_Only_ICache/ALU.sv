module ALU(
    input       [31:0]  a,b,    //操作数
    input       [11:0]  f,      //选择信号
    output      [31:0]  y       //运算结果
);
wire[31:0]   ADD,SUB,SLT,SLTU;   //加法，减法，小于比较，无符号小于比较
wire[31:0]   AND,OR,NOR,XOR;     //按位与，按位或，按位或非，按位异或
wire[31:0]   SLL,SRL,SRA;        //左移，右移，算数右移

assign ADD=a+b;
assign SUB=a+~b+1;
assign SLT = {{31{1'b0}},$signed(a)<$signed(b)};
assign SLTU={{31{1'b0}},a<b};
assign AND=a&b;
assign OR=a|b;
assign NOR=~(a|b);
assign XOR=a^b;
assign SLL=a<<b[4:0];
assign SRL=a>>b[4:0];
assign SRA=$signed(a)>>>b[4:0];

assign y=({32{f[0]}}&ADD)|({32{f[1]}}&SUB)|({32{f[2]}}&SLT)|({32{f[3]}}&SLTU)|
    ({32{f[4]}}&AND)|({32{f[5]}}&OR)|({32{f[6]}}&NOR)|({32{f[7]}}&XOR)|
    ({32{f[8]}}&SLL)|({32{f[9]}}&SRL)|({32{f[10]}}&SRA)|({32{f[11]}}&b);

endmodule
