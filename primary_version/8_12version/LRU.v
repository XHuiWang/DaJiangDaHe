`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 17:18:20
// Design Name: 
// Module Name: LRU
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


module LRU(
    input          clk,
    input          LRU_update,
    input          miss_LRU_update,
    input          miss_lru_way,
    input  [1:0]   hit,
    input  [7:0]   w_index,
    output   wire      way_sel
    
    );
    reg [0:0] Lru [0:255];
    generate
        integer ram_index;
        initial
             for (ram_index = 0; ram_index < 256; ram_index = ram_index + 1)
                 Lru[ram_index] = 1'b0;
    endgenerate
    always @(posedge clk) begin
        if(LRU_update) begin
            case(hit)
                2'b00: Lru[w_index] <= Lru[w_index];
                2'b01: Lru[w_index] <= 1'b1;
                2'b10: Lru[w_index] <= 1'b0;
                2'b11: Lru[w_index] <= 1'b1;//impossible
            endcase
        end
        else if(miss_LRU_update) begin
            case(miss_lru_way)
                1'b0: Lru[w_index] <= 1'b1;
                default: Lru[w_index] <= 1'b0;
            endcase
        end
        else Lru[w_index] <= Lru[w_index];    
    end
    assign way_sel = Lru[w_index];

endmodule
