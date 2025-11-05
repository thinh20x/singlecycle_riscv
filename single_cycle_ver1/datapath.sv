module datapath (
    input wire i_clk,
    input wire i_reset,
    
    input wire i_pc_sel,
    
    output wire[31:0] o_instr,
    
    input wire [2:0] i_imm_sel,
    
    input wire i_rd_wren,
    
    input wire i_insn_vld,
    
    input wire i_br_un,
    output wire o_br_less,
    output wire o_br_equal,
    
    input wire i_opa_sel,
    input wire i_opb_sel,
    
    input wire[3:0] i_alu_op,
    
    input wire i_mem_wren,
    
    input wire[1:0] i_wb_sel,
    input wire [1:0] i_lsu_op, // 0x: word handle, 10: Half word, 11: byte
    input wire i_ld_un, // 0: for signed, 1: for unsigned

    output wire[31:0] o_pc_debug, //Debug program counter
    output wire o_insn_vld,       // Instruction valid
    output wire [31:0] o_io_ledr, // Output for red LEDs
    output wire [31:0] o_io_ledg, // Output for green LEDs
    output wire [6:0] o_io_hex0,  // Output for 7-segment display 0
    output wire [6:0] o_io_hex1,  // Output for 7-segment display 1
    output wire [6:0] o_io_hex2,  // Output for 7-segment display 2
    output wire [6:0] o_io_hex3,  // Output for 7-segment display 3
    output wire [6:0] o_io_hex4,  // Output for 7-segment display 4
    output wire [6:0] o_io_hex5,  // Output for 7-segment display 5
    output wire [6:0] o_io_hex6,  // Output for 7-segment display 6
    output wire [6:0] o_io_hex7,  // Output for 7-segment display 7
    output wire [31:0] o_io_lcd,  // Output for LCD register
    input wire [31:0] i_io_sw    // Input for switches
);
    // program counter block--------------------------------------
    reg[31:0] pc;
    initial begin
        pc = 0;
    end
    wire[31:0] pc_next, pc_four, alu_data;
    wire[31:0] instr;
    
    //==============mux before pc 
    assign pc_next = (i_pc_sel) ? alu_data : pc_four; // pc_sel = 1 -> alu_data
    
    //--------------------------------------+4 block 
    assign pc_four = pc + 4;
    
    // imem IM(------------------------------------------------------------
    //     .i_clk(i_clk),
    //     .i_reset(i_reset),
    //     .i_pc(pc),
    //     .o_instr(instr)
    // );
    assign o_instr = instr;

    // regfile block--------------------------------------------------------------------------
    wire[31:0] rs1_data, rs2_data, wb_data;
    regfile RF(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_rs1_addr(instr[19:15]),
        .i_rs2_addr(instr[24:20]),
        .o_rs1_data(rs1_data),
        .o_rs2_data(rs2_data),
        .i_rd_addr(instr[11:7]),
        .i_rd_data(wb_data),
        .i_rd_wren(i_rd_wren)
    );
    // immediate block-----------------------------------------------------------
    wire[31:0] imm;
    imm_gen IG(//-------------------------4/11/2025:immgen to imm_gen
        .i_instr(instr[31:7]),
        .i_imm_sel(i_imm_sel), // 
        .o_imm(imm)
    );
    //i_imm_sel=0
    //unique case (i_imm_sel)
    //          3'd0:  I type
	//			
	//			3'd1  I*
				
    //          3'd2   S 
				
	//			3'd3  /B 
				
	//			3'd4  u 
				
	//			3'd5  J 
				
				
    
    // BRC block---------------------------------------------------------------------
    
    
    
    
    brc BR(
        .i_rs1_data(rs1_data),
        .i_rs2_data(rs2_data),
        .i_br_un(i_br_un),// 1 unsigned  /0 signed
        .o_br_less(o_br_less),
        .o_br_equal(o_br_equal)
    );
    
    //-------------------mux opa----------------------------------------------------------
    
    wire[31:0] operand_a, operand_b;
    
    assign operand_a = (i_opa_sel) ? pc : rs1_data;
    
    //----------------mux opb-------------------------------------------
    assign operand_b = (i_opb_sel) ? rs2_data : imm  ;
    
   // ALU block-------------------------------------------------------- 
    alu AL(
        .i_op_a(operand_a),
        .i_op_b(operand_b),
        .i_alu_op(i_alu_op),
        .o_alu_data(alu_data)
    );
    
    // LSU block-------------------------------------------------------
    wire[31:0] ld_data;
    lsu LS(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_lsu_addr(alu_data), // Address for data read/write
        .i_st_data(rs2_data),  // Data to be stored
        .i_lsu_wren(i_mem_wren),     // Write enable signal (1 if writing)
        .o_ld_data(ld_data), // Data read from memory
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
        .i_io_sw(i_io_sw),   // Input for switches
        .i_lsu_op(i_lsu_op), // 0x: word handle, 10: Half word, 11: byte
        .i_ld_un(i_ld_un), // 0: for signed, 1: for unsigned

//===========================imem=======================
        .i_pc(pc),
        .o_instr(instr)
    );
    // Write back
    assign wb_data = (i_wb_sel[1]) ? pc_four : (i_wb_sel[0]) ? alu_data : ld_data; // 1x: pc4, 01: aludata, 00: lddata
    assign o_pc_debug = pc;
    assign o_insn_vld = i_insn_vld;
    //
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            pc <= 32'd0;
        end
        else begin
            pc <= pc_next; // update pc after 1 clk cycle
        end
    end
    
endmodule
