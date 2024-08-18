module Stable_Counter(
input                   clk,
input                   rstn,   //只受rstn控制，不受flush信号影响

output  wire    [63:0]  EX_rdcntv
);
reg     [63:0]  cnt;
always @(posedge clk)begin
    if(!rstn)
        cnt <= 64'h0;
    else
        cnt <= cnt + 1;
end
assign EX_rdcntv = cnt;
endmodule