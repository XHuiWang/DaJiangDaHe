`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/01 20:35:54
// Design Name: 
// Module Name: mmu_lite
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

//直接映射，纯组合逻辑

module inst_mmu_lite(

input        [31:0]   addr,
input        [31:0]   CRMD,
input        [31:0]   DMW0,
input        [31:0]   DMW1,

output logic [31:0]   paddr,
output logic          uncache
);



//直接翻译模式 DA=1 PG=0
always@(*) begin
    if(CRMD[4] == 1) begin
        paddr   = addr;
        uncache = ~CRMD[5];
    end
    
    else begin
        if(addr[31:29] == DMW0[31:29]) begin
            paddr   = {DMW0[27:25], addr[28:0]};
            uncache = ~DMW0[4];  
        end
        else if(addr[31:29] == DMW1[31:29]) begin
            paddr   = {DMW1[27:25], addr[28:0]};
            uncache = ~DMW1[4];  
        end
        else begin
            paddr   = addr;
            uncache = ~CRMD[5];
        end
    end

end


endmodule
