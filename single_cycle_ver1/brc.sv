module brc (
    input logic [31:0] i_rs1_data,   // Operand A (rs1)
    input logic [31:0] i_rs2_data,   // Operand B (rs2)
    input logic i_br_un,             // 0 if signed comparison, 1 if unsigned
    output logic o_br_less,          // 1 if A < B
    output logic o_br_equal          // 1 if A == B
);

    logic [31:0] xor_result;         // Intermediate signal for equality check
    logic A_msb, B_msb;              // Most significant bits (MSB) for signed comparison
    logic A_less_than_B;             // Intermediate signal for less-than check

	
    // Step 1: Equality check using bitwise XOR
    always_comb begin
        xor_result = i_rs1_data ^ i_rs2_data;  // XOR each bit, if all 0s -> equal
        o_br_equal = (xor_result == 32'b0);    // If xor_result is all 0, A == B, o_br_equal=1 
    end

    // Step 2: Less-than check
    always_comb begin
        A_msb = i_rs1_data[31];  // MSB of A
        B_msb = i_rs2_data[31];  // MSB of B

        if (!i_br_un) begin
            // Unsigned comparison: Compare bit-by-bit starting from MSB
            A_less_than_B = 1'b0;
            for (int i = 31; i >= 0; i--) begin
                if (i_rs1_data[i] != i_rs2_data[i]) begin
                    A_less_than_B = (i_rs1_data[i] == 1'b0);
                    break;
                end
            end
        end else begin
            // Signed comparison: Check MSB (sign bit) first
            if (A_msb != B_msb) begin
                A_less_than_B = A_msb;  // If A is negative and B is positive, A < B
            end else begin
                // If both have the same sign, do bitwise comparison
                A_less_than_B = 1'b0;
                for (int i = 30; i >= 0; i--) begin
                    if (i_rs1_data[i] != i_rs2_data[i]) begin
                        A_less_than_B = (i_rs1_data[i] == 1'b0);
                        break;
                    end
                end
            end
        end

        o_br_less = A_less_than_B;  // Set output o_br_less based on the comparison
    end

endmodule
