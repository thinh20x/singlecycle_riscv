`timescale 1ns / 1ps 
module alu (
    input  logic [31:0] i_op_a,
    input  logic [31:0] i_op_b,
    input  logic  [3:0] i_alu_op,
    output logic [31:0] o_alu_data
);

    localparam ALU_ADD  = 4'h0;
    localparam ALU_SUB  = 4'h1;
    localparam ALU_SLT  = 4'h2;
    localparam ALU_SLTU = 4'h3;
    localparam ALU_XOR  = 4'h4;
    localparam ALU_OR   = 4'h5;
    localparam ALU_AND  = 4'h6;
    localparam ALU_SLL  = 4'h7;
    localparam ALU_SRL  = 4'h8;
    localparam ALU_SRA  = 4'h9;
    localparam ALU_LUI  = 4'hA; // o_alu_data = i_op_b = output off immgen block

    // ===== Logic operations =====
    logic [31:0] res_xor, res_or, res_and;
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : gen_logic_ops
            assign res_xor[gi] = (i_op_a[gi] & ~i_op_b[gi]) | (~i_op_a[gi] & i_op_b[gi]);
            assign res_or[gi]  = i_op_a[gi] | i_op_b[gi];
            assign res_and[gi] = i_op_a[gi] & i_op_b[gi];
        end
    endgenerate

    // ===== Carry-lookahead adder core =====
    logic [31:0] a, b, p, g, sum_bits;
    logic [32:0] carry;
    logic do_sub;
    logic carry_out, overflow;
    logic [7:0] Pblk, Gblk;
    logic [8:0] carry_blk_in;

    always_comb begin
        do_sub = (i_alu_op == ALU_SUB) || (i_alu_op == ALU_SLT) || (i_alu_op == ALU_SLTU);
        a = i_op_a;
        b = do_sub ? ~i_op_b : i_op_b;
    end

    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : gen_pg_bits
            assign p[gi] = a[gi] ^ b[gi];
            assign g[gi] = a[gi] & b[gi];
        end
    endgenerate

    // --- Block Propagate/Generate ---
    always_comb begin
        automatic integer blk;
        automatic integer base;
        for (blk = 0; blk < 8; blk = blk + 1) begin
            base = blk * 4;
            Pblk[blk] = p[base+3] & p[base+2] & p[base+1] & p[base];
            Gblk[blk] = g[base+3]
                      | (p[base+3] & g[base+2])
                      | (p[base+3] & p[base+2] & g[base+1])
                      | (p[base+3] & p[base+2] & p[base+1] & g[base]);
        end
    end

    // --- Block carry chain ---
    always_comb begin
        automatic integer blk;
        carry_blk_in[0] = do_sub ? 1'b1 : 1'b0;
        for (blk = 0; blk < 8; blk = blk + 1)
            carry_blk_in[blk+1] = Gblk[blk] | (Pblk[blk] & carry_blk_in[blk]);
    end

    // --- Bit-level carry ---
    always_comb begin
        automatic integer blk, base;
        automatic logic c0;
        for (blk = 0; blk < 8; blk = blk + 1) begin
            base = blk * 4;
            c0 = carry_blk_in[blk];
            carry[base+0] = c0;
            carry[base+1] = g[base] | (p[base] & c0);
            carry[base+2] = g[base+1] | (p[base+1] & g[base]) | (p[base+1] & p[base] & c0);
            carry[base+3] = g[base+2]
                          | (p[base+2] & g[base+1])
                          | (p[base+2] & p[base+1] & g[base])
                          | (p[base+2] & p[base+1] & p[base] & c0);
            carry[base+4] = Gblk[blk] | (Pblk[blk] & c0);
        end
    end

    always_comb begin
        automatic integer i;
        for (i = 0; i < 32; i = i + 1)
            sum_bits[i] = p[i] ^ carry[i];
    end

    assign carry_out = carry[32];
    assign overflow = carry[31] ^ carry[32];

    // ===== SLT/SLTU =====
    logic slt_bit, sltu_bit;
    always_comb begin
        automatic logic sign_a, sign_b, sign_result;
        sign_a = i_op_a[31];
        sign_b = i_op_b[31];
        sign_result = sum_bits[31];
        if (sign_a ^ sign_b)
            slt_bit = sign_a;
        else
            slt_bit = sign_result ^ overflow;
        sltu_bit = ~carry_out;
    end

    // ===== Shifters =====
    logic [31:0] res_sll, res_srl, res_sra;
    logic [4:0] shamt;
    assign shamt = i_op_b[4:0];

    always_comb begin
        automatic logic [31:0] tmp;
        tmp = i_op_a;
        if (shamt[0]) tmp = {tmp[30:0], 1'b0};
        if (shamt[1]) tmp = {tmp[29:0], 2'b00};
        if (shamt[2]) tmp = {tmp[27:0], 4'h0};
        if (shamt[3]) tmp = {tmp[23:0], 8'h00};
        if (shamt[4]) tmp = {tmp[15:0], 16'h0000};
        res_sll = tmp;
    end

    always_comb begin
        automatic logic [31:0] tmp;
        tmp = i_op_a;
        if (shamt[0]) tmp = {1'b0, tmp[31:1]};
        if (shamt[1]) tmp = {2'b00, tmp[31:2]};
        if (shamt[2]) tmp = {4'h0, tmp[31:4]};
        if (shamt[3]) tmp = {8'h00, tmp[31:8]};
        if (shamt[4]) tmp = {16'h0000, tmp[31:16]};
        res_srl = tmp;
    end

    always_comb begin
        automatic logic [31:0] tmp;
        automatic logic signbit;
        tmp = i_op_a;
        signbit = tmp[31];
        if (shamt[0]) tmp = {signbit, tmp[31:1]};
        if (shamt[1]) tmp = {{2{signbit}}, tmp[31:2]};
        if (shamt[2]) tmp = {{4{signbit}}, tmp[31:4]};
        if (shamt[3]) tmp = {{8{signbit}}, tmp[31:8]};
        if (shamt[4]) tmp = {{16{signbit}}, tmp[31:16]};
        res_sra = tmp;
    end

    // ===== Final output =====
    always_comb begin
        case (i_alu_op)
            ALU_ADD:  o_alu_data = sum_bits;
            ALU_SUB:  o_alu_data = sum_bits;
            ALU_SLT:  o_alu_data = {31'b0, slt_bit};
            ALU_SLTU: o_alu_data = {31'b0, sltu_bit};
            ALU_XOR:  o_alu_data = res_xor;
            ALU_OR:   o_alu_data = res_or;
            ALU_AND:  o_alu_data = res_and;
            ALU_SLL:  o_alu_data = res_sll;
            ALU_SRL:  o_alu_data = res_srl;
            ALU_SRA:  o_alu_data = res_sra;
            ALU_LUI:  o_alu_data = i_op_b; // with i_op_b = output off immgen
            default:  o_alu_data = 32'b0;
        endcase
    end

endmodule
