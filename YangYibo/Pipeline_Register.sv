module Pipeline_Register(
    input                       clk,
    input                       rstn,
    input                       stall_dcache,
    input                       stall_div,
    input                       EX_br_a,  //A指令是否需要修正预测的结果，在EX段发生跳转
    input           [ 6: 0]     MEM_ecode_in_a, //A指令的异常码
    input           [ 6: 0]     MEM_ecode_in_b, //B指令的异常码
    input                       WB_flush_csr,
    
    input           [31: 0]     EX_pc_a,            //A指令的PC
    input           [31: 0]     EX_pc_b,            //B指令的PC
    output  reg     [31: 0]     MEM_pc_a,
    output  reg     [31: 0]     MEM_pc_b,
    output  reg     [31: 0]     WB_pc_a,            
    output  reg     [31: 0]     WB_pc_b,

    input           [31: 0]     EX_alu_result_a,    //A指令的运算结果
    input           [31: 0]     EX_alu_result_b,    //B指令的运算结果
    output  reg     [31: 0]     MEM_alu_result_a,
    output  reg     [31: 0]     MEM_alu_result_b,
    // output  reg     [31: 0]     WB_alu_result_a,
    // output  reg     [31: 0]     WB_alu_result_b,

    input           [63: 0]     EX_mul_tmp1,        //乘法器临时结果1
    input           [63: 0]     EX_mul_tmp2,        //乘法器临时结果2
    output  reg     [63: 0]     MEM_mul_tmp1,
    output  reg     [63: 0]     MEM_mul_tmp2,

    input                       EX_rf_we_a,         //A指令寄存器写使能
    input                       EX_rf_we_b,         //B指令寄存器写使能
    input           [ 4: 0]     EX_rf_waddr_a,      //A指令寄存器写地址
    input           [ 4: 0]     EX_rf_waddr_b,      //B指令寄存器写地址
    input           [ 5: 0]     EX_wb_mux_select_b,
    output  reg     [ 5: 0]     MEM_wb_mux_select_b,

    output  reg                 MEM_rf_we_a,
    output  reg                 MEM_rf_we_b,
    output  reg     [ 4: 0]     MEM_rf_waddr_a,
    output  reg     [ 4: 0]     MEM_rf_waddr_b,
    input           [31: 0]     MEM_rf_wdata_a,
    input           [31: 0]     MEM_rf_wdata_b,

    output  reg                 WB_rf_we_a,
    output  reg                 WB_rf_we_b,
    output  reg     [ 4: 0]     WB_rf_waddr_a,
    output  reg     [ 4: 0]     WB_rf_waddr_b,
    output  reg     [31: 0]     WB_rf_wdata_a,
    output  reg     [31: 0]     WB_rf_wdata_b
);
always@(posedge clk)
begin
    if(!rstn | WB_flush_csr)
    begin
        MEM_alu_result_a<=32'h0000_0000;
        MEM_alu_result_b<=32'h0000_0000;
        // WB_alu_result_a<=32'h0000_0000;
        // WB_alu_result_b<=32'h0000_0000;
        MEM_rf_we_a<=1'b0;
        MEM_rf_we_b<=1'b0;
        MEM_rf_waddr_a<=5'b00000;
        MEM_rf_waddr_b<=5'b00000;
        WB_rf_we_a<=1'b0;
        WB_rf_we_b<=1'b0;
        WB_rf_waddr_a<=5'b00000;
        WB_rf_waddr_b<=5'b00000;
        WB_rf_wdata_a<=32'h0000_0000;
        WB_rf_wdata_b<=32'h0000_0000;
        MEM_wb_mux_select_b<=6'b000000;
        MEM_mul_tmp1<=64'h0000_0000;
        MEM_mul_tmp2<=64'h0000_0000;
        MEM_pc_a<=32'h0000_0000;
        MEM_pc_b<=32'h0000_0000;
        WB_pc_a<=32'h0000_0000;
        WB_pc_b<=32'h0000_0000;
    end
    else if(!stall_dcache&&!stall_div)begin //考虑到前递，stall_dcache应阻塞所有段间寄存器
        //EX->MEM
        //不需要修正分支预测
        if(!EX_br_a) begin 
            MEM_alu_result_b<=EX_alu_result_b;
            MEM_rf_we_b<=EX_rf_we_b;
            MEM_wb_mux_select_b<=EX_wb_mux_select_b;
            MEM_mul_tmp1<=EX_mul_tmp1;
            MEM_mul_tmp2<=EX_mul_tmp2;
            MEM_pc_b<=EX_pc_b;
        end
        //需要修正分支预测
        else begin 
            MEM_alu_result_b<=32'h0000_0000;
            MEM_rf_we_b<=1'b0;
            MEM_wb_mux_select_b<=6'b000000;
            MEM_mul_tmp1<=64'h0000_0000;
            MEM_mul_tmp2<=64'h0000_0000;
            MEM_pc_b<=32'h0000_0000;
        end 
        MEM_alu_result_a<=EX_alu_result_a;
        MEM_rf_we_a<=EX_rf_we_a;
        MEM_rf_waddr_a<=EX_rf_waddr_a;
        MEM_rf_waddr_b<=EX_rf_waddr_b;
        MEM_pc_a<=EX_pc_a;

        //MEM->WB
        // WB_alu_result_a<=MEM_alu_result_a;
        // WB_alu_result_b<=MEM_alu_result_b;
        WB_rf_we_a<=|MEM_ecode_in_a ? 1'b0 : MEM_rf_we_a;    //A指令有无非中断例外
        WB_rf_we_b<=((|MEM_ecode_in_a) | (|MEM_ecode_in_b)) ? 1'b0 : MEM_rf_we_b; //AB指令有无非中断例外

        WB_rf_waddr_a<=MEM_rf_waddr_a;
        WB_rf_waddr_b<=MEM_rf_waddr_b;
        WB_rf_wdata_a<=MEM_rf_wdata_a;
        WB_rf_wdata_b<=MEM_rf_wdata_b;
        WB_pc_a<=MEM_pc_a;
        WB_pc_b<=MEM_pc_b;
    end
    else begin end
end

endmodule