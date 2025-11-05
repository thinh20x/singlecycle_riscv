module regfile ( 
  input wire i_clk, // Clock (posedge) 
  input wire i_reset, // Active-high synchronous reset 
  input wire [4:0] i_rs1_addr, // Read register 1 address 
  input wire [4:0] i_rs2_addr, // Read register 2 address 
  input wire [4:0] i_rd_addr, // Write register address 
  input wire [31:0] i_rd_data, // Write data 
  input wire i_rd_wren // Write enable ); // 32 registers of 32 bits 
  
  output wire [31:0] o_rs1_data, // Read data 1 
  output wire [31:0] o_rs2_data, // Read data 2 
 

  reg [31:0] regfile_mem [31:0]; 
  
  integer idx;
  
  always @(posedge i_clk or negedge i_reset) begin 
    if (i_reset) begin // Reset all registers to 0 
      for (idx = 0; idx < 32; idx = idx + 1) 
        regfile_mem[idx] <= 32'b0; 
      end else begin
      if (i_rd_wren && (i_rd_addr != 5'd0)) 
        regfile_mem[i_rd_addr] <= i_rd_data; 
    end 
  end
  
  assign o_rs1_data = regfile_mem[i_rs1_addr]; 
  assign o_rs2_data = regfile_mem[i_rs2_addr]; 
endmodule
