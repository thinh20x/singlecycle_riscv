`default_nettype none

module singlecycle_wrapper (
  input  logic [17:0] SW,
  output logic [17:0] LEDR,
  output logic [7:0]  LEDG,
  output logic [6:0]  HEX0, HEX1, HEX2, HEX3,
  output logic [6:0]  HEX4, HEX5, HEX6, HEX7,
  input  logic        CLOCK_50
);

  // Khai báo tất cả signals cần thiết
  logic [31:0] io_lcd, io_ledg_full, io_ledr_full;
  logic [31:0] pc_debug;
  logic [6:0] hex0_data, hex1_data, hex2_data, hex3_data;
  logic [6:0] hex4_data, hex5_data, hex6_data, hex7_data;

  // Instantiate single_cycle với ĐẦY ĐỦ port connections
  single_cycle singleCycle (
    .i_io_sw   ({14'b0, SW[17:0]}),
    .o_io_lcd  (io_lcd),
    .o_io_ledg (io_ledg_full),
    .o_io_ledr (io_ledr_full),
    .o_io_hex0 (hex0_data),
    .o_io_hex1 (hex1_data),
    .o_io_hex2 (hex2_data),
    .o_io_hex3 (hex3_data),
    .o_io_hex4 (hex4_data),
    .o_io_hex5 (hex5_data),
    .o_io_hex6 (hex6_data),
    .o_io_hex7 (hex7_data),
    .o_pc_debug(pc_debug),
    .i_clk     (CLOCK_50),
    .i_reset   (SW[17]),
    .o_insn_vld(LEDG[0])
  );

  // Map outputs
  assign LEDR = io_ledr_full[17:0];
  assign LEDG[7:1] = io_ledg_full[7:1];
  assign HEX0 = hex0_data;
  assign HEX1 = hex1_data;
  assign HEX2 = hex2_data;
  assign HEX3 = hex3_data;
  assign HEX4 = hex4_data;
  assign HEX5 = hex5_data;
  assign HEX6 = hex6_data;
  assign HEX7 = hex7_data;

endmodule : singlecycle_wrapper
