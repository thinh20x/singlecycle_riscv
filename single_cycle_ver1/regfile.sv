// regfile.sv
module regfile (
    input logic         i_clk,         // Global clock
    input logic         i_reset,         // Global reset (active high)--------------------------------4 /11/ 2025
    input logic [4:0]   i_rs1_addr,    // Address of first source register
    input logic [4:0]   i_rs2_addr,    // Address of second source register
    output logic [31:0] o_rs1_data,    // Data from first source register
    output logic [31:0] o_rs2_data,    // Data from second source register
    input logic [4:0]   i_rd_addr,     // Address of destination register
    input logic [31:0]  i_rd_data,     // Data to write to destination register
    input logic         i_rd_wren      // Write enable for destination register
);

    // Register array: 32 registers of 32 bits each
logic [31:0] regfile [31:0];
	 
always_ff @(posedge i_clk or negedge i_reset) begin
	    if(!i_reset) begin 		                  
	        regfile[0]  <= 32'h0;
            regfile[1]  <= 32'h0;
            regfile[2]  <= 32'h0;
            regfile[3]  <= 32'h0;
            regfile[4]  <= 32'h0;
            regfile[5]  <= 32'h0;
            regfile[6]  <= 32'h0;
            regfile[7]  <= 32'h0;
            regfile[8]  <= 32'h0;
            regfile[9]  <= 32'h0;
            regfile[10] <= 32'h0;
            regfile[11] <= 32'h0;
            regfile[12] <= 32'h0;
            regfile[13] <= 32'h0;
            regfile[14] <= 32'h0;
            regfile[15] <= 32'h0;
            regfile[16] <= 32'h0;
            regfile[17] <= 32'h0;
            regfile[18] <= 32'h0;
            regfile[19] <= 32'h0;
            regfile[20] <= 32'h0;
            regfile[21] <= 32'h0;
            regfile[22] <= 32'h0;
            regfile[23] <= 32'h0;
            regfile[24] <= 32'h0;
            regfile[25] <= 32'h0;
            regfile[26] <= 32'h0;
            regfile[27] <= 32'h0;
            regfile[28] <= 32'h0;
            regfile[29] <= 32'h0;
            regfile[30] <= 32'h0;
            regfile[31] <= 32'h0;
		end else if ( i_rd_wren && i_rd_addr != 5'h0 ) begin
			regfile[i_rd_addr] <=  i_rd_data ;
		end
end 
// Read port 1: read data from regfile[i_rs1_addr]
assign o_rs1_data = (i_rs1_addr == 5'd0) ? 32'h0 : regfile[i_rs1_addr];

	// Read port 2: read data from regfile[i_rs2_addr]
assign o_rs2_data = (i_rs2_addr == 5'd0) ? 32'h0 : regfile[i_rs2_addr];
endmodule 
