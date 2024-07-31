`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/20 13:29:51
// Design Name: 
// Module Name: TagV_mem
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


module Data_mem_inst #(
    parameter RAM_WIDTH = 128,                       // Specify RAM data width
    parameter RAM_DEPTH = 256,                      // Specify RAM depth (number of entries)
    parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) (
    input [clogb2(RAM_DEPTH-1)-1:0] addra, // Address bus, width determined from RAM_DEPTH
    input [RAM_WIDTH-1:0] dina,          // RAM input data
    input clka,                          // Clock
    input wea,                           // Write enable
    output [RAM_WIDTH-1:0] douta         // RAM output data
  );
  
    (* ram_style = "block" *)
    reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
    reg [clogb2(RAM_DEPTH-1)-1:0] addra_reg;
  
    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
      if (INIT_FILE != "") begin: use_init_file
        initial
          $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
      end else begin: init_bram_to_zero
        integer ram_index;
        initial
          for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
            BRAM[ram_index] = {RAM_WIDTH{1'b0}};
      end
    endgenerate
  
    always @(posedge clka)begin
        if (wea) begin
            BRAM[addra] <= dina;
        end 
    end
    
    always @(posedge clka)begin
        addra_reg <= addra;
    end
  
    assign douta = BRAM[addra_reg];
  
  
    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
      input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
          depth = depth >> 1;
    endfunction
  
  endmodule
