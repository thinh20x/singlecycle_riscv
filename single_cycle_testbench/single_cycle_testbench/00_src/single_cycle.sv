//----------------------------------------------------------------------//
//  Design Note
//----------------------------------------------------------------------//
//  1. Instruction Memory Depth (IMEM): At least 8 kB to run the "isa_1b.hex" or "isa_4b.hex"
//  2. Data        Memory Depth (DMEM): At least 2 kB (0x0000_0000 - 0x0000_07FF)
//  3. IMEM and DMEM are separate memory blocks (Harvard-like structure).


module single_cycle (
    input  logic         i_clk     ,
    input  logic         i_reset   ,
    input  logic [31:0]  i_io_sw   ,
    output logic [31:0]  o_io_ledr ,
    output logic [31:0]  o_io_ledg ,
    output logic [31:0]  o_io_lcd  ,
    output logic [ 6:0]  o_io_hex0 ,
    output logic [ 6:0]  o_io_hex1 ,
    output logic [ 6:0]  o_io_hex2 ,
    output logic [ 6:0]  o_io_hex3 ,
    output logic [ 6:0]  o_io_hex4 ,
    output logic [ 6:0]  o_io_hex5 ,
    output logic [ 6:0]  o_io_hex6 ,
    output logic [ 6:0]  o_io_hex7 ,
    output logic [31:0]  o_pc_debug,
    output logic         o_insn_vld
);



// Top level file of your milestone 2
// Write your code here










endmodule : single_cycle
