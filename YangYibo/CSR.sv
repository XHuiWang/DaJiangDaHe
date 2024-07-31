`include "CSR_h.vh"
module CSR(
    input                           clk,
    input                           stable_clk, //遗留接口，直接连接clk
    input                           rstn,
    //software query port (exe stage)
    input                           software_we,//是否允许软件写入
    input           [13:0]          raddr_a,    //允许同时读两个地址的数据
    input           [13:0]          raddr_b,
    output reg      [31:0]          rdata_a,    //读优先
    output reg      [31:0]          rdata_b,    //读优先
    input           [13:0]          waddr,
    input           [31:0]          we,         //只能同时写一个地址的数据
    input           [31:0]          wdata,

    //current machine state
    output          [1:0]           plv,    //当前特权等级
    output          [5:0]           ecode,  //例外类型一级编码
    // output          [8:0]           esubcode,//例外类型二级编码

    //exception
    input                           store_state,      //pplv = plv , pie = ie 
    input                           restore_state,    //plv  = pplv, ie  = pie
    input           [6:0]           ecode_in, //例外类型 [5:0] 一级编码 [6] 二级编码
    input                           ecode_we, //例外类型写入使能
    output          [31:0]          era_out,  //例外返回地址
    input           [31:0]          era_in,
    input                           era_we,   //例外返回地址写使能
    input           [31:0]          badv_in,
    input                           badv_we,
    output          [31:0]          eentry,

    //interrupt
    output has_interrupt_cpu,
    output has_interrupt_idle,
    input [7:0] hardware_int,

    //MMU
    output [1:0] translate_mode,    //01: direct, 10: paged
    output [1:0] direct_i_mat, //处于直接地址翻译模式时，存储访问类型
    output [1:0] direct_d_mat, //0: 非缓存, 1: 可缓存

        //timer
    output [31:0] tid
);
reg timer_int;      //定时器中断
//CRMD
reg [`CRMD_PLV]     crmd_plv;
reg [`CRMD_IE]      crmd_ie;
reg [`CRMD_DA]      crmd_da;
reg [`CRMD_PG]      crmd_pg;
reg [`CRMD_DATF]    crmd_datf;
reg [`CRMD_DATM]    crmd_datm;
wire [31:0] csr_crmd;
assign csr_crmd[`CRMD_PLV]  = crmd_plv;
assign csr_crmd[`CRMD_IE]   = crmd_ie;
assign csr_crmd[`CRMD_DA]   = crmd_da;
assign csr_crmd[`CRMD_PG]   = crmd_pg;
assign csr_crmd[`CRMD_DATF] = crmd_datf;
assign csr_crmd[`CRMD_DATM] = crmd_datm;
assign csr_crmd[`CRMD_ZERO] = 0;
//PRMD
reg [`PRMD_PPLV]    prmd_pplv;
reg [`PRMD_PIE]     prmd_pie;
wire [31:0] csr_prmd;
assign csr_prmd[`PRMD_PPLV] = prmd_pplv;
assign csr_prmd[`PRMD_PIE]  = prmd_pie;
assign csr_prmd[`PRMD_ZERO] = 0;
//ECFG
reg [`ECFG_LIE]     ecfg_lie;
wire [31:0] csr_ecfg;
assign csr_ecfg[`ECFG_LIE]  = ecfg_lie;
assign csr_ecfg[`ECFG_ZERO] = 0;
//ESTAT
reg [`ESTAT_IS_0] estat_is_0;
reg [`ESTAT_ECODE] estat_ecode;
reg [`ESTAT_ESUBCODE] estat_subecode;
wire [31:0] csr_estat;
//龙芯架构32位精简版参考手册 v1.0 p.59 只提到“1个核间中断（IPI），
//1个定时器中断（TI）,8个硬中断（HWI0~HWI7）”
//is[1:0]      软件中断
//is[9:2]= HWI[7:0] 硬中断HWI 
//is[10] = 0   la32r中恒为0
//is[11] = TI  定时器中断
//is[12] = IPI 核间中断
assign csr_estat[`ESTAT_IS_0] = estat_is_0;
assign csr_estat[`ESTAT_IS_1] = {1'b0,timer_int,1'b0,hardware_int};
assign csr_estat[`ESTAT_ZERO_0] = 0;
assign csr_estat[`ESTAT_ECODE]  = estat_ecode;
assign csr_estat[`ESTAT_ESUBCODE] = estat_subecode;
assign csr_estat[`ESTAT_ZERO_1] = 0;
//ERA
reg [31:0] csr_era;
//BADV
reg [31:0] csr_badv;
//EENTRY
reg [`EENTRY_VA] eentry_va;
wire [31:0] csr_eentry;
assign csr_eentry[`EENTRY_ZERO] = 0;
assign csr_eentry[`EENTRY_VA]   = eentry_va;
//SAVE0~3
reg [31:0] csr_save0,csr_save1,csr_save2,csr_save3;

//TID
reg [31:0] csr_tid;
//TCFG
reg [`TCFG_EN] tcfg_en;
reg [`TCFG_PERIODIC] tcfg_periodic;
reg [`TCFG_INITVAL] tcfg_initval;
wire [31:0] csr_tcfg;
assign csr_tcfg[`TCFG_EN]   = tcfg_en;
assign csr_tcfg[`TCFG_PERIODIC] = tcfg_periodic;
assign csr_tcfg[`TCFG_INITVAL]  = tcfg_initval;
//TVAL
reg [31:0] csr_tval;
//TICLR
wire[31:0] csr_ticlr = 0;
//CTAG
reg [31:0] csr_ctag;
///////////////////////////////////////
wire [1:0] pg_da_next = {we[4]?wdata[4]:crmd_pg,we[3]?wdata[3]:crmd_da};
///////////////////////////////////////
//CSR update
//CRMD
always @(posedge clk)
    if(~rstn) begin
        crmd_plv <= 0;
        crmd_ie <= 0;
        crmd_da <= 1;
        crmd_pg <= 0;
        crmd_datf <= 0;
        crmd_datm <= 0;
    end else if(restore_state) begin
        crmd_plv <= prmd_pplv;
        crmd_ie <= prmd_pie;
    end else if(store_state) begin
        crmd_plv <= 0;
        crmd_ie <= 0;
    end else if(software_we&&waddr==`CSR_CRMD) begin
        if(we[0]) crmd_plv[0]  <= wdata[0];
        if(we[1]) crmd_plv[1]  <= wdata[1];
        if(we[2]) crmd_ie[2]   <= wdata[2];
        if(we[5]) crmd_datf[5] <= wdata[5];
        if(we[6]) crmd_datf[6] <= wdata[6];
        if(we[7]) crmd_datm[7] <= wdata[7];
        if(we[8]) crmd_datm[8] <= wdata[8];
        //只在{pg,da}处在合法状态时更新
        if(we[3]||we[4]) begin
            if(pg_da_next[0]^pg_da_next[1])
                {crmd_pg,crmd_da} <= pg_da_next;
        end
    end
//PRMD
always @(posedge clk)
    if(~rstn) begin
        prmd_pplv <= 0;
        prmd_pie <= 0;
    end else if(store_state) begin
        prmd_pplv <= crmd_plv;
        prmd_pie  <= crmd_ie;
    end else if(software_we&&waddr==`CSR_PRMD) begin
        if(we[0]) prmd_pplv[0]<=wdata[0];
        if(we[1]) prmd_pplv[1]<=wdata[1];
        if(we[2]) prmd_pie[2] <=wdata[2];
    end
//ECFG
always @(posedge clk)
    if(~rstn) begin
        ecfg_lie <= 0;
    end else if(software_we&&waddr==`CSR_ECFG) begin
        if(we[0]) ecfg_lie[0]<=wdata[0];
        if(we[1]) ecfg_lie[1]<=wdata[1];
        if(we[2]) ecfg_lie[2]<=wdata[2];
        if(we[3]) ecfg_lie[3]<=wdata[3];
        if(we[4]) ecfg_lie[4]<=wdata[4];
        if(we[5]) ecfg_lie[5]<=wdata[5];
        if(we[6]) ecfg_lie[6]<=wdata[6];
        if(we[7]) ecfg_lie[7]<=wdata[7];
        if(we[8]) ecfg_lie[8]<=wdata[8];
        if(we[9]) ecfg_lie[9]<=wdata[9];
        if(we[11]) ecfg_lie[11]<=wdata[11];
        if(we[12]) ecfg_lie[12]<=wdata[12];
    end
//ESTAT
always @(posedge clk)
    if(~rstn) begin
        estat_is_0 <= 0;
        estat_ecode <= 0;
        estat_subecode <= 0;
    end else if(ecode_we) begin
        estat_ecode <= ecode_in[5:0];
        estat_subecode <= (|ecode_in[5:0]) ? {8'b0,ecode_in[6]}:9'b0;   //存在1（非中断例外）? 二级编码 : 0
    end else if(software_we&&waddr==`CSR_ESTAT) begin
        if(we[0]) estat_is_0[0]<=wdata[0];
        if(we[1]) estat_is_0[1]<=wdata[1];
    end
//ERA
always @(posedge clk)
    if(~rstn) begin
        csr_era <= 0;
    end else if(era_we) begin
        csr_era <= era_in;
    end else if(software_we&&waddr==`CSR_ERA) begin
        if(we[ 0]) csr_era[ 0]<=wdata[ 0];
        if(we[ 1]) csr_era[ 1]<=wdata[ 1];
        if(we[ 2]) csr_era[ 2]<=wdata[ 2];
        if(we[ 3]) csr_era[ 3]<=wdata[ 3];
        if(we[ 4]) csr_era[ 4]<=wdata[ 4];
        if(we[ 5]) csr_era[ 5]<=wdata[ 5];
        if(we[ 6]) csr_era[ 6]<=wdata[ 6];
        if(we[ 7]) csr_era[ 7]<=wdata[ 7];
        if(we[ 8]) csr_era[ 8]<=wdata[ 8];
        if(we[ 9]) csr_era[ 9]<=wdata[ 9];
        if(we[10]) csr_era[10]<=wdata[10];
        if(we[11]) csr_era[11]<=wdata[11];
        if(we[12]) csr_era[12]<=wdata[12];
        if(we[13]) csr_era[13]<=wdata[13];
        if(we[14]) csr_era[14]<=wdata[14];
        if(we[15]) csr_era[15]<=wdata[15];
        if(we[16]) csr_era[16]<=wdata[16];
        if(we[17]) csr_era[17]<=wdata[17];
        if(we[18]) csr_era[18]<=wdata[18];
        if(we[19]) csr_era[19]<=wdata[19];
        if(we[20]) csr_era[20]<=wdata[20];
        if(we[21]) csr_era[21]<=wdata[21];
        if(we[22]) csr_era[22]<=wdata[22];
        if(we[23]) csr_era[23]<=wdata[23];
        if(we[24]) csr_era[24]<=wdata[24];
        if(we[25]) csr_era[25]<=wdata[25];
        if(we[26]) csr_era[26]<=wdata[26];
        if(we[27]) csr_era[27]<=wdata[27];
        if(we[28]) csr_era[28]<=wdata[28];
        if(we[29]) csr_era[29]<=wdata[29];
        if(we[30]) csr_era[30]<=wdata[30];
        if(we[31]) csr_era[31]<=wdata[31];
    end
//BADV
always @(posedge clk)
    if(~rstn) begin
        csr_badv <= 0;
    end else if(badv_we) begin
        csr_badv <= badv_in;
    end else if(software_we&&waddr==`CSR_BADV) begin
        if(we[ 0]) csr_badv[ 0]<=wdata[ 0];
        if(we[ 1]) csr_badv[ 1]<=wdata[ 1];
        if(we[ 2]) csr_badv[ 2]<=wdata[ 2];
        if(we[ 3]) csr_badv[ 3]<=wdata[ 3];
        if(we[ 4]) csr_badv[ 4]<=wdata[ 4];
        if(we[ 5]) csr_badv[ 5]<=wdata[ 5];
        if(we[ 6]) csr_badv[ 6]<=wdata[ 6];
        if(we[ 7]) csr_badv[ 7]<=wdata[ 7];
        if(we[ 8]) csr_badv[ 8]<=wdata[ 8];
        if(we[ 9]) csr_badv[ 9]<=wdata[ 9];
        if(we[10]) csr_badv[10]<=wdata[10];
        if(we[11]) csr_badv[11]<=wdata[11];
        if(we[12]) csr_badv[12]<=wdata[12];
        if(we[13]) csr_badv[13]<=wdata[13];
        if(we[14]) csr_badv[14]<=wdata[14];
        if(we[15]) csr_badv[15]<=wdata[15];
        if(we[16]) csr_badv[16]<=wdata[16];
        if(we[17]) csr_badv[17]<=wdata[17];
        if(we[18]) csr_badv[18]<=wdata[18];
        if(we[19]) csr_badv[19]<=wdata[19];
        if(we[20]) csr_badv[20]<=wdata[20];
        if(we[21]) csr_badv[21]<=wdata[21];
        if(we[22]) csr_badv[22]<=wdata[22];
        if(we[23]) csr_badv[23]<=wdata[23];
        if(we[24]) csr_badv[24]<=wdata[24];
        if(we[25]) csr_badv[25]<=wdata[25];
        if(we[26]) csr_badv[26]<=wdata[26];
        if(we[27]) csr_badv[27]<=wdata[27];
        if(we[28]) csr_badv[28]<=wdata[28];
        if(we[29]) csr_badv[29]<=wdata[29];
        if(we[30]) csr_badv[30]<=wdata[30];
        if(we[31]) csr_badv[31]<=wdata[31];
    end
//EENTRY
always @(posedge clk)
    if(~rstn) begin
        eentry_va <= 0;
    end else if(software_we&&waddr==`CSR_EENTRY) begin
        if(we[ 6]) eentry_va[ 6]<=wdata[ 6];
        if(we[ 7]) eentry_va[ 7]<=wdata[ 7];
        if(we[ 8]) eentry_va[ 8]<=wdata[ 8];
        if(we[ 9]) eentry_va[ 9]<=wdata[ 9];
        if(we[10]) eentry_va[10]<=wdata[10];
        if(we[11]) eentry_va[11]<=wdata[11];
        if(we[12]) eentry_va[12]<=wdata[12];
        if(we[13]) eentry_va[13]<=wdata[13];
        if(we[14]) eentry_va[14]<=wdata[14];
        if(we[15]) eentry_va[15]<=wdata[15];
        if(we[16]) eentry_va[16]<=wdata[16];
        if(we[17]) eentry_va[17]<=wdata[17];
        if(we[18]) eentry_va[18]<=wdata[18];
        if(we[19]) eentry_va[19]<=wdata[19];
        if(we[20]) eentry_va[20]<=wdata[20];
        if(we[21]) eentry_va[21]<=wdata[21];
        if(we[22]) eentry_va[22]<=wdata[22];
        if(we[23]) eentry_va[23]<=wdata[23];
        if(we[24]) eentry_va[24]<=wdata[24];
        if(we[25]) eentry_va[25]<=wdata[25];
        if(we[26]) eentry_va[26]<=wdata[26];
        if(we[27]) eentry_va[27]<=wdata[27];
        if(we[28]) eentry_va[28]<=wdata[28];
        if(we[29]) eentry_va[29]<=wdata[29];
        if(we[30]) eentry_va[30]<=wdata[30];
        if(we[31]) eentry_va[31]<=wdata[31];
    end
//SAVE0~3
always @(posedge clk)
    if(~rstn) begin
        csr_save0 <= 0;
    end else if(software_we&&waddr==`CSR_SAVE0) begin
        if(we[ 0]) csr_save0[ 0]<=wdata[ 0];
        if(we[ 1]) csr_save0[ 1]<=wdata[ 1];
        if(we[ 2]) csr_save0[ 2]<=wdata[ 2];
        if(we[ 3]) csr_save0[ 3]<=wdata[ 3];
        if(we[ 4]) csr_save0[ 4]<=wdata[ 4];
        if(we[ 5]) csr_save0[ 5]<=wdata[ 5];
        if(we[ 6]) csr_save0[ 6]<=wdata[ 6];
        if(we[ 7]) csr_save0[ 7]<=wdata[ 7];
        if(we[ 8]) csr_save0[ 8]<=wdata[ 8];
        if(we[ 9]) csr_save0[ 9]<=wdata[ 9];
        if(we[10]) csr_save0[10]<=wdata[10];
        if(we[11]) csr_save0[11]<=wdata[11];
        if(we[12]) csr_save0[12]<=wdata[12];
        if(we[13]) csr_save0[13]<=wdata[13];
        if(we[14]) csr_save0[14]<=wdata[14];
        if(we[15]) csr_save0[15]<=wdata[15];
        if(we[16]) csr_save0[16]<=wdata[16];
        if(we[17]) csr_save0[17]<=wdata[17];
        if(we[18]) csr_save0[18]<=wdata[18];
        if(we[19]) csr_save0[19]<=wdata[19];
        if(we[20]) csr_save0[20]<=wdata[20];
        if(we[21]) csr_save0[21]<=wdata[21];
        if(we[22]) csr_save0[22]<=wdata[22];
        if(we[23]) csr_save0[23]<=wdata[23];
        if(we[24]) csr_save0[24]<=wdata[24];
        if(we[25]) csr_save0[25]<=wdata[25];
        if(we[26]) csr_save0[26]<=wdata[26];
        if(we[27]) csr_save0[27]<=wdata[27];
        if(we[28]) csr_save0[28]<=wdata[28];
        if(we[29]) csr_save0[29]<=wdata[29];
        if(we[30]) csr_save0[30]<=wdata[30];
        if(we[31]) csr_save0[31]<=wdata[31];
    end

always @(posedge clk)
    if(~rstn) begin
        csr_save1 <= 0;
    end else if(software_we&&waddr==`CSR_SAVE1) begin
        if(we[ 0]) csr_save1[ 0]<=wdata[ 0];
        if(we[ 1]) csr_save1[ 1]<=wdata[ 1];
        if(we[ 2]) csr_save1[ 2]<=wdata[ 2];
        if(we[ 3]) csr_save1[ 3]<=wdata[ 3];
        if(we[ 4]) csr_save1[ 4]<=wdata[ 4];
        if(we[ 5]) csr_save1[ 5]<=wdata[ 5];
        if(we[ 6]) csr_save1[ 6]<=wdata[ 6];
        if(we[ 7]) csr_save1[ 7]<=wdata[ 7];
        if(we[ 8]) csr_save1[ 8]<=wdata[ 8];
        if(we[ 9]) csr_save1[ 9]<=wdata[ 9];
        if(we[10]) csr_save1[10]<=wdata[10];
        if(we[11]) csr_save1[11]<=wdata[11];
        if(we[12]) csr_save1[12]<=wdata[12];
        if(we[13]) csr_save1[13]<=wdata[13];
        if(we[14]) csr_save1[14]<=wdata[14];
        if(we[15]) csr_save1[15]<=wdata[15];
        if(we[16]) csr_save1[16]<=wdata[16];
        if(we[17]) csr_save1[17]<=wdata[17];
        if(we[18]) csr_save1[18]<=wdata[18];
        if(we[19]) csr_save1[19]<=wdata[19];
        if(we[20]) csr_save1[20]<=wdata[20];
        if(we[21]) csr_save1[21]<=wdata[21];
        if(we[22]) csr_save1[22]<=wdata[22];
        if(we[23]) csr_save1[23]<=wdata[23];
        if(we[24]) csr_save1[24]<=wdata[24];
        if(we[25]) csr_save1[25]<=wdata[25];
        if(we[26]) csr_save1[26]<=wdata[26];
        if(we[27]) csr_save1[27]<=wdata[27];
        if(we[28]) csr_save1[28]<=wdata[28];
        if(we[29]) csr_save1[29]<=wdata[29];
        if(we[30]) csr_save1[30]<=wdata[30];
        if(we[31]) csr_save1[31]<=wdata[31];
    end

always @(posedge clk)
    if(~rstn) begin
        csr_save2 <= 0;
    end else if(software_we&&waddr==`CSR_SAVE2) begin
        if(we[ 0]) csr_save2[ 0]<=wdata[ 0];
        if(we[ 1]) csr_save2[ 1]<=wdata[ 1];
        if(we[ 2]) csr_save2[ 2]<=wdata[ 2];
        if(we[ 3]) csr_save2[ 3]<=wdata[ 3];
        if(we[ 4]) csr_save2[ 4]<=wdata[ 4];
        if(we[ 5]) csr_save2[ 5]<=wdata[ 5];
        if(we[ 6]) csr_save2[ 6]<=wdata[ 6];
        if(we[ 7]) csr_save2[ 7]<=wdata[ 7];
        if(we[ 8]) csr_save2[ 8]<=wdata[ 8];
        if(we[ 9]) csr_save2[ 9]<=wdata[ 9];
        if(we[10]) csr_save2[10]<=wdata[10];
        if(we[11]) csr_save2[11]<=wdata[11];
        if(we[12]) csr_save2[12]<=wdata[12];
        if(we[13]) csr_save2[13]<=wdata[13];
        if(we[14]) csr_save2[14]<=wdata[14];
        if(we[15]) csr_save2[15]<=wdata[15];
        if(we[16]) csr_save2[16]<=wdata[16];
        if(we[17]) csr_save2[17]<=wdata[17];
        if(we[18]) csr_save2[18]<=wdata[18];
        if(we[19]) csr_save2[19]<=wdata[19];
        if(we[20]) csr_save2[20]<=wdata[20];
        if(we[21]) csr_save2[21]<=wdata[21];
        if(we[22]) csr_save2[22]<=wdata[22];
        if(we[23]) csr_save2[23]<=wdata[23];
        if(we[24]) csr_save2[24]<=wdata[24];
        if(we[25]) csr_save2[25]<=wdata[25];
        if(we[26]) csr_save2[26]<=wdata[26];
        if(we[27]) csr_save2[27]<=wdata[27];
        if(we[28]) csr_save2[28]<=wdata[28];
        if(we[29]) csr_save2[29]<=wdata[29];
        if(we[30]) csr_save2[30]<=wdata[30];
        if(we[31]) csr_save2[31]<=wdata[31];
    end

always @(posedge clk)
    if(~rstn) begin
        csr_save3 <= 0;
    end else if(software_we&&waddr==`CSR_SAVE3) begin
        if(we[ 0]) csr_save3[ 0]<=wdata[ 0];
        if(we[ 1]) csr_save3[ 1]<=wdata[ 1];
        if(we[ 2]) csr_save3[ 2]<=wdata[ 2];
        if(we[ 3]) csr_save3[ 3]<=wdata[ 3];
        if(we[ 4]) csr_save3[ 4]<=wdata[ 4];
        if(we[ 5]) csr_save3[ 5]<=wdata[ 5];
        if(we[ 6]) csr_save3[ 6]<=wdata[ 6];
        if(we[ 7]) csr_save3[ 7]<=wdata[ 7];
        if(we[ 8]) csr_save3[ 8]<=wdata[ 8];
        if(we[ 9]) csr_save3[ 9]<=wdata[ 9];
        if(we[10]) csr_save3[10]<=wdata[10];
        if(we[11]) csr_save3[11]<=wdata[11];
        if(we[12]) csr_save3[12]<=wdata[12];
        if(we[13]) csr_save3[13]<=wdata[13];
        if(we[14]) csr_save3[14]<=wdata[14];
        if(we[15]) csr_save3[15]<=wdata[15];
        if(we[16]) csr_save3[16]<=wdata[16];
        if(we[17]) csr_save3[17]<=wdata[17];
        if(we[18]) csr_save3[18]<=wdata[18];
        if(we[19]) csr_save3[19]<=wdata[19];
        if(we[20]) csr_save3[20]<=wdata[20];
        if(we[21]) csr_save3[21]<=wdata[21];
        if(we[22]) csr_save3[22]<=wdata[22];
        if(we[23]) csr_save3[23]<=wdata[23];
        if(we[24]) csr_save3[24]<=wdata[24];
        if(we[25]) csr_save3[25]<=wdata[25];
        if(we[26]) csr_save3[26]<=wdata[26];
        if(we[27]) csr_save3[27]<=wdata[27];
        if(we[28]) csr_save3[28]<=wdata[28];
        if(we[29]) csr_save3[29]<=wdata[29];
        if(we[30]) csr_save3[30]<=wdata[30];
        if(we[31]) csr_save3[31]<=wdata[31];
    end
//TID
always @(posedge clk)
    if(~rstn) begin
        csr_tid <= 0;
    end else if(software_we&&waddr==`CSR_TID) begin
        if(we[ 0]) csr_tid[ 0]<=wdata[ 0];
        if(we[ 1]) csr_tid[ 1]<=wdata[ 1];
        if(we[ 2]) csr_tid[ 2]<=wdata[ 2];
        if(we[ 3]) csr_tid[ 3]<=wdata[ 3];
        if(we[ 4]) csr_tid[ 4]<=wdata[ 4];
        if(we[ 5]) csr_tid[ 5]<=wdata[ 5];
        if(we[ 6]) csr_tid[ 6]<=wdata[ 6];
        if(we[ 7]) csr_tid[ 7]<=wdata[ 7];
        if(we[ 8]) csr_tid[ 8]<=wdata[ 8];
        if(we[ 9]) csr_tid[ 9]<=wdata[ 9];
        if(we[10]) csr_tid[10]<=wdata[10];
        if(we[11]) csr_tid[11]<=wdata[11];
        if(we[12]) csr_tid[12]<=wdata[12];
        if(we[13]) csr_tid[13]<=wdata[13];
        if(we[14]) csr_tid[14]<=wdata[14];
        if(we[15]) csr_tid[15]<=wdata[15];
        if(we[16]) csr_tid[16]<=wdata[16];
        if(we[17]) csr_tid[17]<=wdata[17];
        if(we[18]) csr_tid[18]<=wdata[18];
        if(we[19]) csr_tid[19]<=wdata[19];
        if(we[20]) csr_tid[20]<=wdata[20];
        if(we[21]) csr_tid[21]<=wdata[21];
        if(we[22]) csr_tid[22]<=wdata[22];
        if(we[23]) csr_tid[23]<=wdata[23];
        if(we[24]) csr_tid[24]<=wdata[24];
        if(we[25]) csr_tid[25]<=wdata[25];
        if(we[26]) csr_tid[26]<=wdata[26];
        if(we[27]) csr_tid[27]<=wdata[27];
        if(we[28]) csr_tid[28]<=wdata[28];
        if(we[29]) csr_tid[29]<=wdata[29];
        if(we[30]) csr_tid[30]<=wdata[30];
        if(we[31]) csr_tid[31]<=wdata[31];
    end

//TCFG
always @(posedge clk)
    if(~rstn) begin
        tcfg_en <= 0;
        tcfg_initval <= 0;
        tcfg_periodic<=0;
    end else if(software_we&&waddr==`CSR_TCFG) begin
        if(we[ 0]) tcfg_en[ 0]     <=wdata[ 0];
        if(we[ 1]) tcfg_periodic[1]<=wdata[ 1];
        if(we[ 2]) tcfg_initval[ 2]<=wdata[ 2];
        if(we[ 3]) tcfg_initval[ 3]<=wdata[ 3];
        if(we[ 4]) tcfg_initval[ 4]<=wdata[ 4];
        if(we[ 5]) tcfg_initval[ 5]<=wdata[ 5];
        if(we[ 6]) tcfg_initval[ 6]<=wdata[ 6];
        if(we[ 7]) tcfg_initval[ 7]<=wdata[ 7];
        if(we[ 8]) tcfg_initval[ 8]<=wdata[ 8];
        if(we[ 9]) tcfg_initval[ 9]<=wdata[ 9];
        if(we[10]) tcfg_initval[10]<=wdata[10];
        if(we[11]) tcfg_initval[11]<=wdata[11];
        if(we[12]) tcfg_initval[12]<=wdata[12];
        if(we[13]) tcfg_initval[13]<=wdata[13];
        if(we[14]) tcfg_initval[14]<=wdata[14];
        if(we[15]) tcfg_initval[15]<=wdata[15];
        if(we[16]) tcfg_initval[16]<=wdata[16];
        if(we[17]) tcfg_initval[17]<=wdata[17];
        if(we[18]) tcfg_initval[18]<=wdata[18];
        if(we[19]) tcfg_initval[19]<=wdata[19];
        if(we[20]) tcfg_initval[20]<=wdata[20];
        if(we[21]) tcfg_initval[21]<=wdata[21];
        if(we[22]) tcfg_initval[22]<=wdata[22];
        if(we[23]) tcfg_initval[23]<=wdata[23];
        if(we[24]) tcfg_initval[24]<=wdata[24];
        if(we[25]) tcfg_initval[25]<=wdata[25];
        if(we[26]) tcfg_initval[26]<=wdata[26];
        if(we[27]) tcfg_initval[27]<=wdata[27];
        if(we[28]) tcfg_initval[28]<=wdata[28];
        if(we[29]) tcfg_initval[29]<=wdata[29];
        if(we[30]) tcfg_initval[30]<=wdata[30];
        if(we[31]) tcfg_initval[31]<=wdata[31];
    end

reg just_set_timer;
always @(posedge clk)
    if(~rstn) just_set_timer<=0;
    else if(software_we && waddr==`CSR_TCFG && we!=0)
        just_set_timer<=1;
    else just_set_timer<=0;

//TVAL
reg time_out;   //定时器计时是否完成
always @(posedge stable_clk)
    if(~rstn) begin
        csr_tval <= 0;
        time_out <= 0;
    end
    //FIXME: 设置TCFG.InitVal后自动重置定时器，这在手册中未提及
    else if(csr_tval==0||just_set_timer) begin
        time_out <= 0;
        //循环计数模式下，定时器计时完成后自动重置
        //计时器的初始值比标准大1，否则给定时器设置0无法触发中断
        if(tcfg_periodic||just_set_timer) csr_tval<={tcfg_initval[`TCFG_INITVAL],2'd1};
    end else if(tcfg_en) begin
        csr_tval<=csr_tval-1;
        time_out<=csr_tval==1;
    end

//TICLR
always @(posedge stable_clk)
    if(~rstn||software_we && waddr==`CSR_TICLR && we[`TICLR_CLR] && wdata[`TICLR_CLR])
        timer_int <= 0;
    else if(time_out)
        timer_int <= 1;

//CTAG
always @(posedge clk)
    if(~rstn) begin
        csr_ctag <= 0;
    end else if(software_we&&waddr==`CSR_CTAG) begin
        if(we[ 0]) csr_ctag[ 0]<=wdata[ 0];
        if(we[ 1]) csr_ctag[ 1]<=wdata[ 1];
        if(we[ 2]) csr_ctag[ 2]<=wdata[ 2];
        if(we[ 3]) csr_ctag[ 3]<=wdata[ 3];
        if(we[ 4]) csr_ctag[ 4]<=wdata[ 4];
        if(we[ 5]) csr_ctag[ 5]<=wdata[ 5];
        if(we[ 6]) csr_ctag[ 6]<=wdata[ 6];
        if(we[ 7]) csr_ctag[ 7]<=wdata[ 7];
        if(we[ 8]) csr_ctag[ 8]<=wdata[ 8];
        if(we[ 9]) csr_ctag[ 9]<=wdata[ 9];
        if(we[10]) csr_ctag[10]<=wdata[10];
        if(we[11]) csr_ctag[11]<=wdata[11];
        if(we[12]) csr_ctag[12]<=wdata[12];
        if(we[13]) csr_ctag[13]<=wdata[13];
        if(we[14]) csr_ctag[14]<=wdata[14];
        if(we[15]) csr_ctag[15]<=wdata[15];
        if(we[16]) csr_ctag[16]<=wdata[16];
        if(we[17]) csr_ctag[17]<=wdata[17];
        if(we[18]) csr_ctag[18]<=wdata[18];
        if(we[19]) csr_ctag[19]<=wdata[19];
        if(we[20]) csr_ctag[20]<=wdata[20];
        if(we[21]) csr_ctag[21]<=wdata[21];
        if(we[22]) csr_ctag[22]<=wdata[22];
        if(we[23]) csr_ctag[23]<=wdata[23];
        if(we[24]) csr_ctag[24]<=wdata[24];
        if(we[25]) csr_ctag[25]<=wdata[25];
        if(we[26]) csr_ctag[26]<=wdata[26];
        if(we[27]) csr_ctag[27]<=wdata[27];
        if(we[28]) csr_ctag[28]<=wdata[28];
        if(we[29]) csr_ctag[29]<=wdata[29];
        if(we[30]) csr_ctag[30]<=wdata[30];
        if(we[31]) csr_ctag[31]<=wdata[31];
    end
///////////////////////////////////////
//CSR read
always @* begin
    case(raddr_a)
    `CSR_CRMD     : rdata_a = csr_crmd     ;
    `CSR_PRMD     : rdata_a = csr_prmd     ;
    `CSR_ECFG     : rdata_a = csr_ecfg     ;
    `CSR_ESTAT    : rdata_a = csr_estat    ;
    `CSR_ERA      : rdata_a = csr_era      ;
    `CSR_BADV     : rdata_a = csr_badv     ;
    `CSR_EENTRY   : rdata_a = csr_eentry   ;
    `CSR_SAVE0    : rdata_a = csr_save0    ;
    `CSR_SAVE1    : rdata_a = csr_save1    ;
    `CSR_SAVE2    : rdata_a = csr_save2    ;
    `CSR_SAVE3    : rdata_a = csr_save3    ;
    `CSR_TID      : rdata_a = csr_tid      ;
    `CSR_TCFG     : rdata_a = csr_tcfg     ;
    `CSR_TVAL     : rdata_a = csr_tval     ;
    `CSR_TICLR    : rdata_a = csr_ticlr    ;
    `CSR_CTAG     : rdata_a = csr_ctag     ;
    default       : rdata_a = 0            ;
    endcase

    case(raddr_b)
    `CSR_CRMD     : rdata_b = csr_crmd     ;
    `CSR_PRMD     : rdata_b = csr_prmd     ;
    `CSR_ECFG     : rdata_b = csr_ecfg     ;
    `CSR_ESTAT    : rdata_b = csr_estat    ;
    `CSR_ERA      : rdata_b = csr_era      ;
    `CSR_BADV     : rdata_b = csr_badv     ;
    `CSR_EENTRY   : rdata_b = csr_eentry   ;
    `CSR_SAVE0    : rdata_b = csr_save0    ;
    `CSR_SAVE1    : rdata_b = csr_save1    ;
    `CSR_SAVE2    : rdata_b = csr_save2    ;
    `CSR_SAVE3    : rdata_b = csr_save3    ;
    `CSR_TID      : rdata_b = csr_tid      ;
    `CSR_TCFG     : rdata_b = csr_tcfg     ;
    `CSR_TVAL     : rdata_b = csr_tval     ;
    `CSR_TICLR    : rdata_b = csr_ticlr    ;
    `CSR_CTAG     : rdata_b = csr_ctag     ;
    default       : rdata_b = 0            ;
    endcase
end
assign plv = crmd_plv;
assign era_out = csr_era;
assign eentry = csr_eentry;
assign has_interrupt_cpu  = crmd_ie & (|(ecfg_lie&csr_estat[`ESTAT_IS]));
assign has_interrupt_idle = |csr_estat[`ESTAT_IS];
assign translate_mode = {crmd_pg,crmd_da};
assign direct_i_mat = crmd_datf;
assign direct_d_mat = crmd_datm;
assign ecode = estat_ecode;
assign tid = csr_tid;
//end CSR read
endmodule