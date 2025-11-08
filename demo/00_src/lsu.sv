/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off UNUSEDPARAM */
/* verilator lint_off LATCH */
/* verilator lint_off COMBDLY */
/* verilator lint_off SYNCASYNCNET */
/* verilator lint_off MULTIDRIVEN */

`define MEMFILE "../02_test/hex2bcd.mem"
`define MEMSIZE 16384
`define ADDRBIT 16

module lsu (
    input wire i_clk,          // Global clock
    input wire i_reset,        // Global active reset
    input wire [31:0] i_lsu_addr, // Address for data read/write
    input wire [31:0] i_st_data,  // Data to be stored
    input wire i_lsu_wren,     // Write enable signal (1 if writing)
    output reg [31:0] o_ld_data, // Data read from memory
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
    input wire [31:0] i_io_sw,    // Input for switches
    input wire [1:0] i_lsu_op, // 0x: word handle, 10: Half word, 11: byte
    input wire i_ld_un, // 0: for signed, 1: for unsigned extend half word  number

    input wire[31:0] i_pc,
    output reg[31:0] o_instr
);

    // Memory declaration (2KiB)
    reg [31:0] d_mem [`MEMSIZE/4-1:0]; // 16KiB flash+ram

    // Map 0000_0000 - 0000_7FFB Flash
    // Map 8000 - 8FFF Sram

    //  THANH GHI Äá»†M (BUFFER) //
    reg [31:0] sw_buffer;
    reg [31:0] io_buffer[15:0];
    genvar i;
    generate
        for (i = 0; i<16; i++) begin : loop
            initial begin
                io_buffer[i] = 0;
            end    
        end
endgenerate
        
    initial begin
        d_mem = '{default:'0};
    end    

    

    /// io
    assign o_io_ledr = io_buffer[0];
    assign o_io_ledg = io_buffer[1];

    assign o_io_hex0 = io_buffer[2][6:0];
    assign o_io_hex1 = io_buffer[2][14:8];
    assign o_io_hex2 = io_buffer[2][22:16];
    assign o_io_hex3 = io_buffer[2][30:24];

    assign o_io_hex4 = io_buffer[3][6:0];
    assign o_io_hex5 = io_buffer[3][14:8];
    assign o_io_hex6 = io_buffer[3][22:16];
    assign o_io_hex7 = io_buffer[3][30:24];

    assign o_io_lcd = io_buffer[4];
    
    assign sw_buffer = i_io_sw;

    reg [31:0] i_st_data_buffer;
    reg [31:0] i_lsu_addr_buffer;
    reg i_lsu_wren_buffer;

    // Initialize memory from mem.dump
    initial begin
        $readmemh(`MEMFILE, d_mem);
    end

    /// imem máº¡ch tá»• há»£p 
    reg [`ADDRBIT-3:0] pc_addr;
    assign o_instr = d_mem[pc_addr];
    always @(i_pc) begin
        pc_addr <= {1'b0, i_pc[`ADDRBIT-2:2]};//---------------------------8KB intruction memory~2k instruction
    end
    /////cáº¡nh lÃªn (posedge): CPU xuáº¥t dá»¯ liá»‡u má»›i. Cáº¡nh xuá»‘ng (negedge): LSU láº¥y dá»¯ liá»‡u tá»« CPU vÃ  lÆ°u vÃ o buffer.
   // Ä‘áº£m báº£o ráº±ng khi Ä‘áº¿n cáº¡nh lÃªn káº¿ tiáº¿p, dá»¯ liá»‡u Ä‘Ã£ á»•n Ä‘á»‹nh.

    always @(negedge i_clk) begin
        i_lsu_wren_buffer <= i_lsu_wren;
        if (i_lsu_wren) begin
            i_st_data_buffer <= i_st_data;
            i_lsu_addr_buffer <= i_lsu_addr;
        end
    end

    // LSU logic
    always @(posedge i_clk) begin
        if (i_lsu_wren_buffer) begin
            // Memory-mapped I/O handling
            case (i_lsu_addr_buffer[31:16])
                16'h1000: begin// truy cap memory-mapped I/O cho led, hex, lcd
                    if (!i_lsu_op[1]) io_buffer[i_lsu_addr_buffer[15:12]] <= i_st_data_buffer;// ghi word vao ngoáº¡i vi led sw

                    else if (i_lsu_op[1] & ~i_lsu_op[0]) begin// ghi half word 
                        if (!i_lsu_addr_buffer[1]) io_buffer[i_lsu_addr_buffer[15:12]][15:0] <= i_st_data_buffer[15:0];// lower half
                        // Truy cáº­p 16 bit tháº¥p (bits [15:0]) cá»§a pháº§n tá»­ io_buffer thá»© i_lsu_addr_buffer[15:12].â€
                        else io_buffer[i_lsu_addr_buffer[15:12]][31:16] <= i_st_data_buffer[15:0];// upper half
                    end

                    else if (i_lsu_op[1] & i_lsu_op[0]) begin// ghi byte 
                        case (i_lsu_addr_buffer[1:0])
                            2'b00: io_buffer[i_lsu_addr_buffer[15:12]][7:0] <= i_st_data_buffer[7:0];
                            2'b01: io_buffer[i_lsu_addr_buffer[15:12]][15:8] <= i_st_data_buffer[7:0];
                            2'b10: io_buffer[i_lsu_addr_buffer[15:12]][23:16] <= i_st_data_buffer[7:0];
                            2'b11: io_buffer[i_lsu_addr_buffer[15:12]][31:24] <= i_st_data_buffer[7:0];
                        endcase
                    end
                end

                // data Memory access
                16'h0000: begin
                    if (!i_lsu_op[1]) begin// ghi word
                        d_mem[{1'b1, i_lsu_addr_buffer[`ADDRBIT-2:2]}] <= i_st_data_buffer;//  ghi word vao data memory
                    end
                    else if (i_lsu_op[1] & ~i_lsu_op[0]) begin// ghi half word
                        if (!i_lsu_addr_buffer[1]) d_mem[{1'b1, i_lsu_addr_buffer[`ADDRBIT-2:2]}][15:0] <= i_st_data_buffer[15:0];//    lower half
                        else d_mem[{1'b1, i_lsu_addr_buffer[`ADDRBIT-2:2]}][31:16] <= i_st_data_buffer[15:0];//    upper half
                        end
                    else if (i_lsu_op[1] & i_lsu_op[0]) begin
                        case (i_lsu_addr_buffer[1:0])
                            2'b00: d_mem[{1'b1, i_lsu_addr_buffer[`ADDRBIT-2:2]}][7:0] <= i_st_data_buffer[7:0];
                            2'b01: d_mem[{1'b1, i_lsu_addr_buffer[`ADDRBIT-2:2]}][15:8] <= i_st_data_buffer[7:0];
                            2'b10: d_mem[{1'b1, i_lsu_addr_buffer[`ADDRBIT-2:2]}][23:16] <= i_st_data_buffer[7:0];
                            2'b11: d_mem[{1'b1, i_lsu_addr_buffer[`ADDRBIT-2:2]}][31:24] <= i_st_data_buffer[7:0];
                        endcase
                    end
                end

                // Reserved
                default: ;
            endcase
        end
    end

    always @(i_lsu_addr, i_lsu_op, i_ld_un) begin
        if (!i_reset) begin////-------------------------8/11/2025 reset high to reset low
            // Reset outputs
            o_ld_data <= 32'b0;
        end 
        // Memory-mapped I/O handling with read operations
        case (i_lsu_addr[31:16])
            16'h1000: begin
                if (!i_lsu_op[1]) begin 
                    o_ld_data <= io_buffer[i_lsu_addr[15:12]];// doc word tu ngoai vi led sw
                end
                else if (i_lsu_op[1] & ~i_lsu_op[0]) begin
                    if (!i_lsu_addr[1]) begin
                        o_ld_data[15:0] <= io_buffer[i_lsu_addr[15:12]][15:0];
                        o_ld_data[31:16] <= {16{io_buffer[i_lsu_addr[15:12]][15] & ~i_ld_un}};
                    end
                    else begin
                        o_ld_data[15:0] <= io_buffer[i_lsu_addr[15:12]][31:16];
                        o_ld_data[31:16] <= {16{io_buffer[i_lsu_addr[15:12]][31] & ~i_ld_un}};
                    end
                end
                else if (i_lsu_op[1] & i_lsu_op[0]) begin
                    case (i_lsu_addr[1:0])
                        2'b00: begin
                            o_ld_data[7:0] <= io_buffer[i_lsu_addr[15:12]][7:0];
                            o_ld_data[31:8] <= {24{io_buffer[i_lsu_addr[15:12]][7] & ~i_ld_un}};
                        end
                        2'b01: begin
                            o_ld_data[7:0] <= io_buffer[i_lsu_addr[15:12]][15:8];
                            o_ld_data[31:8] <= {24{io_buffer[i_lsu_addr[15:12]][15] & ~i_ld_un}};
                        end
                        2'b10: begin
                            o_ld_data[7:0] <= io_buffer[i_lsu_addr[15:12]][23:16];
                            o_ld_data[31:8] <= {24{io_buffer[i_lsu_addr[15:12]][23] & ~i_ld_un}};
                        end
                        2'b11: begin
                            o_ld_data[7:0] <= io_buffer[i_lsu_addr[15:12]][31:24];
                            o_ld_data[31:8] <= {24{io_buffer[i_lsu_addr[15:12]][31] & ~i_ld_un}};
                        end
                    endcase
                end
            end
            
            // Switches
            16'h1001: begin
                if (!i_lsu_op[1]) begin 
                    o_ld_data <= sw_buffer;
                end
                else if (i_lsu_op[1] & ~i_lsu_op[0]) begin
                    if (!i_lsu_addr[1]) begin
                        o_ld_data[15:0] <= sw_buffer[15:0];
                        o_ld_data[31:16] <= {16{sw_buffer[15] & ~i_ld_un}};
                    end
                    else begin
                        o_ld_data[15:0] <= sw_buffer[31:16];
                        o_ld_data[31:16] <= {16{sw_buffer[31] & ~i_ld_un}};
                    end
                end
                else if (i_lsu_op[1] & i_lsu_op[0]) begin
                    case (i_lsu_addr[1:0])
                        2'b00: begin
                            o_ld_data[7:0] <= sw_buffer[7:0];
                            o_ld_data[31:8] <= {24{sw_buffer[7] & ~i_ld_un}};
                        end
                        2'b01: begin
                            o_ld_data[7:0] <= sw_buffer[15:8];
                            o_ld_data[31:8] <= {24{sw_buffer[15] & ~i_ld_un}};
                        end
                        2'b10: begin
                            o_ld_data[7:0] <= sw_buffer[23:16];
                            o_ld_data[31:8] <= {24{sw_buffer[23] & ~i_ld_un}};
                        end
                        2'b11: begin
                            o_ld_data[7:0] <= sw_buffer[31:24];
                            o_ld_data[31:8] <= {24{sw_buffer[31] & ~i_ld_un}};
                        end
                    endcase
                end
            end

            // Memory access
            16'h0000: begin
                if (!i_lsu_op[1]) begin
                    o_ld_data <= d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}];
                end
                else if (i_lsu_op[1] & ~i_lsu_op[0]) begin
                    if (!i_lsu_addr[1]) begin
                        o_ld_data[15:0] <= d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][15:0];
                        o_ld_data[31:16] <= {16{d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][15] & ~i_ld_un}};
                    end
                    else begin
                        o_ld_data[15:0] <= d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][31:16];
                        o_ld_data[31:16] <= {16{d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][31] & ~i_ld_un}};
                    end
                end
                else begin
                    case (i_lsu_addr[1:0])
                        2'b00: begin
                            o_ld_data[7:0] <= d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][7:0];
                            o_ld_data[31:8] <= {24{d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][7] & ~i_ld_un}};
                        end
                        2'b01: begin
                            o_ld_data[7:0] <= d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][15:8];
                            o_ld_data[31:8] <= {24{d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][15] & ~i_ld_un}};
                        end
                        2'b10: begin
                            o_ld_data[7:0] <= d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][23:16];
                            o_ld_data[31:8] <= {24{d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][23] & ~i_ld_un}};
                        end
                        2'b11: begin
                            o_ld_data[7:0] <= d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][31:24];
                            o_ld_data[31:8] <= {24{d_mem[{1'b1, i_lsu_addr[`ADDRBIT-2:2]}][31] & ~i_ld_un}};
                        end
                    endcase
                    
                end
            end
            
            // Reserved
            default: ;
        endcase
    end

endmodule
    
