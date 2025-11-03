/* ============================================================
 *  Module: regfile.sv
 *  Description: 32×32 Register File for RV32I single-cycle CPU
 *  Author: [Your Name]
 *  Synthesizable version - compatible with Vivado
 * ============================================================ */

module regfile (
    input  wire        i_clk,        // Clock (posedge)
    input  wire        i_reset,      // Active-high synchronous reset
    input  wire [4:0]  i_rs1_addr,   // Read register 1 address
    input  wire [4:0]  i_rs2_addr,   // Read register 2 address
    output wire [31:0] o_rs1_data,   // Read data 1
    output wire [31:0] o_rs2_data,   // Read data 2
    input  wire [4:0]  i_rd_addr,    // Write register address
    input  wire [31:0] i_rd_data,    // Write data
    input  wire        i_rd_wren     // Write enable
);

    // 32 registers of 32 bits
    reg [31:0] regfile_mem [31:0];

    integer idx;

    // -------------------------------
    // Synchronous write + reset logic
    // -------------------------------
    always @(posedge i_clk) begin
        if (i_reset) begin
            // Reset all registers to 0
            for (idx = 0; idx < 32; idx = idx + 1)
                regfile_mem[idx] <= 32'b0;
        end
        else begin
            // Write operation (except x0)
            if (i_rd_wren && (i_rd_addr != 5'd0))
                regfile_mem[i_rd_addr] <= i_rd_data;
        end
    end

    // -------------------------------
    // Combinational read ports
    // -------------------------------
    assign o_rs1_data = regfile_mem[i_rs1_addr];
    assign o_rs2_data = regfile_mem[i_rs2_addr];

endmodule
