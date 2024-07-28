`include "CSR_h.vh"
module CSR(
    input                           clk,
    input                           rstn,
    //software query port (exe stage)
    input                           software_we,//是否允许软件写入
    input           [13:0]          raddr,
    output reg      [31:0]          rdata,  //写优先
    input           [13:0]          waddr,
    input           [31:0]          we,
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
    output [1:0] direct_d_mat  //0: 非缓存, 1: 可缓存
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
assign csr_estat[`ESTAT_IS_0] = estat_is_0;
//龙芯架构32位精简版参考手册 v1.0 p.59 只提到“1个核间中断（IPI），
//1个定时器中断（TI）,8个硬中断（HWI0~HWI7）”
//询问该公司的技术人员后，我们得知
//is[9:2] = hw[7:0] 
//is[10] 是 la64的特有中断，在la32r中恒为0
//is[11] = TI
//is[12] = IPI
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
        if(we[10]) ecfg_lie[10]<=wdata[10];
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
        estat_subecode <= ecode_in[5:0]==0 ? 0:{8'b0,ecode_in[6]};
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
///////////////////////////////////////
//CSR read
always @* begin
    case(waddr)
    `CSR_CRMD     : rdata = csr_crmd     ;
    `CSR_PRMD     : rdata = csr_prmd     ;
    `CSR_ECFG     : rdata = csr_ecfg     ;
    `CSR_ESTAT    : rdata = csr_estat    ;
    `CSR_ERA      : rdata = csr_era      ;
    `CSR_BADV     : rdata = csr_badv     ;
    `CSR_EENTRY   : rdata = csr_eentry   ;
    `CSR_SAVE0    : rdata = csr_save0    ;
    `CSR_SAVE1    : rdata = csr_save1    ;
    `CSR_SAVE2    : rdata = csr_save2    ;
    `CSR_SAVE3    : rdata = csr_save3    ;
    // `CSR_TID      : rdata = csr_tid      ;
    // `CSR_TCFG     : rdata = csr_tcfg     ;
    // `CSR_TVAL     : rdata = csr_tval     ;
    // `CSR_TICLR    : rdata = csr_ticlr    ;
    // `CSR_CTAG     : rdata = csr_ctag     ;
    default       : rdata = 0            ;
    endcase
end
assign plv = crmd_plv;
assign era_out = csr_era;
assign eentry = csr_eentry;
assign has_interrupt_cpu  = crmd_ie&&(ecfg_lie&csr_estat[`ESTAT_IS])!=0;
assign has_interrupt_idle = csr_estat[`ESTAT_IS]!=0;
assign translate_mode = {crmd_pg,crmd_da};
assign direct_i_mat = crmd_datf;
assign direct_d_mat = crmd_datm;
assign ecode = estat_ecode;
//end CSR read
endmodule