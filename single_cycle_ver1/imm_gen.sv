module imm_gen (
    input logic [31:0] i_inst,      // 12-bit input data
	 
	 input logic [2:0] imm_sel,
    output logic [31:0] o_imm      // 32-bit output data
);

   /* always_comb begin
        // Check the sign bit (bit 11) of the 12-bit input
        if (i_inst[11] == 1'b1) begin
            // If the sign bit is 1, extend the sign (fill upper bits with 1s)
            o_imm = {20'b11111111111111111111, i_inst}; // Fill with 1's
        end else begin
            // If the sign bit is 0, extend with 0s
            o_imm = {20'b00000000000000000000, i_inst}; // Fill with 0's
        end
    end*/
	 
	  always_comb begin
	  o_imm = 0 ;
        unique case (imm_sel)
            3'd0: o_imm = {{20{i_inst[31]}},i_inst[31:20]}; // I 
				
				3'd1 : o_imm = {{27{i_inst[24]}},i_inst[24:20]}; // I*
				
            3'd2  : o_imm= {{20{i_inst[31]}},i_inst[31:25],i_inst[11:7]}; // S 
				
				3'd3  : o_imm= {{19{i_inst[31]}},i_inst[31],i_inst[7], i_inst[30:25],i_inst[11:8],1'b0}; //B 
				
				3'd4 : o_imm= {i_inst[31:12],12'b0}; // u 
				
				3'd5 : o_imm= {{11{i_inst[31]}},i_inst[31],i_inst[19:12], i_inst[20],i_inst[30:21],1'b0}; // J 
				
				
				
            default: o_imm = 32'b0;
        endcase
    end

endmodule
