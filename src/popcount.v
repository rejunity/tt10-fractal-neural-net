/*
 * Copyright (c) 2024 ReJ aka Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`ifdef SIM
`else
`define USE_HA_FA_CELLS
`endif

module CarrySaveAdder3 (
    input a,
    input b,
    input c,
    output sum,
    output carry
);
  `ifdef USE_HA_FA_CELLS
    /* verilator lint_off PINMISSING */
    sky130_fd_sc_hd__fa_1 full_adder(.A(a), .B(b), .CIN(c), .COUT(carry), .SUM(sum));
    /* verilator lint_on PINMISSING */
  `else
    assign sum = a ^ b ^ c;  // XOR for sum
    assign carry = (a & b) | (b & c) | (c & a);  // Majority function for carry
  `endif
endmodule

module Add2 (
    input  [ 1:0] data,
    output        sum,
    output        carry
);
  `ifdef USE_HA_FA_CELLS
    /* verilator lint_off PINMISSING */
    sky130_fd_sc_hd__ha_1 half_adder(.A(data[0]), .B(data[1]), .COUT(carry), .SUM(sum));
    /* verilator lint_on PINMISSING */
  `else
    CarrySaveAdder3 add3 (.a(data[0]), .b(data[1]), .c(1'b0),
                          .sum(sum), .carry(carry));
  `endif
endmodule

module Add4 (
    input  [ 3:0] data,
    output [ 1:0] sum,
    output        carry
);
  CarrySaveAdder3 add3 (.a(data[0]), .b(data[1]), .c(data[2]),
                        .sum(sum[0]), .carry(carry));
  assign sum[1] = data[3];
endmodule

module Add6 (
    input  [ 5:0] data,
    output [ 1:0] sum,
    output [ 1:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
endmodule

module Add8 (
    input  [ 7:0] data,
    output [ 3:0] sum,
    output [ 1:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[3:2] = data[7:6];
endmodule

module Add12 (
    input  [11:0] data,
    output [ 3:0] sum,
    output [ 3:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 12; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
endmodule

// module Add14 (
//     input  [13:0] data,
//     output [ 5:0] sum,
//     output [ 3:0] carry
// );
//   generate
//     genvar i;
//     for (i = 0; i < 12; i = i + 3)
//       CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
//         .sum(sum[i/3]), .carry(carry[i/3]));
//   endgenerate
//   assign sum[5:4] = data[13:12];
// endmodule

module Add16 (
    input  [15:0] data,
    output [ 5:0] sum,
    output [ 4:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 15; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[5] = data[15];
endmodule

module Add22 (
    input  [21:0] data,
    output [ 7:0] sum,
    output [ 6:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 21; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[7] = data[21];
endmodule

module Add32 (
    input  [31:0] data,
    output [11:0] sum,
    output [ 9:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 30; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[11:10] = data[31:30];
endmodule

module Add44 (
    input  [43:0] data,
    output [15:0] sum,
    output [13:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 42; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[15:14] = data[43:42];
endmodule

module Add64 (
    input  [63:0] data,
    output [21:0] sum,
    output [20:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 63; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[21] = data[63];
endmodule

module Add128 (
    input  [127:0] data,
    output  [43:0] sum,
    output  [41:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 126; i = i + 3)
      CarrySaveAdder3 add3 (.a(data[i  ]), .b(data[i+1]), .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[43:42] = data[127:126];
endmodule


module PopCount128 (
  input [127:0] data,
  output  [7:0] count // 8 bits to hold from 0 to 128 (inclusive)
);
  wire [127:0] bit0_in = data;
  wire [43:0] bit0_stage1;
  wire [15:0] bit0_stage2;
  wire [ 5:0] bit0_stage3;
  wire [ 1:0] bit0_stage4;
  wire        bit0_final;
  wire [41:0] bit1_stage1;
  wire [13:0] bit1_stage2;
  wire [ 4:0] bit1_stage3;
  wire [ 1:0] bit1_stage4;
  wire        bit1_stage5;
  Add128 ad0(.data(bit0_in),     .sum(bit0_stage1), .carry(bit1_stage1)); // 42
  Add44 add1(.data(bit0_stage1), .sum(bit0_stage2), .carry(bit1_stage2)); // 14
  Add16 add3(.data(bit0_stage2), .sum(bit0_stage3), .carry(bit1_stage3)); // 5
  Add6  add4(.data(bit0_stage3), .sum(bit0_stage4), .carry(bit1_stage4)); // 2
  Add2  add5(.data(bit0_stage4), .sum(bit0_final),  .carry(bit1_stage5)); // 0.625

  wire [63:0] bit1_in = {bit1_stage1, bit1_stage2, bit1_stage3, bit1_stage4, bit1_stage5};
  wire [21:0] bit1_stage6;
  wire [ 7:0] bit1_stage7;
  wire [ 3:0] bit1_stage8;
  wire [ 1:0] bit1_stage9;
  wire        bit1_final;
  wire [20:0] bit2_stage1;
  wire [ 6:0] bit2_stage2;
  wire [ 1:0] bit2_stage3;
  wire        bit2_stage4;
  wire        bit2_stage5;
  Add64 add6(.data(bit1_in),     .sum(bit1_stage6), .carry(bit2_stage1)); // 21
  Add22 add7(.data(bit1_stage6), .sum(bit1_stage7), .carry(bit2_stage2)); // 7
  Add8  add8(.data(bit1_stage7), .sum(bit1_stage8), .carry(bit2_stage3)); // 2
  Add4  add9(.data(bit1_stage8), .sum(bit1_stage9), .carry(bit2_stage4)); // 1
  Add2  ad10(.data(bit1_stage9), .sum(bit1_final),  .carry(bit2_stage5)); // 0.625

  wire [31:0] bit2_in = {bit2_stage1, bit2_stage2, bit2_stage3, bit2_stage4, bit2_stage5};
  wire [11:0] bit2_stage6;
  wire [ 3:0] bit2_stage7;
  wire [ 1:0] bit2_stage8;
  wire        bit2_final;
  wire [ 9:0] bit3_stage1;
  wire [ 3:0] bit3_stage2;
  wire        bit3_stage3;
  wire        bit3_stage4;
  Add32 ad11(.data(bit2_in),     .sum(bit2_stage6), .carry(bit3_stage1)); // 10
  Add12 ad12(.data(bit2_stage6), .sum(bit2_stage7), .carry(bit3_stage2)); // 4
  Add4  ad13(.data(bit2_stage7), .sum(bit2_stage8), .carry(bit3_stage3)); // 1
  Add2  ad14(.data(bit2_stage8), .sum(bit2_final),  .carry(bit3_stage4)); // 0.625

  wire [15:0] bit3_in = {bit3_stage1, bit3_stage2, bit3_stage3, bit3_stage4};
  wire [ 5:0] bit3_stage5;
  wire [ 1:0] bit3_stage6;
  wire        bit3_final;
  wire [ 4:0] bit4_stage5;
  wire [ 1:0] bit4_stage6;
  wire        bit4_stage7;
  Add16 ad15(.data(bit3_in),     .sum(bit3_stage5), .carry(bit4_stage5));  // 5
  Add6  ad16(.data(bit3_stage5), .sum(bit3_stage6), .carry(bit4_stage6));  // 2
  Add2  ad17(.data(bit3_stage6), .sum(bit3_final),  .carry(bit4_stage7));  // 0.625

  wire [ 7:0] bit4_in ={bit4_stage5, bit4_stage6, bit4_stage7};
  wire [ 3:0] bit4_stage8;
  wire [ 1:0] bit4_stage9;
  wire        bit4_final;
  wire [ 1:0] bit5_stage1;
  wire        bit5_stage2;
  wire        bit5_stage3;
  Add8  ad18(.data(bit4_in),     .sum(bit4_stage8), .carry(bit5_stage1)); // 2
  Add4  ad19(.data(bit4_stage8), .sum(bit4_stage9), .carry(bit5_stage2)); // 1
  Add2 add20(.data(bit4_stage9), .sum(bit4_final),  .carry(bit5_stage3)); // 0.625

  wire [ 3:0] bit5_in = {bit5_stage1, bit5_stage2, bit5_stage3};
  wire [ 1:0] bit5_stage4;
  wire        bit5_final;
  wire        bit6_stage11;
  wire        bit6_stage12;
  Add4 add21(.data(bit5_in),     .sum(bit5_stage4), .carry(bit7_stage1));  // 1
  Add2 add22(.data(bit5_stage4), .sum(bit5_final),  .carry(bit7_stage2));  // 0.625

  wire [1:0]  bit6_in = {bit6_stage1, bit6_stage2};
  wire        bit6_final;
  wire        bit7_final;
  Add2 add23(.data(bit6_in),      .sum(bit6_final),   .carry(bit7_final)); // 0.625

  // Output the final count
  assign count = {bit7_final, bit6_final, bit5_final, bit4_final,
                  bit3_final, bit2_final, bit1_final, bit0_final};

endmodule

module PopCount32 (
    input [31:0] data,
    output [5:0] count // 6 bits to hold from 0 to 32 (inclusive)
);
  wire [11:0] bit0_stage1;
  wire [ 3:0] bit0_stage2;
  wire [ 1:0] bit0_stage3;
  wire        bit0_final;

  wire [ 9:0] bit1_stage1;
  wire [ 3:0] bit1_stage2;
  wire        bit1_stage3;
  wire        bit1_stage4;

  Add32 add1(.data(data),        .sum(bit0_stage1), .carry(bit1_stage1)); // 10
  Add12 add2(.data(bit0_stage1), .sum(bit0_stage2), .carry(bit1_stage2)); // 4
  Add4  add3(.data(bit0_stage2), .sum(bit0_stage3), .carry(bit1_stage3)); // 1
  Add2  add4(.data(bit0_stage3), .sum(bit0_final),  .carry(bit1_stage4)); // 0

  wire [ 5:0] bit1_stage5;
  wire [ 1:0] bit1_stage6;
  wire        bit1_final;

  wire [ 4:0] bit2_stage5;
  wire [ 1:0] bit2_stage6;
  wire        bit2_stage7;

  Add16 add5(.data({bit1_stage1, bit1_stage2, bit1_stage3, bit1_stage4}), .sum(bit1_stage5), .carry(bit2_stage5));  // 5
  Add6  add6(.data(bit1_stage5),                                          .sum(bit1_stage6), .carry(bit2_stage6));  // 2
  Add2  add7(.data(bit1_stage6),                                          .sum(bit1_final),  .carry(bit2_stage7));  // 0

  wire [ 3:0] bit2_stage8;
  wire [ 1:0] bit2_stage9;
  wire        bit2_final;

  wire [ 1:0] bit3_stage8;
  wire        bit3_stage9;
  wire        bit3_stage10;

  Add8  add8(.data({bit2_stage5, bit2_stage6, bit2_stage7}),              .sum(bit2_stage8), .carry(bit3_stage8));  // 2
  Add4  add9(.data(bit2_stage8),                                          .sum(bit2_stage9), .carry(bit3_stage9));  // 1
  Add2 add10(.data(bit2_stage9),                                          .sum(bit2_final),  .carry(bit3_stage10)); // 0

  wire [ 1:0] bit3_stage11;
  wire        bit3_final;

  wire        bit4_stage11;
  wire        bit4_stage12;

  Add4 add11(.data({bit3_stage8, bit3_stage9, bit3_stage10}),             .sum(bit3_stage11), .carry(bit4_stage11));  // 1
  Add2 add12(.data(bit3_stage11),                                         .sum(bit3_final),   .carry(bit4_stage12)); 

  wire        bit4_final, bit5_final;

  Add2 addFF(.data({bit4_stage12, bit4_stage11}),                         .sum(bit4_final),   .carry(bit5_final));

  // Output the final count
  assign count = {bit5_final, bit4_final, bit3_final, bit2_final, bit1_final, bit0_final};

endmodule
