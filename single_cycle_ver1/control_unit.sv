module control_unit(
    input logic [31:0] i_instr,
    input logic br_less, br_eqal, o_ACK, in_sram,
    output logic pc_sel, rd_wren, insn_vld, br_un, opa_sel, opb_sel, mem_wren,mem_read ,
    output logic [3:0] alu_op,
    output logic [1:0] wb_sel,
	 output logic en_pc,
    output logic [2:0] imm_sel,
	 output logic [2:0] num_byte
);

    logic [3:0] imm_sel_temp;
    logic [2:0] func_3 ;
    logic [6:0] func_7 ;

	 assign func_3 = i_instr[14:12];
	 assign func_7 = i_instr[31:25];
    always_comb begin
        imm_sel_temp = 4'd8;
		  en_pc = 1;
        pc_sel = 0;
        rd_wren = 0;
        insn_vld = 0 ;
        br_un = 0;
        opa_sel = 0;
        opb_sel = 0;
        mem_wren = 0;
		  mem_read =0;
        alu_op = 4'd0;
        wb_sel = 2'd0;
        imm_sel = 3'd0;
        num_byte = 3'd0;
        unique case(i_instr[6:0])
            7'b0010011 : imm_sel_temp = 4'd0; // I1-type
            7'b0100011 : imm_sel_temp = 4'd1; // S-type
            7'b1100011 : imm_sel_temp = 4'd2; // B-type
            7'b1101111 : imm_sel_temp = 4'd3; // J-type
            7'b0010111, 7'b0110111 : imm_sel_temp = 4'd4; // U-type
            7'b0110011 : imm_sel_temp = 4'd5; // R-type
            7'b0000011 : imm_sel_temp = 4'd6; // I2-type
            7'b1100111 : imm_sel_temp = 4'd7; // I3-type
            default: imm_sel_temp = imm_sel_temp;
        endcase

        if (imm_sel_temp == 4'd5) begin // R-type
            pc_sel = 0;
            br_un = 0;
				insn_vld = 1;
            opa_sel = 0;
            opb_sel = 1;
            mem_wren = 0;
            rd_wren = 1;
            wb_sel = 2'b01;
            case({func_3, func_7})
                0   : alu_op = 4'b0000; // add
                32  : alu_op = 4'b0001; // sub
                256 : alu_op = 4'b0010; // slt
                384 : alu_op = 4'b0011; // sltu
                512 : alu_op = 4'b0100; // xor
                768 : alu_op = 4'b0101; // or
                896 : alu_op = 4'b0110; // and
                128 : alu_op = 4'b0111; // sll
                640 : alu_op = 4'b1000; // srl
                672 : alu_op = 4'b1001; // sra
            endcase
        end
        else if (imm_sel_temp == 4'd0) begin // I1-type
            pc_sel = 0;
            br_un = 0;
				insn_vld = 1 ;
            opa_sel = 0;
            opb_sel = 0;
            mem_wren = 0;
            rd_wren = 1;
            wb_sel = 2'b01;
            if (func_3 == 3'b001 || func_3 == 3'b101) begin 
                imm_sel = 1;
                case({func_3, func_7}) 
                    128 : alu_op = 4'b0111; // sll
                    640 : alu_op = 4'b1000; // srl
                    672 : alu_op = 4'b1001; // sra
                endcase
            end else begin
                imm_sel = 0;
                case(func_3)
                    0 : alu_op = 4'b0000; // add
                    2 : alu_op = 4'b0010; // slt
                    3 : alu_op = 4'b0011; // sltu
                    4 : alu_op = 4'b0100; // xor
                    6 : alu_op = 4'b0101; // or
                    7 : alu_op = 4'b0110; // and
                endcase
            end
        end
        else if (imm_sel_temp == 4'd6) begin // I2-type
            imm_sel = 0;
            pc_sel = 0;
				insn_vld = 1 ;
            br_un = 0;
            opa_sel = 0;
            opb_sel = 0;
            mem_wren = 0; // đọc ra từ bộ nhớ
				mem_read =1;
            rd_wren = 1; // cho phép ghi vào regfile
				alu_op = 4'b0000;
            wb_sel = 2'b00; //lấy đường lsu
				if (in_sram == 1) begin
					en_pc = (o_ACK) ? 1:0; //o_ACK = 0 thi cho, o_ACK = 1 thi tieptuc
				end else begin
					en_pc = 1; //luon tiep tuc
				end
            case(func_3)
                0 : num_byte = 3'd0; // lb
                4 : num_byte = 3'd1; // lbu
                1 : num_byte = 3'd2; // lh
                5 : num_byte = 3'd3; // lhu
                2 : num_byte = 3'd4; // lw
            endcase
        end
        else if (imm_sel_temp == 4'd7) begin // I3-type jalr 
            pc_sel = 1;
            rd_wren = 1;
            insn_vld = 1 ;
            br_un = 0;
            opa_sel = 0;
            opb_sel = 0;
            alu_op = 0;
            mem_wren = 0;
            wb_sel = 2'b10;
            imm_sel = 0;
        end
        else if (imm_sel_temp == 4'd1) begin // S-type
            pc_sel = 0;
				insn_vld=1 ;
            rd_wren = 0;//không cho phép ghi vào regfile
            br_un = 0;
            opa_sel = 0;
            opb_sel = 0;
            mem_wren = 1;//cho phép ghi vào bộ nhớ
				mem_read=0;
            wb_sel = 0;	//tùy định	      
            imm_sel = 2;
				alu_op = 4'd0;
				if (in_sram == 1) begin
					en_pc = (o_ACK) ? 1:0; //o_ACK = 0 thi cho, o_ACK = 1 thi tiep tuc
				end else begin
					en_pc = 1;
				end
            case(func_3)
                0 : num_byte = 3'd0; // sb
                1 : num_byte = 3'd2; // sh
                2 : num_byte = 3'd4; // sw
            endcase
        end
        else if (imm_sel_temp == 4'd2) begin // B-type
            imm_sel = 3;
            rd_wren = 0;
            insn_vld = 1 ;
            opb_sel = 0;
            mem_wren = 0;
            br_un = 0;
            opa_sel = 1;
            alu_op = 4'd0;
            wb_sel = 2'b00;
            case(func_3)
                0 : pc_sel = (br_eqal) ? 1 : 0; // beq
                5 : begin // bge 
                    br_un = 1;
                    pc_sel = (br_less) ? 0 : 1;
                end
                7 : begin // bgeu
                    br_un = 0;
                    pc_sel = (br_less) ? 0 : 1;
                end
                4 : begin // blt
                    br_un = 1;
                    pc_sel = (br_less) ? 1 : 0;
                end
                6 : begin // bltu
                    br_un = 0;
                    pc_sel = (br_less) ? 1 : 0;
                end
                1 : pc_sel = (br_eqal) ? 0 : 1; // bne
            endcase
        end
        else if (imm_sel_temp == 4'd3) begin // J-type
            imm_sel = 3'd5;
				insn_vld = 1 ;
            pc_sel = 1;
            rd_wren = 1;
            opa_sel = 1;
            wb_sel = 2'b10;
            alu_op = 0;
				
        end 
        else if (imm_sel_temp == 4'd4) begin // U-type
				insn_vld = 1 ;
            imm_sel = 3'd4;
            pc_sel = 0;
				wb_sel = 2'b01;
            rd_wren = 1;
            opa_sel = 1;
				opb_sel = 0;
				
            case(i_instr[6:0])
                7'b0010111 : alu_op = 4'd0; // auipc
                7'b0110111 : alu_op = 4'd10; // lui+++++++++++++++++++++
            endcase
        end
    end
endmodule
