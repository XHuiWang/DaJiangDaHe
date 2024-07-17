module Pipeline_Register(
    input                       clk,
    input                       rstn,
    input                       stall,
    
    input                       EX_br_a,            //A指令是否需要修正预测的结果，在EX段发生跳转
    input           [31: 0]     EX_alu_result_a,    //A指令的运算结果
    input           [31: 0]     EX_alu_result_b,    //B指令的运算结果
    output  reg     [31: 0]     MEM_alu_result_a,
    output  reg     [31: 0]     MEM_alu_result_b,
    output  reg     [31: 0]     WB_alu_result_a,
    output  reg     [31: 0]     WB_alu_result_b,

    input                       EX_rf_we_a,         //A指令寄存器写使能
    input                       EX_rf_we_b,         //B指令寄存器写使能
    input           [ 4: 0]     EX_rf_waddr_a,      //A指令寄存器写地址
    input           [ 4: 0]     EX_rf_waddr_b,      //B指令寄存器写地址
    input           [ 2: 0]     EX_mem_type_a,      //A指令访存类型
    input           [ 2: 0]     EX_mem_type_b,      //B指令访存类型

    output  reg                 MEM_rf_we_a,
    output  reg                 MEM_rf_we_b,
    output  reg     [ 4: 0]     MEM_rf_waddr_a,
    output  reg     [ 4: 0]     MEM_rf_waddr_b,
    input           [31: 0]     MEM_rf_wdata_a,
    input           [31: 0]     MEM_rf_wdata_b,
    output  reg     [ 2: 0]     MEM_mem_type_a,
    output  reg     [ 2: 0]     MEM_mem_type_b,

    output  reg                 WB_rf_we_a,
    output  reg                 WB_rf_we_b,
    output  reg     [ 4: 0]     WB_rf_waddr_a,
    output  reg     [ 4: 0]     WB_rf_waddr_b,
    output  reg     [31: 0]     WB_rf_wdata_a,
    output  reg     [31: 0]     WB_rf_wdata_b
);
 
always@(posedge clk,negedge rstn)
begin
    if(!rstn)
    begin
    end
    else
    begin
        if(!stall)
        begin
            MEM_alu_result_a<=EX_alu_result_a;
            WB_alu_result_a<=MEM_alu_result_a;
            WB_alu_result_b<=MEM_alu_result_b;
            //不需要修正分支预测
            if(!EX_br_a) begin 
                MEM_alu_result_b<=EX_alu_result_b;
                MEM_rf_we_b<=EX_rf_we_b;
            end
            //需要修正分支预测
            else begin 
                MEM_alu_result_b<=32'h0000_0000;
                MEM_rf_we_b<=1'b0;
            end 
                
            MEM_rf_we_a<=EX_rf_we_a;
            MEM_rf_waddr_a<=EX_rf_waddr_a;
            MEM_rf_waddr_b<=EX_rf_waddr_b;
            MEM_mem_type_a<=EX_mem_type_a;
            MEM_mem_type_b<=EX_mem_type_b;

            WB_rf_we_a<=MEM_rf_we_a;
            WB_rf_we_b<=MEM_rf_we_b;
            WB_rf_waddr_a<=MEM_rf_waddr_a;
            WB_rf_waddr_b<=MEM_rf_waddr_b;
            WB_rf_wdata_a<=MEM_rf_wdata_a;
            WB_rf_wdata_b<=MEM_rf_wdata_b;
        end       
    end
end

endmodule