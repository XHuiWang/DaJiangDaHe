module ex_mem_wb(
    input                       clk,
    input                       rstn,

    input                       EX_a_enable,        //A指令是否是有效指令（影响中断信号的附着）
    input                       EX_b_enable,        //B指令是否是有效指令（影响中断信号的附着）
    //ALU计算相关
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
    input           [ 3: 0]     EX_alu_src_sel_a1,  //A指令的第一个操作数选择信号
    input           [ 3: 0]     EX_alu_src_sel_a2,  //A指令的第二个操作数选择信号
    input           [ 3: 0]     EX_alu_src_sel_b1,  //B指令的第一个操作数选择信号
    input           [ 3: 0]     EX_alu_src_sel_b2,  //B指令的第二个操作数选择信号
    input           [11: 0]     EX_alu_op_a,        //A指令的运算类型
    input           [11: 0]     EX_alu_op_b,        //B指令的运算类型
    //乘除法相关
    input                       EX_signed,          //乘除法符号指示，1为有符号数乘除法
    input                       EX_mul_en,          //乘法器使能，stall使其在2个EX有效
    input                       EX_div_en,          //除法器使能，stall使其在33个EX有效
    output  wire                stall_ex,           //EX段产生的乘法器除法器暂停信号

    //RF写回
    input                       EX_rf_we_a,         //A指令寄存器写使能
    input                       EX_rf_we_b,         //B指令寄存器写使能
    input           [ 4: 0]     EX_rf_waddr_a,      //A指令寄存器写地址
    input           [ 4: 0]     EX_rf_waddr_b,      //B指令寄存器写地址
    input           [ 8: 0]     EX_wb_mux_select_b, //MEM段B指令RF写回数据多选器独热码
    output  reg                 WB_rf_we_a,         //A指令寄存器写使能
    output  reg                 WB_rf_we_b,         //B指令寄存器写使能
    output  reg     [ 4: 0]     WB_rf_waddr_a,      //A指令寄存器写地址
    output  reg     [ 4: 0]     WB_rf_waddr_b,      //B指令寄存器写地址
    output  reg     [31: 0]     WB_rf_wdata_a,      //A指令寄存器写数据
    output  reg     [31: 0]     WB_rf_wdata_b,      //B指令寄存器写数据

    //dcache
    input                       EX_mem_we_a,        //A指令内存写使能
    input                       EX_mem_we_b,        //B指令内存写使能
    input           [ 2: 0]     EX_mem_type_a,      //A指令内存写类型
    input           [ 2: 0]     EX_mem_type_b,      //B指令内存写类型

    output  wire                EX_mem_rvalid,
    output  wire                EX_mem_wvalid,
    input                       MEM_mem_rready,
    input                       MEM_mem_wready,
    output  wire     [31: 0]    EX_mem_addr,
    output  wire     [ 2: 0]    EX_mem_type,
    output  wire     [31: 0]    EX_mem_wdata, 
    input            [31: 0]    MEM_mem_rdata,

    //CSR读写
    input           [ 2: 0]     EX_csr_type,        //CSR类型 001RD 010WR 100 XCHG 
    input           [31: 0]     EX_csr_rdata,       //CSR读数据 CSR单发B指令
    input           [13: 0]     EX_csr_waddr,       //CSR写地址 MEM段生效
    input           [31: 0]     EX_tid,             //定时器/计时器编号
    
    output  reg     [13: 0]     WB_csr_waddr,       //CSR写地址 MEM段生效
    output  reg     [31: 0]     WB_csr_we,          //CSR写使能 MEM段生效 按位
    output  reg     [31: 0]     WB_csr_wdata,       //CSR写数据 MEM段生效
    
    //CSR控制
    input                       EX_ertn,            //是否是ertn指令 单发B指令
    input           [ 6: 0]     EX_ecode_in_a,      //A指令例外码 WB段写入 [5:0]一级[6]二级
    input           [ 6: 0]     EX_ecode_in_b,      
    input                       EX_ecode_we_a,      //A指令例外码写使能/是否产生例外
    input                       EX_ecode_we_b,
    input                       MEM_interrupt,      //中断信号，CSR直接发到MEM段

    output  reg     [ 6: 0]     WB_ecode_in,        //例外码 WB段写入
    output  reg                 WB_ecode_we,        //例外码写使能/是否产生例外
    output  reg     [31: 0]     WB_badv_in,         //取指地址错记录PC，地址非对齐记录地址
    output  reg                 WB_badv_we,         //出错虚地址写使能
    output  reg     [31: 0]     WB_era_in,          //产生例外的指令PC
    output  reg                 WB_era_we,          //产生例外的指令PC写使能
    output  reg                 WB_era_en,          //发给PC更新器，下个边沿跳转到CSR.era
    output  reg                 WB_eentry_en,       //发给PC更新器，下个边沿跳转到CSR.eentry
    output  reg                 WB_store_state,     //触发例外，pplv=plv；pie=ie
    output  reg                 WB_restore_state,   //从例外恢复，plv=pplv；ie=pie
    output  reg                 WB_flush_csr,       //因任何原因写CSR时，清空流水线
    output  reg     [31: 0]     WB_flush_csr_pc,    //CSRWR/CSRXCHG，清空流水线时pc跳转的位置
    
    //BR
    input           [ 3: 0]     EX_br_type_a,       //A指令的分支类型
    input           [ 3: 0]     EX_br_type_b,       //B指令的分支类型
    input                       EX_br_pd_a,         //predict A指令的分支预测，1预测跳转，0预测不跳转                  
    input                       EX_br_pd_b,         //predict B指令的分支预测，1预测跳转，0预测不跳转   
    input           [31: 0]     EX_pc_pd_a,         //A指令的分支预测的跳转结果PC
    input           [31: 0]     EX_pc_pd_b,         //B指令的分支预测的跳转结果PC
    output          [ 0: 0]     EX_br,              //是否需要修正预测的结果
    output          [31: 0]     EX_pc_br,           //修正时应跳转到的地址
    //发给分支预测的信号
    output          [31: 0]     EX_pc_of_br,        //分支指令的PC
    input           [ 1: 0]     EX_pd_type_a,       //A指令的分支类型（与分支预测交互）
    input           [ 1: 0]     EX_pd_type_b,       //B指令的分支类型（与分支预测交互）
    output          [ 1: 0]     EX_pd_type,         //分支指令的分支类型（与分支预测交互）
    output          [31: 0]     EX_br_target,       //分支指令原本的目标地址
    output                      EX_br_jump,         //分支指令原本是否跳转     

    //UnCache
    output  wire                EX_UnCache,         //是否在访问外设
    //Debug
    output  wire      [31: 0]   debug0_wb_pc,       //写回段 A指令的pc
    output  wire      [ 3: 0]   debug0_wb_rf_we,    //写回段 A指令的寄存器写使能
    output  wire      [ 4: 0]   debug0_wb_rf_wnum,  //写回段 A指令的寄存器写地址
    output  wire      [31: 0]   debug0_wb_rf_wdata, //写回段 A指令的寄存器写数据
    output  wire      [31: 0]   debug1_wb_pc,       //写回段 B指令的pc
    output  wire      [ 3: 0]   debug1_wb_rf_we,    //写回段 B指令的寄存器写使能
    output  wire      [ 4: 0]   debug1_wb_rf_wnum,  //写回段 B指令的寄存器写地址
    output  wire      [31: 0]   debug1_wb_rf_wdata  //写回段 B指令的寄存器写数据
);
logic   [31: 0]     MEM_pc_a;                       //A指令的PC
logic   [31: 0]     MEM_pc_b;                       //B指令的PC
logic   [31: 0]     WB_pc_a;                        //A指令的PC
logic   [31: 0]     WB_pc_b;                        //B指令的PC

logic   [31: 0]     EX_rf_rdata_a1_f;               //A指令的第一个寄存器的值，经前递修正后
logic   [31: 0]     EX_rf_rdata_a2_f;               //A指令的第二个寄存器的值，经前递修正后
logic   [31: 0]     EX_rf_rdata_b1_f;               //B指令的第一个寄存器的值，经前递修正后
logic   [31: 0]     EX_rf_rdata_b2_f;               //B指令的第二个寄存器的值，经前递修正后

logic   [31: 0]     EX_alu_result_a;                //A指令的运算结果
logic   [31: 0]     EX_alu_result_b;                //B指令的运算结果
logic   [31: 0]     MEM_alu_result_a;               //A指令的运算结果
logic   [31: 0]     MEM_alu_result_b;               //B指令的运算结果

logic               MEM_rf_we_a;                    //A指令寄存器写使能
logic               MEM_rf_we_b;                    //B指令寄存器写使能
logic   [ 4: 0]     MEM_rf_waddr_a;                 //A指令寄存器写地址
logic   [ 4: 0]     MEM_rf_waddr_b;                 //B指令寄存器写地址
logic   [ 8: 0]     MEM_wb_mux_select_b;            //MEM段B指令RF写回数据多选器独热码

logic   [63: 0]     EX_mul_tmp1;                    //乘法临时结果的第一个加数
logic   [63: 0]     EX_mul_tmp2;                    //乘法临时结果的第二个加数
logic   [63: 0]     MEM_mul_tmp1;                   //乘法临时结果的第一个加数
logic   [63: 0]     MEM_mul_tmp2;                   //乘法临时结果的第二个加数
logic   [63: 0]     MEM_mul_res;                    //乘法结果
logic   [31: 0]     MEM_div_quo;                    //除法商
logic   [31: 0]     MEM_div_rem;                    //除法余数

logic               EX_br_a;                        //A指令是否需要修正预测的结果
logic               EX_mem_we;                      //内存写使能 由DCache考虑STORE指令的W/H/B分类
logic               EX_mem_we_bb;                   //考虑A为BR时修正后，B指令内存写使能

// logic   [31: 0]     MEM_mem_rdata_orig;             //内存读数据，尚未考虑LOAD指令的W/B/H/BU/HU分类
logic   [31: 0]     MEM_rf_wdata_a;                 //A指令寄存器写数据
logic   [31: 0]     MEM_rf_wdata_b;                 //B指令寄存器写数据

logic               MEM_mem_ready;
logic               stall_dcache;                   //~MEM_mem_ready
logic               stall_dcache_buf;               //留存一级stall信号，EX(BR)MEM(MISS)时仅第一个周期EX_br可以置1
logic               stall_mul;                      //乘法器暂停信号
logic               stall_div;                      //除法器暂停信号
logic               stall_ex_buf;                   //乘除法暂停信号保留一级

//CSR读写
logic   [31: 0]   EX_csr_we;
logic   [31: 0]   EX_csr_wdata;
logic   [31: 0]   MEM_csr_we;

//CSR控制
logic   [ 6: 0]   EX_ecode_in_aa;
logic   [ 6: 0]   EX_ecode_in_bb;
logic             EX_ecode_we_aa;
logic             EX_ecode_we_bb;
logic   [31: 0]   EX_badv_in_a;
logic   [31: 0]   EX_badv_in_b;
logic             EX_badv_we_a;
logic             EX_badv_we_b;

logic             MEM_ertn;
logic   [ 6: 0]   MEM_ecode_in_a;
logic   [ 6: 0]   MEM_ecode_in_b;
logic             MEM_ecode_we_a;
logic             MEM_ecode_we_b;
logic   [31: 0]   MEM_badv_in_a;
logic   [31: 0]   MEM_badv_in_b;
logic             MEM_badv_we_a;
logic             MEM_badv_we_b;
logic   [ 6: 0]   MEM_ecode_in;
logic             MEM_ecode_we;
logic   [31: 0]   MEM_badv_in;
logic             MEM_badv_we;
logic   [31: 0]   MEM_era_in;
logic             MEM_era_we;
logic             MEM_era_en;
logic             MEM_eentry_en;
logic             MEM_store_state;
logic             MEM_restore_state;
logic             MEM_flush_csr;
logic   [31: 0]   MEM_flush_csr_pc;
logic             MEM_a_enable;
logic             MEM_b_enable;

logic             WB_ertn;

//RDCNTV RDCNTID
logic   [63: 0]   EX_rdcntv;
logic   [63: 0]   MEM_rdcntv;
logic   [31: 0]   EX_rdcntid;
logic   [31: 0]   MEM_rdcntid;
assign EX_rdcntid = EX_tid;
//寄存器写相关
assign  EX_mem_we    = EX_mem_we_bb;      //访存指令单发B指令
assign  EX_mem_we_bb = ( EX_br_a | (|EX_ecode_in_aa) | (|EX_ecode_in_bb) | (|MEM_ecode_in_a) | (|MEM_ecode_in_b) | WB_flush_csr) 
        ?1'b0:EX_mem_we_b;//A修正预测/A非中断例外/B非中断例外，B指令不能写内存
assign  EX_mem_wdata = EX_rf_rdata_b2_f;  //访存指令单发B指令
assign  EX_mem_addr  = EX_alu_result_b;   //访存指令单发B指令

assign  EX_mem_type  = EX_mem_type_b;     //访存指令单发B指令
//乘除法暂停信号
assign  stall_ex = stall_mul | stall_div;
//MEM Mux of rf_wdata
assign MEM_rf_wdata_a = MEM_alu_result_a;
assign MEM_rf_wdata_b = ( ( {32{MEM_wb_mux_select_b[0]}}&MEM_alu_result_b   | {32{MEM_wb_mux_select_b[1]}}&MEM_mem_rdata      )   | 
                          ( {32{MEM_wb_mux_select_b[2]}}&MEM_mul_res[31:0]  | {32{MEM_wb_mux_select_b[3]}}&MEM_mul_res[63:32] ) ) | 
                        ( ( {32{MEM_wb_mux_select_b[4]}}&MEM_div_quo        | {32{MEM_wb_mux_select_b[5]}}&MEM_div_rem        )   |
                          ( {32{MEM_wb_mux_select_b[6]}}&MEM_rdcntv[31:0]   | {32{MEM_wb_mux_select_b[7]}}&MEM_rdcntv[63:32]  ) ) |
                          ( {32{MEM_wb_mux_select_b[8]}}&MEM_rdcntid        ); 
// MEM段B指令RF写回数据多选器独热码 
// 9'b0_0000_0001: ALU
// 9'b0_0000_0010: LD类型指令
// 9'b0_0000_0100: MUL  取低32位
// 9'b0_0000_1000: MULH 取高32位
// 9'b0_0001_0000: DIV 取商
// 9'b0_0010_0000: MOD 取余
// 9'b0_0100_0000: RDCNTVL.W 取低32位
// 9'b0_1000_0000: RDCNTVH.W 取高32位
// 9'b1_0000_0000: RDCNTID
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
    .EX_csr_rdata(EX_csr_rdata),
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
    .EX_pc_pd_a(EX_pc_pd_a),
    .EX_pc_pd_b(EX_pc_pd_b),
    // .stall_dcache(stall_dcache),
    .stall_dcache_buf(stall_dcache_buf),
    .stall_ex_buf(stall_ex_buf),
    .EX_br_a(EX_br_a),
    .EX_br(EX_br),
    .EX_pc_br(EX_pc_br),
    .EX_pc_of_br(EX_pc_of_br),
    .EX_pd_type_a(EX_pd_type_a),
    .EX_pd_type_b(EX_pd_type_b),
    .EX_pd_type(EX_pd_type),
    .EX_br_target(EX_br_target),
    .EX_br_jump(EX_br_jump)
  );
Mul  Mul_inst (
    .clk(clk),
    .rstn(rstn),
    .WB_flush_csr(WB_flush_csr),
    .mul_en(EX_mul_en),
    .EX_mul_x(EX_rf_rdata_b1_f),
    .EX_mul_y(EX_rf_rdata_b2_f),
    .EX_mul_signed(EX_signed),
    .stall_mul(stall_mul),
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
    .WB_flush_csr(WB_flush_csr),
    .div_en(EX_div_en),
    .div_x(EX_rf_rdata_b1_f),
    .div_y(EX_rf_rdata_b2_f),
    .div_signed(EX_signed),
    .stall_div(stall_div),
    .MEM_div_quo(MEM_div_quo),
    .MEM_div_rem(MEM_div_rem)
  );
Stable_Counter  Stable_Counter_inst (
    .clk(clk),
    .rstn(rstn),
    .EX_rdcntv(EX_rdcntv)
  );

FU_CSR  FU_CSR_inst (
    .EX_rf_rdata_b1_f(EX_rf_rdata_b1_f),
    .EX_rf_rdata_b2_f(EX_rf_rdata_b2_f),
    .EX_csr_type(EX_csr_type),
    .EX_csr_we(EX_csr_we),
    .EX_csr_wdata(EX_csr_wdata),
    .EX_pc_a(EX_pc_a),
    .EX_pc_b(EX_pc_b),
    .EX_ecode_in_a(EX_ecode_in_a),
    .EX_ecode_in_b(EX_ecode_in_b),
    .EX_ecode_we_a(EX_ecode_we_a),
    .EX_ecode_we_b(EX_ecode_we_b),
    .EX_wb_mux_select_b(EX_wb_mux_select_b),
    .EX_mem_we_b(EX_mem_we_b),
    .EX_mem_addr(EX_mem_addr),
    .EX_mem_type(EX_mem_type),
    .EX_ecode_in_aa(EX_ecode_in_aa),
    .EX_ecode_in_bb(EX_ecode_in_bb),
    .EX_ecode_we_aa(EX_ecode_we_aa),
    .EX_ecode_we_bb(EX_ecode_we_bb),
    .EX_badv_in_a(EX_badv_in_a),
    .EX_badv_in_b(EX_badv_in_b),
    .EX_badv_we_a(EX_badv_we_a),
    .EX_badv_we_b(EX_badv_we_b)
  );
FU_CSR2  FU_CSR2_inst (
    .MEM_csr_we(MEM_csr_we),
    .MEM_ertn(MEM_ertn),
    .MEM_interrupt(MEM_interrupt),
    .MEM_interrupt_buf(MEM_interrupt_buf),
    .MEM_a_enable(MEM_a_enable),
    .MEM_b_enable(MEM_b_enable),
    .MEM_pc_a(MEM_pc_a),
    .MEM_pc_b(MEM_pc_b),
    .MEM_ecode_in_a(MEM_ecode_in_a),
    .MEM_ecode_in_b(MEM_ecode_in_b),
    .MEM_ecode_we_a(MEM_ecode_we_a),
    .MEM_ecode_we_b(MEM_ecode_we_b),
    .MEM_badv_in_a(MEM_badv_in_a),
    .MEM_badv_in_b(MEM_badv_in_b),
    .MEM_badv_we_a(MEM_badv_we_a),
    .MEM_badv_we_b(MEM_badv_we_b),
    .MEM_ecode_in(MEM_ecode_in),
    .MEM_ecode_we(MEM_ecode_we),
    .MEM_badv_in(MEM_badv_in),
    .MEM_badv_we(MEM_badv_we),
    .MEM_era_in(MEM_era_in),
    .MEM_era_we(MEM_era_we),
    .MEM_era_en(MEM_era_en),
    .MEM_eentry_en(MEM_eentry_en),
    .MEM_store_state(MEM_store_state),
    .MEM_restore_state(MEM_restore_state),
    .MEM_flush_csr(MEM_flush_csr),
    .MEM_flush_csr_pc(MEM_flush_csr_pc)
  );
Pipeline_Register  Pipeline_Register_inst (
    .clk(clk),
    .rstn(rstn),
    .stall_dcache(stall_dcache),
    .stall_ex(stall_ex),
    .EX_br_a(EX_br_a),
    .MEM_ecode_in_a(MEM_ecode_in_a),
    .MEM_ecode_in_b(MEM_ecode_in_b),
    .WB_flush_csr(WB_flush_csr),
    .EX_pc_a(EX_pc_a),
    .EX_pc_b(EX_pc_b),
    .MEM_pc_a(MEM_pc_a),
    .MEM_pc_b(MEM_pc_b),
    .WB_pc_a(WB_pc_a),
    .WB_pc_b(WB_pc_b),
    .EX_alu_result_a(EX_alu_result_a),
    .EX_alu_result_b(EX_alu_result_b),
    .MEM_alu_result_a(MEM_alu_result_a),
    .MEM_alu_result_b(MEM_alu_result_b),
    // .WB_alu_result_a(WB_alu_result_a),
    // .WB_alu_result_b(WB_alu_result_b),
    .EX_mul_tmp1(EX_mul_tmp1),
    .EX_mul_tmp2(EX_mul_tmp2),
    .MEM_mul_tmp1(MEM_mul_tmp1),
    .MEM_mul_tmp2(MEM_mul_tmp2),
    .EX_rf_we_a(EX_rf_we_a),
    .EX_rf_we_b(EX_rf_we_b),
    .EX_rf_waddr_a(EX_rf_waddr_a),
    .EX_rf_waddr_b(EX_rf_waddr_b),
    .EX_wb_mux_select_b(EX_wb_mux_select_b),
    .MEM_wb_mux_select_b(MEM_wb_mux_select_b),
    .MEM_rf_we_a(MEM_rf_we_a),
    .MEM_rf_we_b(MEM_rf_we_b),
    .MEM_rf_waddr_a(MEM_rf_waddr_a),
    .MEM_rf_waddr_b(MEM_rf_waddr_b),
    .MEM_rf_wdata_a(MEM_rf_wdata_a),
    .MEM_rf_wdata_b(MEM_rf_wdata_b),
    .WB_rf_we_a(WB_rf_we_a),
    .WB_rf_we_b(WB_rf_we_b),
    .WB_rf_waddr_a(WB_rf_waddr_a),
    .WB_rf_waddr_b(WB_rf_waddr_b),
    .WB_rf_wdata_a(WB_rf_wdata_a),
    .WB_rf_wdata_b(WB_rf_wdata_b)
  );
Pipeline_Register_CSR  Pipeline_Register_CSR_inst (
    .clk(clk),
    .rstn(rstn),
    .stall_dcache(stall_dcache),
    .stall_ex(stall_ex),
    .EX_br_a(EX_br_a),
    .EX_csr_waddr(EX_csr_waddr),
    .EX_csr_we(EX_csr_we),
    .EX_csr_wdata(EX_csr_wdata),
    .EX_rdcntv(EX_rdcntv),
    .EX_rdcntid(EX_rdcntid),
    .MEM_csr_we(MEM_csr_we),
    .WB_csr_waddr(WB_csr_waddr),
    .WB_csr_we(WB_csr_we),
    .WB_csr_wdata(WB_csr_wdata),
    .MEM_rdcntv(MEM_rdcntv),
    .MEM_rdcntid(MEM_rdcntid),
    .EX_a_enable(EX_a_enable),
    .EX_b_enable(EX_b_enable),
    .MEM_a_enable(MEM_a_enable),
    .MEM_b_enable(MEM_b_enable),
    .MEM_interrupt(MEM_interrupt),
    .MEM_interrupt_buf(MEM_interrupt_buf),
    .EX_ertn(EX_ertn),
    .MEM_ertn(MEM_ertn),
    .WB_ertn(WB_ertn),
    .EX_ecode_in_aa(EX_ecode_in_aa),
    .EX_ecode_in_bb(EX_ecode_in_bb),
    .EX_ecode_we_aa(EX_ecode_we_aa),
    .EX_ecode_we_bb(EX_ecode_we_bb),
    .EX_badv_in_a(EX_badv_in_a),
    .EX_badv_in_b(EX_badv_in_b),
    .EX_badv_we_a(EX_badv_we_a),
    .EX_badv_we_b(EX_badv_we_b),
    .MEM_ecode_in_a(MEM_ecode_in_a),
    .MEM_ecode_in_b(MEM_ecode_in_b),
    .MEM_ecode_we_a(MEM_ecode_we_a),
    .MEM_ecode_we_b(MEM_ecode_we_b),
    .MEM_badv_in_a(MEM_badv_in_a),
    .MEM_badv_in_b(MEM_badv_in_b),
    .MEM_badv_we_a(MEM_badv_we_a),
    .MEM_badv_we_b(MEM_badv_we_b),
    .MEM_ecode_in(MEM_ecode_in),
    .MEM_ecode_we(MEM_ecode_we),
    .MEM_badv_in(MEM_badv_in),
    .MEM_badv_we(MEM_badv_we),
    .MEM_era_in(MEM_era_in),
    .MEM_era_we(MEM_era_we),
    .MEM_era_en(MEM_era_en),
    .MEM_eentry_en(MEM_eentry_en),
    .MEM_store_state(MEM_store_state),
    .MEM_restore_state(MEM_restore_state),
    .MEM_flush_csr(MEM_flush_csr),
    .MEM_flush_csr_pc(MEM_flush_csr_pc),
    .WB_ecode_in(WB_ecode_in),
    .WB_ecode_we(WB_ecode_we),
    .WB_badv_in(WB_badv_in),
    .WB_badv_we(WB_badv_we),
    .WB_era_in(WB_era_in),
    .WB_era_we(WB_era_we),
    .WB_era_en(WB_era_en),
    .WB_eentry_en(WB_eentry_en),
    .WB_store_state(WB_store_state),
    .WB_restore_state(WB_restore_state),
    .WB_flush_csr(WB_flush_csr),
    .WB_flush_csr_pc(WB_flush_csr_pc)
  );


assign EX_mem_rvalid = EX_wb_mux_select_b[1];
assign EX_mem_wvalid = EX_mem_we;
assign MEM_mem_ready = MEM_mem_rready | MEM_mem_wready;
assign stall_dcache  = ~MEM_mem_ready;
assign EX_UnCache    =  EX_mem_addr==32'hbfaf_8000 | EX_mem_addr==32'hbfaf_8010 |
                        EX_mem_addr==32'hbfaf_8020 | EX_mem_addr==32'hbfaf_8030 |
                        EX_mem_addr==32'hbfaf_8040 | EX_mem_addr==32'hbfaf_8050 |
                        EX_mem_addr==32'hbfaf_8060 | EX_mem_addr==32'hbfaf_8070 |
                        EX_mem_addr==32'hbfaf_f020 | EX_mem_addr==32'hbfaf_f030 |
                        EX_mem_addr==32'hbfaf_f040 | EX_mem_addr==32'hbfaf_f050 |
                        EX_mem_addr==32'hbfaf_f060 | EX_mem_addr==32'hbfaf_f070 |
                        EX_mem_addr==32'hbfaf_f080 | EX_mem_addr==32'hbfaf_f090 |
                        EX_mem_addr==32'hbfaf_e000 | EX_mem_addr==32'hbfaf_ff00 |
                        EX_mem_addr==32'hbfaf_ff10 | EX_mem_addr==32'hbfaf_ff20 |
                        EX_mem_addr==32'hbfaf_ff30 | EX_mem_addr==32'hbfaf_ff40; 
always @(posedge clk) begin
  if(!rstn | WB_flush_csr)begin
    stall_dcache_buf <= 1'b0;
    stall_ex_buf <= 1'b0;
  end
  else begin
    stall_dcache_buf <= stall_dcache;
    stall_ex_buf <= stall_ex;
  end
end

//debug interface
assign debug0_wb_pc = WB_pc_b;
assign debug0_wb_rf_we = {4{WB_rf_we_b&(~stall_dcache_buf)&(~stall_ex_buf)}};
assign debug0_wb_rf_wnum = WB_rf_waddr_b;
assign debug0_wb_rf_wdata = WB_rf_wdata_b;
assign debug1_wb_pc = WB_pc_a;
assign debug1_wb_rf_we = {4{WB_rf_we_a&(~stall_dcache_buf)&(~stall_ex_buf)}};
assign debug1_wb_rf_wnum = WB_rf_waddr_a;
assign debug1_wb_rf_wdata = WB_rf_wdata_a;
endmodule