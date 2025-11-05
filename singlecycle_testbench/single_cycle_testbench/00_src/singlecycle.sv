module singlecycle (
    input wire i_clk,
    input wire i_reset,
    output reg [31:0] o_pc_debug,
    output reg o_insn_vld,
    output reg [31:0] o_io_ledr, // Output for red LEDs
    output reg [31:0] o_io_ledg, // Output for green LEDs
    output reg [6:0] o_io_hex0,  // Output for 7-segment display 0
    output reg [6:0] o_io_hex1,  // Output for 7-segment display 1
    output reg [6:0] o_io_hex2,  // Output for 7-segment display 2
    output reg [6:0] o_io_hex3,  // Output for 7-segment display 3
    output reg [6:0] o_io_hex4,  // Output for 7-segment display 4
    output reg [6:0] o_io_hex5,  // Output for 7-segment display 5
    output reg [6:0] o_io_hex6,  // Output for 7-segment display 6
    output reg [6:0] o_io_hex7,  // Output for 7-segment display 7
    output reg [31:0] o_io_lcd,  // Output for LCD register
    input wire [31:0] i_io_sw    // Input for switches
);
    wire pc_sel;
    wire[31:0] instr;
    wire [2:0]imm_sel;
    wire rd_wren;
    wire insn_vld;
    wire br_un;
    wire br_less;
    wire br_equal;
    wire opa_sel;
    wire opb_sel;
    wire[3:0] alu_op;
    wire mem_wren;
    wire[1:0] wb_sel;
    wire[1:0] lsu_op;
    wire ld_un;
//--------------------------------------
    control_unit CU(
        //.i_clk(i_clk),//ok
        //.i_reset(i_reset),
        .o_pc_sel(pc_sel),
        .i_instr(instr),
        .o_imm_sel(imm_sel),
        .o_rd_wren(rd_wren),
        .o_insn_vld(insn_vld),
        .o_br_un(br_un),
        .i_br_less(br_less),
        .i_br_equal(br_equal),
        .o_opa_sel(opa_sel),
        .o_opb_sel(opb_sel),
        .o_alu_op(alu_op),
        .o_mem_wren(mem_wren),
        .o_wb_sel(wb_sel),
        .o_lsu_op(lsu_op), // 0x: word handle, 10: Half word, 11: byte
        .o_ld_un(ld_un) // 0: for signed, 1: for unsigned extend half word  numver
    );

  //----------------------------------------------------
    datapath DP(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_pc_sel(pc_sel),
        .o_instr(instr),
        .i_imm_sel(imm_sel),
        .i_rd_wren(rd_wren),
        .i_insn_vld(insn_vld),
        .i_br_un(br_un),
        .o_br_less(br_less),
        .o_br_equal(br_equal),
        .i_opa_sel(opa_sel),
        .i_opb_sel(opb_sel),
        .i_alu_op(alu_op),
        .i_mem_wren(mem_wren),
        .i_wb_sel(wb_sel),
        .i_lsu_op(lsu_op), // 0x: word handle, 10: Half word, 11: byte
        .i_ld_un(ld_un), // 0: for signed, 1: for unsigned

        .o_pc_debug(o_pc_debug), //Debug program counter
        .o_insn_vld(o_insn_vld),       // Instruction valid
        .o_io_ledr(o_io_ledr), // Output for red LEDs
        .o_io_ledg(o_io_ledg), // Output for green LEDs
        .o_io_hex0(o_io_hex0),  // Output for 7-segment display 0
        .o_io_hex1(o_io_hex1),  // Output for 7-segment display 1
        .o_io_hex2(o_io_hex2),  // Output for 7-segment display 2
        .o_io_hex3(o_io_hex3),  // Output for 7-segment display 3
        .o_io_hex4(o_io_hex4),  // Output for 7-segment display 4
        .o_io_hex5(o_io_hex5),  // Output for 7-segment display 5
        .o_io_hex6(o_io_hex6),  // Output for 7-segment display 6
        .o_io_hex7(o_io_hex7),  // Output for 7-segment display 7
        .o_io_lcd(o_io_lcd),  // Output for LCD register
        .i_io_sw(i_io_sw)   // Input for switches
    );

endmodule 
