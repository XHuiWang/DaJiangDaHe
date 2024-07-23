`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/22 11:06:25
// Design Name: 
// Module Name: ptab_table
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//并行比较，要暴露所有数据
//16项 30位pc 和 30位ptab_target_pc

module ptab_table(


    input clk,
    //写口
    input ptab_update, //由顶层模块给出，由分支预测的结果决定
    input [29:0] update_ptab_pc, //更新的pc
    input [29:0] update_ptab_target_pc, //更新的目标pc
    input [3:0]  update_ptab_addr, //更新的地址

    //valid的更新设计在外部

    //读口 全暴露
    output [29:0] pc0,
    output [29:0] pc0_target_pc,
    output [29:0] pc1,
    output [29:0] pc1_target_pc,
    output [29:0] pc2,
    output [29:0] pc2_target_pc,
    output [29:0] pc3,
    output [29:0] pc3_target_pc,
    output [29:0] pc4,
    output [29:0] pc4_target_pc,
    output [29:0] pc5,
    output [29:0] pc5_target_pc,
    output [29:0] pc6,
    output [29:0] pc6_target_pc,
    output [29:0] pc7,
    output [29:0] pc7_target_pc,
    output [29:0] pc8,
    output [29:0] pc8_target_pc,
    output [29:0] pc9,
    output [29:0] pc9_target_pc,
    output [29:0] pc10,
    output [29:0] pc10_target_pc,
    output [29:0] pc11,
    output [29:0] pc11_target_pc,
    output [29:0] pc12,
    output [29:0] pc12_target_pc,
    output [29:0] pc13,
    output [29:0] pc13_target_pc,
    output [29:0] pc14,
    output [29:0] pc14_target_pc,
    output [29:0] pc15,
    output [29:0] pc15_target_pc

    );

reg [29:0] pc             [0:15];
reg [29:0] ptab_target_pc [0:15];

//输出
assign pc0 = pc[0];
assign pc0_target_pc = ptab_target_pc[0];
assign pc1 = pc[1];
assign pc1_target_pc = ptab_target_pc[1];
assign pc2 = pc[2];
assign pc2_target_pc = ptab_target_pc[2];
assign pc3 = pc[3];
assign pc3_target_pc = ptab_target_pc[3];
assign pc4 = pc[4];
assign pc4_target_pc = ptab_target_pc[4];
assign pc5 = pc[5];
assign pc5_target_pc = ptab_target_pc[5];
assign pc6 = pc[6];
assign pc6_target_pc = ptab_target_pc[6];
assign pc7 = pc[7];
assign pc7_target_pc = ptab_target_pc[7];
assign pc8 = pc[8];
assign pc8_target_pc = ptab_target_pc[8];
assign pc9 = pc[9];
assign pc9_target_pc = ptab_target_pc[9];
assign pc10 = pc[10];
assign pc10_target_pc = ptab_target_pc[10];
assign pc11 = pc[11];
assign pc11_target_pc = ptab_target_pc[11];
assign pc12 = pc[12];
assign pc12_target_pc = ptab_target_pc[12];
assign pc13 = pc[13];
assign pc13_target_pc = ptab_target_pc[13]; 
assign pc14 = pc[14];
assign pc14_target_pc = ptab_target_pc[14];
assign pc15 = pc[15];
assign pc15_target_pc = ptab_target_pc[15];



//更新
always @(posedge clk)
begin
    if(ptab_update)
    begin
        pc[update_ptab_addr] <= update_ptab_pc;
        ptab_target_pc[update_ptab_addr] <= update_ptab_target_pc;
    end
end




endmodule
