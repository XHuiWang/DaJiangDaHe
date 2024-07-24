module ex_mem_wb(
    input                       clk,
    input                       rstn,

    input           [31: 0]     EX_pc_a,            //A指令的PC值
    input           [31: 0]     EX_pc_b,            //B指令的PC值
    input           [31: 0]     EX_rf_rdata_a1,     //A指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_a2,     //A指令的第二个寄存器的值
    input           [31: 0]     EX_rf_rdata_b1,     //B指令的第一个寄存器的值
    input           [31: 0]     EX_rf_rdata_b2,     //B指令的第二个寄存器的值
    input           [31: 0]     EX_imm_a,           //A指令的立即数
    input           [31: 0]     EX_imm_b,           //B指令的立即数

    input           [ 4: 0]     EX_rf_raddr_a1,     //A指令的第一个寄存器的地址
    input           [ 4: 0]     EX_rf_raddr_a2,     //A指令的第二个寄存器的地址
    input           [ 4: 0]     EX_rf_raddr_b1,     //B指令的第一个寄存器的地址
    input           [ 4: 0]     EX_rf_raddr_b2,     //B指令的第二个寄存器的地址

    input           [ 2: 0]     EX_alu_src_sel_a1,  //A指令的第一个操作数选择信号
    input           [ 2: 0]     EX_alu_src_sel_a2,  //A指令的第二个操作数选择信号
    input           [ 2: 0]     EX_alu_src_sel_b1,  //B指令的第一个操作数选择信号
    input           [ 2: 0]     EX_alu_src_sel_b2,  //B指令的第二个操作数选择信号
    input           [11: 0]     EX_alu_op_a,        //A指令的运算类型
    input           [11: 0]     EX_alu_op_b,        //B指令的运算类型

    input           [ 3: 0]     EX_br_type_a,       //A指令的分支类型
    input           [ 3: 0]     EX_br_type_b,       //B指令的分支类型
    input                       EX_br_pd_a,         //predict A指令的分支预测，1预测跳转，0预测不跳转                  
    input                       EX_br_pd_b,         //predict B指令的分支预测，1预测跳转，0预测不跳转    
    
    input                       EX_rf_we_a,         //A指令寄存器写使能
    input                       EX_rf_we_b,         //B指令寄存器写使能
    input           [ 4: 0]     EX_rf_waddr_a,      //A指令寄存器写地址
    input           [ 4: 0]     EX_rf_waddr_b,      //B指令寄存器写地址
    
    input                       EX_mem_we_a,        //A指令内存写使能
    input                       EX_mem_we_b,        //B指令内存写使能
    input           [ 2: 0]     EX_mem_type_a,      //A指令内存写类型
    input           [ 2: 0]     EX_mem_type_b,      //B指令内存写类型

    input                       EX_signed,          //乘除法符号指示，1为有符号数乘除法
    input           [ 5: 0]     EX_wb_mux_select_b,  //MEM段B指令RF写回数据多选器独热码

    output  reg                 WB_rf_we_a,         //A指令寄存器写使能
    output  reg                 WB_rf_we_b,         //B指令寄存器写使能
    output  reg     [ 4: 0]     WB_rf_waddr_a,      //A指令寄存器写地址
    output  reg     [ 4: 0]     WB_rf_waddr_b,      //B指令寄存器写地址
    output  reg     [31: 0]     WB_rf_wdata_a,      //A指令寄存器写数据
    output  reg     [31: 0]     WB_rf_wdata_b,      //B指令寄存器写数据

    output          [ 0: 0]     EX_br,              //是否需要修正预测的结果
    output          [31: 0]     EX_pc_br,           //修正时应跳转到的地址
    
    //dcache
    output  wire                EX_mem_rvalid,
    output  wire                EX_mem_wvalid,
    input                       MEM_mem_rready,
    input                       MEM_mem_wready,
    output  wire     [31: 0]    EX_mem_addr,
    output  wire     [ 2: 0]    EX_mem_type,
    output  wire     [31: 0]    EX_mem_wdata, 
    input            [31: 0]    MEM_mem_rdata,

    //div
    input                       EX_div_en,          //除法器使能，stall使其在33个EX有效
    output  wire                stall_div           //除法器暂停信号
);
logic   [31: 0]     EX_rf_rdata_a1_f;               //A指令的第一个寄存器的值，经前递修正后
logic   [31: 0]     EX_rf_rdata_a2_f;               //A指令的第二个寄存器的值，经前递修正后
logic   [31: 0]     EX_rf_rdata_b1_f;               //B指令的第一个寄存器的值，经前递修正后
logic   [31: 0]     EX_rf_rdata_b2_f;               //B指令的第二个寄存器的值，经前递修正后

logic   [31: 0]     EX_alu_result_a;                //A指令的运算结果
logic   [31: 0]     EX_alu_result_b;                //B指令的运算结果
logic   [31: 0]     MEM_alu_result_a;               //A指令的运算结果
logic   [31: 0]     MEM_alu_result_b;               //B指令的运算结果
logic   [31: 0]     WB_alu_result_a;                //A指令的运算结果
logic   [31: 0]     WB_alu_result_b;                //B指令的运算结果

logic               MEM_rf_we_a;                    //A指令寄存器写使能
logic               MEM_rf_we_b;                    //B指令寄存器写使能
logic   [ 4: 0]     MEM_rf_waddr_a;                 //A指令寄存器写地址
logic   [ 4: 0]     MEM_rf_waddr_b;                 //B指令寄存器写地址
logic   [ 5: 0]     MEM_wb_mux_select_b;            //MEM段B指令RF写回数据多选器独热码

logic   [31: 0]     EX_mul_tmp1;                    //乘法临时结果的第一个加数
logic   [31: 0]     EX_mul_tmp2;                    //乘法临时结果的第二个加数
logic   [31: 0]     MEM_mul_tmp1;                   //乘法临时结果的第一个加数
logic   [31: 0]     MEM_mul_tmp2;                   //乘法临时结果的第二个加数
logic   [63: 0]     MEM_mul_res;                    //乘法结果
logic   [31: 0]     MEM_div_quo;                    //除法商
logic   [31: 0]     MEM_div_rem;                    //除法余数

logic               EX_br_a;                        //A指令是否需要修正预测的结果
logic               EX_mem_we;                      //内存写使能 由DCache考虑STORE指令的W/H/B分类
logic               EX_mem_we_bb;                   //考虑A为BR时修正后，B指令内存写使能

logic   [31: 0]     MEM_mem_rdata_orig;             //内存读数据，尚未考虑LOAD指令的W/B/H/BU/HU分类
logic   [31: 0]     MEM_rf_wdata_a;                 //A指令寄存器写数据
logic   [31: 0]     MEM_rf_wdata_b;                 //B指令寄存器写数据
logic   [ 2: 0]     MEM_mem_type_a;                 //A指令访存类型
logic   [ 2: 0]     MEM_mem_type_b;                 //B指令访存类型
logic   [ 2: 0]     MEM_mem_type;                   //访存类型
logic               MEM_mem_ready;
logic               stall_dcache;                   //~MEM_mem_ready
logic               stall_dcache_buf;               //留存一级stall信号，EX(BR)MEM(MISS)时仅第一个周期EX_br可以置1
logic               stall_div_buf;                  //除法器暂停信号
assign  EX_mem_we         =EX_mem_we_a | EX_mem_we_bb;       //A、B至多有一个为STROE指令
assign  EX_mem_we_bb      =EX_br_a?1'b0:EX_mem_we_b;      //若A指令需要修正预测结果，B指令不能写内存
assign  EX_mem_wdata      =EX_mem_type_a==3'b000 ? EX_rf_rdata_b2_f:EX_rf_rdata_a2_f; //不会同时发射两条访存指令，A指令不会是LD指令
assign  EX_mem_addr       =EX_mem_type_a==3'b000 ? EX_alu_result_b:EX_alu_result_a;   //mem_type000对应非访存或LD.W，只要mem_type_a是000，A就不是访存指令

assign  EX_mem_type= EX_mem_type_a + EX_mem_type_b; //A、B至多有一个为STROE指令
assign MEM_mem_type=MEM_mem_type_a +MEM_mem_type_b; //A、B至多有一个为STROE指令


//MEM Mux of rf_wdata
assign MEM_rf_wdata_a = MEM_alu_result_a;
assign MEM_rf_wdata_b = {32{MEM_wb_mux_select_b[0]}}&MEM_alu_result_b   | {32{MEM_wb_mux_select_b[1]}}&MEM_mem_rdata | 
                        {32{MEM_wb_mux_select_b[2]}}&MEM_mul_res[31:0]  | {32{MEM_wb_mux_select_b[3]}}&MEM_mul_res[63:32] | 
                        {32{MEM_wb_mux_select_b[4]}}&MEM_div_quo        | {32{MEM_wb_mux_select_b[5]}}&MEM_div_rem; 
// MEM段B指令RF写回数据多选器独热码 
// 6'b00_0001: ALU
// 6'b00_0010: LD类型指令
// 6'b00_0100: MUL  取低32位
// 6'b00_1000: MULH 取高32位
// 6'b01_0000: DIV 取商
// 6'b10_0000: MOD 取余

Forward  Forward_inst (
    .EX_rf_rdata_a1(EX_rf_rdata_a1),
    .EX_rf_rdata_a2(EX_rf_rdata_a2),
    .EX_rf_rdata_b1(EX_rf_rdata_b1),
    .EX_rf_rdata_b2(EX_rf_rdata_b2),
    .MEM_rf_waddr_a(MEM_rf_waddr_a),
    .MEM_rf_waddr_b(MEM_rf_waddr_b),
    .MEM_rf_we_a(MEM_rf_we_a),
    .MEM_rf_we_b(MEM_rf_we_b),
    .MEM_alu_result_a(MEM_alu_result_a),
    .MEM_alu_result_b(MEM_alu_result_b),
    .WB_rf_waddr_a(WB_rf_waddr_a),
    .WB_rf_waddr_b(WB_rf_waddr_b),
    .WB_rf_we_a(WB_rf_we_a),
    .WB_rf_we_b(WB_rf_we_b),
    .WB_rf_wdata_a(WB_rf_wdata_a),
    .WB_rf_wdata_b(WB_rf_wdata_b),
    .EX_rf_raddr_a1(EX_rf_raddr_a1),
    .EX_rf_raddr_a2(EX_rf_raddr_a2),
    .EX_rf_raddr_b1(EX_rf_raddr_b1),
    .EX_rf_raddr_b2(EX_rf_raddr_b2),
    .EX_rf_rdata_a1_f(EX_rf_rdata_a1_f),
    .EX_rf_rdata_a2_f(EX_rf_rdata_a2_f),
    .EX_rf_rdata_b1_f(EX_rf_rdata_b1_f),
    .EX_rf_rdata_b2_f(EX_rf_rdata_b2_f)
  );

FU_ALU  FU_ALU_inst (
    .EX_pc_a(EX_pc_a),
    .EX_pc_b(EX_pc_b),
    .EX_rf_rdata_a1(EX_rf_rdata_a1_f),
    .EX_rf_rdata_a2(EX_rf_rdata_a2_f),
    .EX_rf_rdata_b1(EX_rf_rdata_b1_f),
    .EX_rf_rdata_b2(EX_rf_rdata_b2_f),
    .EX_imm_a(EX_imm_a),
    .EX_imm_b(EX_imm_b),
    .EX_alu_src_sel_a1(EX_alu_src_sel_a1),
    .EX_alu_src_sel_a2(EX_alu_src_sel_a2),
    .EX_alu_src_sel_b1(EX_alu_src_sel_b1),
    .EX_alu_src_sel_b2(EX_alu_src_sel_b2),
    .EX_alu_op_a(EX_alu_op_a),
    .EX_alu_op_b(EX_alu_op_b),
    .EX_alu_result_a(EX_alu_result_a),
    .EX_alu_result_b(EX_alu_result_b)
);
FU_BR  FU_BR_inst (
    .EX_pc_a(EX_pc_a),
    .EX_pc_b(EX_pc_b),
    .EX_rf_rdata_a1(EX_rf_rdata_a1_f),
    .EX_rf_rdata_a2(EX_rf_rdata_a2_f),
    .EX_rf_rdata_b1(EX_rf_rdata_b1_f),
    .EX_rf_rdata_b2(EX_rf_rdata_b2_f),
    .EX_imm_a(EX_imm_a),
    .EX_imm_b(EX_imm_b),
    .EX_br_type_a(EX_br_type_a),
    .EX_br_type_b(EX_br_type_b),
    .EX_br_pd_a(EX_br_pd_a),
    .EX_br_pd_b(EX_br_pd_b),
    // .stall_dcache(stall_dcache),
    .stall_dcache_buf(stall_dcache_buf),
    .stall_div_buf(stall_div_buf),
    .EX_br_a(EX_br_a),
    .EX_br(EX_br),
    .EX_pc_br(EX_pc_br)
  );
Mul  Mul_inst (
    .EX_mul_x(EX_rf_rdata_b1_f),
    .EX_mul_y(EX_rf_rdata_b2_f),
    .EX_mul_signed(EX_signed),
    .EX_mul_tmp1(EX_mul_tmp1),
    .EX_mul_tmp2(EX_mul_tmp2)
  );
Mul2  Mul2_inst (
    .MEM_mul_tmp1(MEM_mul_tmp1),
    .MEM_mul_tmp2(MEM_mul_tmp2),
    .MEM_mul_res(MEM_mul_res)
);
Div  Div_inst (
    .clk_div(clk),
    .rstn(rstn),
    .div_en(EX_div_en),
    .div_x(EX_rf_rdata_b1_f),
    .div_y(EX_rf_rdata_b2_f),
    .div_signed(EX_signed),
    .stall_div(stall_div),
    .MEM_div_quo(MEM_div_quo),
    .MEM_div_rem(MEM_div_rem)
  );

Pipeline_Register  Pipeline_Register_inst (
    .clk(clk),
    .rstn(rstn),
    .stall_dcache(stall_dcache),
    .stall_div(stall_div),
    .EX_br_a(EX_br_a),
    .EX_alu_result_a(EX_alu_result_a),
    .EX_alu_result_b(EX_alu_result_b),
    .MEM_alu_result_a(MEM_alu_result_a),
    .MEM_alu_result_b(MEM_alu_result_b),
    .WB_alu_result_a(WB_alu_result_a),
    .WB_alu_result_b(WB_alu_result_b),
    .EX_mul_tmp1(EX_mul_tmp1),
    .EX_mul_tmp2(EX_mul_tmp2),
    .MEM_mul_tmp1(MEM_mul_tmp1),
    .MEM_mul_tmp2(MEM_mul_tmp2),
    .EX_rf_we_a(EX_rf_we_a),
    .EX_rf_we_b(EX_rf_we_b),
    .EX_rf_waddr_a(EX_rf_waddr_a),
    .EX_rf_waddr_b(EX_rf_waddr_b),
    .EX_wb_mux_select_b(EX_wb_mux_select_b),
    .EX_mem_type_a(EX_mem_type_a),
    .EX_mem_type_b(EX_mem_type_b),
    .MEM_rf_we_a(MEM_rf_we_a),
    .MEM_rf_we_b(MEM_rf_we_b),
    .MEM_rf_waddr_a(MEM_rf_waddr_a),
    .MEM_rf_waddr_b(MEM_rf_waddr_b),
    .MEM_rf_wdata_a(MEM_rf_wdata_a),
    .MEM_rf_wdata_b(MEM_rf_wdata_b),
    .MEM_mem_type_a(MEM_mem_type_a),
    .MEM_mem_type_b(MEM_mem_type_b),
    .MEM_wb_mux_select_b(MEM_wb_mux_select_b),
    .WB_rf_we_a(WB_rf_we_a),
    .WB_rf_we_b(WB_rf_we_b),
    .WB_rf_waddr_a(WB_rf_waddr_a),
    .WB_rf_waddr_b(WB_rf_waddr_b),
    .WB_rf_wdata_a(WB_rf_wdata_a),
    .WB_rf_wdata_b(WB_rf_wdata_b)
  );
logic   [31: 0]     dout_dm;



assign EX_mem_rvalid = EX_wb_mux_select_b[1];
assign EX_mem_wvalid = EX_mem_we;
assign MEM_mem_ready = MEM_mem_rready | MEM_mem_wready;
assign stall_dcache  = ~MEM_mem_ready;
always @(posedge clk, negedge rstn) begin
  if(!rstn)begin
    stall_dcache_buf <= 1'b0;
    stall_div_buf <= 1'b0;
  end
  else begin
    stall_dcache_buf <= stall_dcache;
    stall_div_buf <= stall_div;
  end
end


endmodule