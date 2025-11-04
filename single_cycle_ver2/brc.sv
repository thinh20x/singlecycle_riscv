////////////////////////////////////////////////////////////////
//
// CTMT_L01_07
//
// Filename                  : alu.sv
// Description               : 
//                             
// Author                    : nhat.leminh0254@gmail.com
//
// Created On                : 
// History (Date, Changed By):
//
//
////////////////////////////////////////////////////////////////
module brc (
    input logic [31:0] i_rs1_data,
    input logic [31:0] i_rs2_data,
    input logic i_br_un,

    output logic o_br_less,
    output logic o_br_equal
);
  logic [31:0] sub_result;
  logic        carry_o;
  logic        signed_less, unsigned_less;

  addsub_32b COMB1 (
      .A      (i_rs1_data),
      .B      (i_rs2_data),
      .add_sub(1'b1),
      .S      (sub_result),
      .carry_o(carry_o)
  );

  assign signed_less   = (i_rs1_data[31] ^ i_rs2_data[31]) ?  i_rs1_data[31] : sub_result[31];
  assign unsigned_less = (i_rs1_data[31] ^ i_rs2_data[31]) ? ~i_rs1_data[31] : ~carry_o;

  assign o_br_less  = (i_br_un) ? signed_less : unsigned_less;
  assign o_br_equal = ~|(sub_result);
endmodule 
