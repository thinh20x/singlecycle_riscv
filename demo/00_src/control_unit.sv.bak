module control_unit(
    input logic [31:0] i_instr,
    input logic i_br_less, i_br_equal, //o_ACK, in_sram, 5/11/2025
    output logic o_pc_sel, o_rd_wren, o_insn_vld, o_br_un, o_opa_sel, o_opb_sel, o_mem_wren,//mem_read ,5/11/2025
    output logic [3:0] o_alu_op,
    output logic [1:0] o_wb_sel,
    
	output logic [1:0] o_lsu_op,
	output logic [0:0] o_ld_un,
	 //output logic en_pc,
    output logic [2:0] o_imm_sel//,//5/11/2025 imm_sel to o_imm_sel 
	// output logic [2:0] num_byte
);

    logic [3:0] imm_sel_temp;
    logic [2:0] func_3 ;
    logic [6:0] func_7 ;

	 assign func_3 = i_instr[14:12];
	 assign func_7 = i_instr[31:25];
    always_comb begin
        imm_sel_temp = 4'd8;
		 // en_pc = 1;---------------tổng cộng 12 tín hiêu  control
        o_pc_sel = 0;
        o_rd_wren = 0;
        o_insn_vld = 0 ;
        o_br_un = 0;
        o_opa_sel = 0;
        o_opb_sel = 0;
        o_mem_wren = 0;
		  //mem_read =0;
        o_alu_op = 4'd0;
        o_wb_sel = 2'd0;
        o_imm_sel = 3'd0;
        //num_byte = 3'd0;
        
         o_lsu_op    = 2'b00;      // default word 5/11/2025
        o_ld_un     = 1'b0;         //5/11/2025 default signed extend 
        unique case(i_instr[6:0])
            7'b0010011 : imm_sel_temp = 4'd0; // I1-type tuong duong I* trong refence card
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
            o_pc_sel = 0;
            o_br_un = 0;
			o_insn_vld = 1;
            o_opa_sel = 0;
            o_opb_sel = 1;
            o_mem_wren = 0;
            o_rd_wren = 1;
            o_wb_sel = 2'b01;
            o_imm_sel = 0;//------------5/11/2025
            o_lsu_op = 0;//-----------mặc định  5//11/2025
            o_ld_un = 0;//------------mặc định k dùng 5//11/2025
            case({func_3, func_7})
                0   : o_alu_op = 4'b0000; // add
                32  : o_alu_op = 4'b0001; // sub
                256 : o_alu_op = 4'b0010; // slt
                384 : o_alu_op = 4'b0011; // sltu
                512 : o_alu_op = 4'b0100; // xor
                768 : o_alu_op = 4'b0101; // or
                896 : o_alu_op = 4'b0110; // and
                128 : o_alu_op = 4'b0111; // sll
                640 : o_alu_op = 4'b1000; // srl
                672 : o_alu_op = 4'b1001; // sra
            endcase
        end
        else if (imm_sel_temp == 4'd0) begin // I1-type=======================
            o_pc_sel = 0;
            o_br_un = 0;
			o_insn_vld = 1 ;
            o_opa_sel = 0;
            o_opb_sel = 0;
            o_mem_wren = 0;
            o_rd_wren = 1;
            o_wb_sel = 2'b01;
            //------------------------------
            if (func_3 == 3'b001 || func_3 == 3'b101) begin 
                o_imm_sel = 1;
                case({func_3, func_7}) 
                    128 : o_alu_op = 4'b0111; // sll I*
                    640 : o_alu_op = 4'b1000; // srl
                    672 : o_alu_op = 4'b1001; // sra I*
                endcase
            end else begin
                o_imm_sel = 0;
                case(func_3)
                    0 : o_alu_op = 4'b0000; // add
                    2 : o_alu_op = 4'b0010; // slt
                    3 : o_alu_op = 4'b0011; // sltu
                    4 : o_alu_op = 4'b0100; // xor
                    6 : o_alu_op = 4'b0101; // or
                    7 : o_alu_op = 4'b0110; // and
                endcase
            end//-----------------------------------
        end//======================================
        else if (imm_sel_temp == 4'd6) begin // I2-type LOAD 
            o_imm_sel = 0;
            o_pc_sel = 0;
				o_insn_vld = 1 ;
            o_br_un = 0;
            o_opa_sel = 0;
            o_opb_sel = 0;
            o_mem_wren = 0; // đọc ra từ bộ nhớ
				//mem_read =1;
            o_rd_wren = 1; // cho phép ghi vào regfile
				o_alu_op = 4'b0000;
            o_wb_sel = 2'b00; //lấy đường lsu
				//if (in_sram == 1) begin---------------------------------------
				//	en_pc = (o_ACK) ? 1:0; //o_ACK = 0 thi cho, o_ACK = 1 thi tieptuc
				//end else begin
				//	en_pc = 1; //luon tiep tuc
				//end
            case(func_3)
                0 : begin 
                    o_lsu_op = 2'b11; // lb
                    o_ld_un  = 1'b0;
                end
                4 : begin 
                    o_lsu_op = 2'b11; // lbu
                    o_ld_un  = 1'b1;
                end
                1 : begin 
                    o_lsu_op = 2'b10; // lh
                    o_ld_un  = 1'b0;
                end
                5 : begin 
                    o_lsu_op = 2'b10; // lhu
                    o_ld_un  = 1'b1;
                end
                2 : begin
                    o_lsu_op = 2'b00; // lw
                    o_ld_un  = 1'b0;
                end
                default: begin
                    o_lsu_op = 2'b00;
                    o_ld_un  = 1'b0;
                end
            endcase//---------------------------------------------------------------
        end
        else if (imm_sel_temp == 4'd7) begin // I3-type jalr 
            o_pc_sel = 1;
            o_rd_wren = 1;
            o_insn_vld = 1 ;
            o_br_un = 0;
            o_opa_sel = 0;
            o_opb_sel = 0;
            o_alu_op = 0;
            o_mem_wren = 0;
            o_wb_sel = 2'b10;
            o_imm_sel = 0;
            
        end
        else if (imm_sel_temp == 4'd1) begin // S-type
            o_pc_sel = 0;
				o_insn_vld=1 ;
            o_rd_wren = 0;//không cho phép ghi vào regfile
            o_br_un = 0;
            o_opa_sel = 0;
            o_opb_sel = 0;
            o_mem_wren = 1;//cho phép ghi vào bộ nhớ
				//mem_read=0;
            o_wb_sel = 0;	//tùy định	      
            o_imm_sel = 2;
				o_alu_op = 4'd0;
				//if (in_sram == 1) begin-------------------------------------------------------
				//	en_pc = (o_ACK) ? 1:0; //o_ACK = 0 thi cho, o_ACK = 1 thi tiep tuc
				//end else begin
				//	en_pc = 1;
				//end
            case(func_3) 
                0 : begin// sb
                    o_lsu_op = 2'b11;  
                    o_ld_un  = 1'b1;
                    end
                1 : begin // sh
                    o_lsu_op = 2'b10;  
                    o_ld_un  = 1'b1; 
                    end
                2 : begin // sw
                    o_lsu_op = 2'b00;  
                    o_ld_un  = 1'b1; 
                    end
                
            endcase//------------------------------------------------------------------------------
        end
        else if (imm_sel_temp == 4'd2) begin // B-type
            o_imm_sel = 3;
            o_rd_wren = 0;
            o_insn_vld = 1 ;
            o_opb_sel = 0;
            o_mem_wren = 0;
            o_br_un = 0;
            o_opa_sel = 1;
            o_alu_op = 4'd0;
            o_wb_sel = 2'b00;
            case(func_3)
                0 : o_pc_sel = (i_br_equal) ? 1 : 0; // beq
                5 : begin // bge 
                    o_br_un = 1;
                    o_pc_sel = (i_br_less) ? 0 : 1;
                end
                7 : begin // bgeu
                    o_br_un = 0;
                    o_pc_sel = (i_br_less) ? 0 : 1;
                end
                4 : begin // blt
                    o_br_un = 1;
                    o_pc_sel = (i_br_less) ? 1 : 0;
                end
                6 : begin // bltu
                    o_br_un = 0;
                    o_pc_sel = (i_br_less) ? 1 : 0;
                end
                1 : o_pc_sel = (i_br_equal) ? 0 : 1; // bne
            endcase
        end
        else if (imm_sel_temp == 4'd3) begin // J-type
            o_imm_sel = 3'd5;
				o_insn_vld = 1 ;
            o_pc_sel = 1;
            o_rd_wren = 1;
            o_opa_sel = 1;
            o_wb_sel = 2'b10;
            o_alu_op = 0;
				
        end 
        else if (imm_sel_temp == 4'd4) begin // U-type
				o_insn_vld = 1 ;
            o_imm_sel = 3'd4;
            o_pc_sel = 0;
				o_wb_sel = 2'b01;
            o_rd_wren = 1;
            o_opa_sel = 1;
				o_opb_sel = 0;
				
            case(i_instr[6:0])
                7'b0010111 : o_alu_op = 4'd0; // auipc
                7'b0110111 : o_alu_op = 4'd10; // lui+++++++++++++++++++++
            endcase
        end
    end
endmodule
