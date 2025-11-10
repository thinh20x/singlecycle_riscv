### Single Cycle RISC-V Processor Demo

#### Overview
This directory contains a demo implementation of a single-cycle RISC-V processor in Verilog. The design follows the RV32I base instruction set and is optimized for FPGA synthesis using tools like Quartus. It demonstrates basic CPU operations including instruction fetch, decode, execute, memory access, and write-back in a single clock cycle.

Key components:
- **Datapath**: Handles data flow between registers, ALU, memory, and branch logic.
- **Control Unit**: Generates control signals based on opcode and function codes.
- **ALU**: Supports arithmetic, logical, and shift operations.
- **LSU (Load/Store Unit)**: Manages memory reads/writes with byte/halfword/word support.
- **Immediate Generator**: Extracts and extends immediates for different instruction formats.
- **Branch Comparator**: Evaluates branch conditions (e.g., equal, less than).

This demo is part of a larger milestone project for learning digital design and processor architecture.

#### Features
- Supports core RV32I instructions: arithmetic (ADD, SUB, etc.), logical (AND, OR, XOR), shifts (SLL, SRL, SRA), branches (BEQ, BNE, BLT, etc.), loads/stores (LB, LH, LW, SB, SH, SW), jumps (JAL, JALR), and upper immediates (LUI, AUIPC).
- Memory initialization via external `.mem` files (e.g., for instruction and data memory).
- Default cases added to all case statements to prevent synthesis issues (e.g., latches or undefined behavior).
- Optimized for synthesis: Ensures full array initialization (e.g., 2D arrays filled to capacity like 512 rows for 2KB memory).
- Fixes for common issues:
  - **Fix 1**: Ensure 2D arrays (e.g., memory) are fully initialized from `.mem` files to avoid zero logic elements during FPGA compilation. Example: For 2KB memory (2048 bytes), with 4 bytes per row, fill all 512 rows.
  - **Fix 2**: LSU read logic corrected to be purely combinational without reset dependency.
  - **Fix 3**: Added explicit default assignment (`o_ld_data = 32'b0`) for reserved cases in LSU.
  - **Fix 4**: Added default cases in control unit for all opcode and function decodes to handle invalid instructions gracefully.

#### Setup and Compilation
1. **Tools Required**: Quartus II/Prime (version 13.0 or later) for synthesis and simulation.
2. **Clone the Repository**:
   ```
   git clone https://github.com/thinh20x/singlecycle_riscv.git
   cd singlecycle_riscv/demo
   ```
3. **Memory Files**: Place your `.mem` files (e.g., `imem.mem`, `dmem.mem`) in the appropriate directory for initialization.
4. **Compile in Quartus**:
   - Open the project file (`demomilestone2.qpf` or similar).
   - Run Analysis & Synthesis, then Full Compilation.
   - Target FPGA: Cyclone family (adjust as needed).
5. **Simulation**: Use ModelSim or Quartus Simulator to verify waveforms.

#### Usage
- Load a RISC-V binary into instruction memory.
- Synthesize and program to FPGA.
- Monitor outputs via pins or Signal Tap for debugging.

#### Known Issues and Improvements
- Current design is single-cycle, so timing may be critical for high clock speeds.
- No support for exceptions or interrupts (RV32I base only).
- Future enhancements: Pipeline the design for better performance.

#### Contributors
- [thinh20x](https://github.com/thinh20x) - Main developer.

For questions or contributions, open an issue or pull request.

---

To apply this updated README:
1. Navigate to your repo's `demo` directory locally.
2. Create or edit `README.md` with the above content.
3. Commit and push:
   ```
   git add README.md
   git commit -m "Update README.md with professional English description and fixes"
   git push origin main
   ```


//to do
---------------------------fixe 1----------------------------------------
logic element=0 when compile fpga cause of dont write enough value to 2D array(2D array readmem from external file.mem) 
example: 2048=2KB , each row contain 4 byte(2048/4=512row) so musr fill out enough value to 512 row
--------------------------------fix 2
LSu fixed
// ❌ SAI: i_reset trong combinational read
always @(i_lsu_addr, ...) begin
    if (i_reset) ...  // Không hợp lý!
end

// ✅ ĐÚNG: Read logic không cần reset
always @(*) begin
    o_ld_data = ...;  // Chỉ phụ thuộc vào address
end
------------------------------------fix 3-------------------------

add default case 
              end
            end
            
            // Reserved
            default:o_ld_data = 32'b0; // Explicit default ;
        endcase
    end

endmodule
----------------------------------fix 4
adđ default case in control unit

    
