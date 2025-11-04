////////////////////////////////////////////////////////////////
//
// CTMT_L01_07
//
// Filename                  : alu.sv
// Description               : 
//                             
// Author                    : nhat.leminh0254@gmail.com
//
// Created On                : Tue Jul 07 22:34:00 2025
// History (Date, Changed By):
//            Jul 01 2025, ngmquan & nhatle, create module.
//            Jul 07 2025, nhatle, fix col_buf.
//            Aug 12 2025, nhatle, modify array index range.
////////////////////////////////////////////////////////////////
module ALU
(
  input  logic [31:0] i_op_a ,
  input  logic [31:0] i_op_b ,
  input  logic [ 3:0] i_alu_op ,
  
  output logic [31:0] o_alu_data
);
  
  logic [31:0] add_result;
  logic [31:0] sub_result;
  logic [31:0] sll_result;
  logic [31:0] slt_result ;
  logic [31:0] sltu_result ;
  logic [31:0] srl_result ;
  logic [31:0] sra_result ;

  addsub_32b            ALU_ADD (.A( i_op_a ), .B( i_op_b ), .add_sub( 1'b0 ), .S( add_result ), .carry_o());
  addsub_32b            ALU_SUB (.A( i_op_a ), .B( i_op_b ), .add_sub( 1'b1 ), .S( sub_result ), .carry_o());
  shift_left_32b        ALU_SLL (.a( i_op_a ), .b( i_op_b ), .y( sll_result ));
  shift_right_32b       ALU_SRL (.a( i_op_a ), .b( i_op_b ), .y( srl_result ));
  shift_right_arith     ALU_SRA (.a( i_op_a ), .b( i_op_b ), .y( sra_result ));
  slt_sltu              ALU_SLT (.in1( i_op_a ), .in2( i_op_b ), .slt_o( slt_result ), .sltu_o( sltu_result ));

  always@(*)
    begin
        case( i_alu_op )
            4'b0000 :  o_alu_data <= add_result ;
            4'b0001 :  o_alu_data <= sub_result ;
            4'b0010 :  o_alu_data <= sll_result ;
            4'b0011 :  o_alu_data <= slt_result ;
            4'b0100 :  o_alu_data <= sltu_result ;
            4'b0101 :  o_alu_data <= i_op_a ^ i_op_b ;
            4'b0110 :  o_alu_data <= srl_result ;
            4'b0111 :  o_alu_data <= sra_result ;
            4'b1000 :  o_alu_data <= i_op_a | i_op_b ;
            4'b1001 :  o_alu_data <= i_op_a & i_op_b ;
            default:    o_alu_data <= 32'b0;
        endcase
    end

endmodule: ALU

module addsub_32b 
(
  input  logic [31: 0] A, B,
  input  logic add_sub,
  
  output logic [31: 0] S,
  output logic carry_o
);
  logic [7:0] carry_in ;
  
  addsub_4b byte_03_00 (.A( A[ 3: 0] ), .B( B[ 3: 0] ), .sel( add_sub ), .Cin( add_sub     ), .S( S[ 3: 0] ), .Co( carry_in[0] ));
  addsub_4b byte_07_04 (.A( A[ 7: 4] ), .B( B[ 7: 4] ), .sel( add_sub ), .Cin( carry_in[0] ), .S( S[ 7: 4] ), .Co( carry_in[1] ));
  addsub_4b byte_11_08 (.A( A[11: 8] ), .B( B[11: 8] ), .sel( add_sub ), .Cin( carry_in[1] ), .S( S[11: 8] ), .Co( carry_in[2] ));
  addsub_4b byte_15_12 (.A( A[15:12] ), .B( B[15:12] ), .sel( add_sub ), .Cin( carry_in[2] ), .S( S[15:12] ), .Co( carry_in[3] ));
  addsub_4b byte_19_16 (.A( A[19:16] ), .B( B[19:16] ), .sel( add_sub ), .Cin( carry_in[3] ), .S( S[19:16] ), .Co( carry_in[4] ));
  addsub_4b byte_23_20 (.A( A[23:20] ), .B( B[23:20] ), .sel( add_sub ), .Cin( carry_in[4] ), .S( S[23:20] ), .Co( carry_in[5] ));
  addsub_4b byte_27_24 (.A( A[27:24] ), .B( B[27:24] ), .sel( add_sub ), .Cin( carry_in[5] ), .S( S[27:24] ), .Co( carry_in[6] ));
  addsub_4b byte_31_28 (.A( A[31:28] ), .B( B[31:28] ), .sel( add_sub ), .Cin( carry_in[6] ), .S( S[31:28] ), .Co( carry_in[7] ));

  assign carry_o = carry_in[7] ;

endmodule: addsub_32b

module addsub_4b
(
  input  logic [3:0] A, B,
  input  logic sel, Cin,
  output logic [3:0] S,
  output logic Co
);
  logic [2:0] c;
  logic [3:0] b;
  
  assign b[0] = B[0] ^ sel ; //----------------------------------------------------------
  assign b[1] = B[1] ^ sel ; // sel = 0 if ADD ( b^0 =  b ) 
  assign b[2] = B[2] ^ sel ; // sel = 1 if SUB ( b^1 = ~b )
  assign b[3] = B[3] ^ sel ; //----------------------------------------------------------
  
  fulladder u0( .A( A[0] ), .B( b[0] ), .Ci( Cin  ), .S( S[0] ), .Co( c[0] )); // Cin shoulb be 'sel': SUB when (sel = 1), a - b = a + (~b) + 1 
  fulladder u1( .A( A[1] ), .B( b[1] ), .Ci( c[0] ), .S( S[1] ), .Co( c[1] ));
  fulladder u2( .A( A[2] ), .B( b[2] ), .Ci( c[1] ), .S( S[2] ), .Co( c[2] ));
  fulladder u3( .A( A[3] ), .B( b[3] ), .Ci( c[2] ), .S( S[3] ), .Co( Co   ));

  
endmodule: addsub_4b

module fulladder
(
  input  logic A, B, Ci,
  output logic S, Co
);
  assign  S  = A ^ B ^ Ci;
  assign  Co = (A & B)|(A & Ci)|(B & Ci);

endmodule:  fulladder

module shift_left_32b (
    input  logic [31:0] a,
    input  logic [31:0] b,        
    output logic [31:0] y
);
    logic [4:0] shamt;
    assign shamt = b[4:0];

    // --------- SLL (Shift Left Logical) ----------
    logic [31:0] sll0, sll1, sll2, sll3, sll4;
    assign sll0 = shamt[0] ? {a[30:0], 1'b0}       : a;
    assign sll1 = shamt[1] ? {sll0[29:0], 2'b0}    : sll0;
    assign sll2 = shamt[2] ? {sll1[27:0], 4'b0}    : sll1;
    assign sll3 = shamt[3] ? {sll2[23:0], 8'b0}    : sll2;
    assign sll4 = shamt[4] ? {sll3[15:0],16'b0}    : sll3;

    assign y = sll4;

endmodule: shift_left_32b

module shift_right_32b (
    input  logic [31:0] a,        
    input  logic [31:0] b,       
    output logic [31:0] y
);
    logic [4:0] shamt;
    assign shamt = b[4:0];

 // --------- SRL (Shift Right Logical) ----------
    logic [31:0] srl0, srl1, srl2, srl3, srl4;
    assign srl0 = shamt[0] ? {1'b0, a[31:1]}       : a;
    assign srl1 = shamt[1] ? {2'b0, srl0[31:2]}    : srl0;
    assign srl2 = shamt[2] ? {4'b0, srl1[31:4]}    : srl1;
    assign srl3 = shamt[3] ? {8'b0, srl2[31:8]}    : srl2;
    assign srl4 = shamt[4] ? {16'b0, srl3[31:16]}  : srl3;

    assign y = srl4;
endmodule: shift_right_32b

module shift_right_arith (
    input  logic [31:0] a,        
    input  logic [31:0] b,       
    output logic [31:0] y
);
    logic [4:0] shamt;
    assign shamt = b[4:0];

    // --------- SRA (Shift Right Arithmetic) ----------
    logic [31:0] sra0, sra1, sra2, sra3, sra4;
    assign sra0 = shamt[0] ? {{1{a[31]}}, a[31:1]}        : a;
    assign sra1 = shamt[1] ? {{2{a[31]}}, sra0[31:2]}     : sra0;
    assign sra2 = shamt[2] ? {{4{a[31]}}, sra1[31:4]}     : sra1;
    assign sra3 = shamt[3] ? {{8{a[31]}}, sra2[31:8]}     : sra2;
    assign sra4 = shamt[4] ? {{16{a[31]}}, sra3[31:16]}   : sra3;

    assign y = sra4;

endmodule: shift_right_arith

module slt_sltu (
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    output logic [31:0] slt_o,
    output logic [31:0] sltu_o
);
  logic [31:0] sub_result;
  logic        carry_o;

  addsub_32b ALU_SUB (
      .A      (in1),
      .B      (in2),
      .add_sub(1'b1),
      .S      (sub_result),
      .carry_o(carry_o)
  );
  // SLTU (unsigned less than)
  assign sltu_o = {31'b0, ~carry_o};

  // SLT (signed less than)
  logic slt_temp;
  assign slt_temp = (in1[31] ^ in2[31]) ? in1[31] : sub_result[31];
  assign slt_o    = {31'b0, slt_temp};
  
endmodule: slt_sltu


