/*
 * Copyright (c) 2024 ReJ aka Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`define REGISTER_INPUTS_OUTPUTS

`define SERIAL_WEIGHTS

// `define SYNAPSES_1
// `define SYNAPSES_2
// `define SYNAPSES_4
// `define SYNAPSES_4_ALT
`define SYNAPSES_N
parameter N = 32;


module CarrySaveAdder3 (
    input a,
    input b,
    input c,
    output sum,
    output carry
);
  `ifdef SIM
    assign sum = a ^ b ^ c;  // XOR for sum
    assign carry = (a & b) | (b & c) | (c & a);  // Majority function for carry
  `else
    /* verilator lint_off PINMISSING */
    sky130_fd_sc_hd__fa_1 full_adder(.A(a), .B(b), .CIN(c), .COUT(carry), .SUM(sum));
    /* verilator lint_on PINMISSING */
  `endif
endmodule

module Add32 (
    input  [31:0] data,
    output [11:0] sum,
    output [ 9:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 30; i = i + 3)
      CarrySaveAdder3 add3 (
        .a(data[i  ]),
        .b(data[i+1]),
        .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[11:10] = data[31:30];
endmodule

module Add16 (
    input  [15:0] data,
    output [ 5:0] sum,
    output [ 4:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 15; i = i + 3)
      CarrySaveAdder3 add3 (
        .a(data[i  ]),
        .b(data[i+1]),
        .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[5] = data[15];
endmodule

module Add12 (
    input  [11:0] data,
    output [ 3:0] sum,
    output [ 3:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 12; i = i + 3)
      CarrySaveAdder3 add3 (
        .a(data[i  ]),
        .b(data[i+1]),
        .c(data[i+2]),
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
      CarrySaveAdder3 add3 (
        .a(data[i  ]),
        .b(data[i+1]),
        .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
  assign sum[3:2] = data[7:6];
endmodule

module Add6 (
    input  [ 5:0] data,
    output [ 1:0] sum,
    output [ 1:0] carry
);
  generate
    genvar i;
    for (i = 0; i < 6; i = i + 3)
      CarrySaveAdder3 add3 (
        .a(data[i  ]),
        .b(data[i+1]),
        .c(data[i+2]),
        .sum(sum[i/3]), .carry(carry[i/3]));
  endgenerate
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

module Add2 (
    input  [ 1:0] data,
    output        sum,
    output        carry
);
  CarrySaveAdder3 add3 (.a(data[0]), .b(data[1]), .c(1'b0),
                        .sum(sum), .carry(carry));
endmodule

module PopCount32 (
    input [31:0] data,
    output [5:0] count // 6 bits to hold up to 32
);
  wire [11:0] bit0_stage1;
  wire [ 3:0] bit0_stage2;
  wire [ 1:0] bit0_stage3;
  wire        bit0_final;

  wire [ 9:0] bit1_stage1;
  wire [ 3:0] bit1_stage2;
  wire        bit1_stage3;
  wire        bit1_stage4;

  Add32 add1(.data(data),        .sum(bit0_stage1), .carry(bit1_stage1));
  Add12 add2(.data(bit0_stage1), .sum(bit0_stage2), .carry(bit1_stage2));
  Add4  add3(.data(bit0_stage2), .sum(bit0_stage3), .carry(bit1_stage3));
  Add2  add4(.data(bit0_stage3), .sum(bit0_final),  .carry(bit1_stage4));

  wire [ 5:0] bit1_stage5;
  wire [ 1:0] bit1_stage6;
  wire        bit1_final;

  wire [ 4:0] bit2_stage5;
  wire [ 1:0] bit2_stage6;
  wire        bit2_stage7;

  Add16 add5(.data({bit1_stage1, bit1_stage2, bit1_stage3, bit1_stage4}), .sum(bit1_stage5), .carry(bit2_stage5));
  Add6  add6(.data(bit1_stage5),                                          .sum(bit1_stage6), .carry(bit2_stage6));
  Add2  add7(.data(bit1_stage6),                                          .sum(bit1_final),  .carry(bit2_stage7));

  wire [ 3:0] bit2_stage8;
  wire [ 1:0] bit2_stage9;
  wire        bit2_final;

  wire [ 1:0] bit3_stage8;
  wire        bit3_stage9;
  wire        bit3_stage10;

  Add8  add8(.data({bit2_stage5, bit2_stage6, bit2_stage7}),              .sum(bit2_stage8), .carry(bit3_stage8));
  Add4  add9(.data(bit2_stage8),                                          .sum(bit2_stage9), .carry(bit3_stage9));
  Add2 add10(.data(bit2_stage9),                                          .sum(bit2_final),  .carry(bit3_stage10)); 

  wire [ 1:0] bit3_stage11;
  wire        bit3_final;

  wire        bit4_stage11;
  wire        bit4_stage12;

  Add4 add11(.data({bit3_stage8, bit3_stage9, bit3_stage10}),             .sum(bit3_stage11), .carry(bit4_stage11)); 
  Add2 add12(.data(bit3_stage11),                                         .sum(bit3_final),   .carry(bit4_stage12)); 

  wire [1:0]  top_bits_final = bit4_stage12 + bit4_stage11;

  // Output the final count
  assign count = {top_bits_final, bit3_final, bit2_final, bit1_final, bit0_final};

endmodule

module synapse_mul (
    input x,
    input weight_zero,
    input weight_sign,
    output signed [1:0] y
);
    assign y = (~x || weight_zero) ?  2'b00 : 
                      weight_sign  ?  2'b11 :
                                      2'b01 ;
endmodule

module synapse_alt (
    input x,
    input weight_zero,
    input weight_sign,
    output positive,
    output negative
);
    assign negative =  weight_sign && ~weight_zero && x;
    assign positive = ~weight_sign && ~weight_zero && x;
endmodule

module tt_um_rejunity_ternary_dot (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [7:0] sum_hi;
  assign uio_oe  = 8'b1111_1100;
  assign UIO_OUT = {sum_hi[5:0], 2'b00};

`ifdef REGISTER_INPUTS_OUTPUTS
  reg [7:0] UI_IN;
  reg [7:0] UIO_IN; 
  wire [7:0] UO_OUT;
  wire [7:0] UIO_OUT;
  reg [7:0] reg_uo_out;
  reg [7:0] reg_uio_out;

  always @(posedge clk) UI_IN <= ui_in;
  always @(posedge clk) UIO_IN <= uio_in;
  always @(posedge clk) reg_uo_out <= UO_OUT;
  always @(posedge clk) reg_uio_out <= UIO_OUT;

  assign uo_out = reg_uo_out;
  assign uio_out = reg_uio_out;

`else

  wire [7:0] UI_IN = ui_in;
  wire [7:0] UIO_IN = uio_in;
  wire [7:0] UO_OUT;
  wire [7:0] UIO_OUT;

  assign uo_out = UO_OUT;
  assign uio_out = UIO_OUT;
`endif

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, uio_in[7:2], 1'b0};

`ifdef SYNAPSES_1

  always @(posedge clk) w <= uio_in[1:0];

  synapse_mul synapse(
    .x(UI_IN[0]),
    .weight_zero(w[0]),
    .weight_sign(w[1]),
    .y(UO_OUT[1:0]));
  assign UO_OUT[7:2] = {6{UO_OUT[1]}};
  assign sum_hi = {8{UO_OUT[1]}};

`elsif SYNAPSES_2

  reg [3:0] w;
  `ifdef SERIAL_WEIGHTS
    always @(posedge clk) w <= { w[1:0], uio_in[1:0] };
  `else
    always @(posedge clk) w <= uio_in[3:0];
  `endif


  wire signed [1:0] y0, y1;
  synapse_mul synapse0(
    .x(UI_IN[0]),
    .weight_zero(w[0]),
    .weight_sign(w[1]),
    .y(y0));

  synapse_mul synapse1(
    .x(UI_IN[1]),
    .weight_zero(w[2]),
    .weight_sign(w[3]),
    .y(y1));

  wire signed [2:0] y = y0 + y1;
  assign UO_OUT = { {5{y[2]}}, y };
  assign sum_hi =   {8{y[2]}};

`elsif SYNAPSES_4

  reg [7:0] w;
  `ifdef SERIAL_WEIGHTS
    always @(posedge clk) w <= { w[5:0], uio_in[1:0] };
  `else
    always @(posedge clk) w <= uio_in[7:0];
  `endif

  wire signed [1:0] y0, y1, y2, y3;
  synapse_mul synapse0(
    .x(UI_IN[0]),
    .weight_zero(w[0]),
    .weight_sign(w[1]),
    .y(y0));

  synapse_mul synapse1(
    .x(UI_IN[1]),
    .weight_zero(w[2]),
    .weight_sign(w[3]),
    .y(y1));

  synapse_mul synapse2(
    .x(UI_IN[2]),
    .weight_zero(w[4]),
    .weight_sign(w[5]),
    .y(y2));

  synapse_mul synapse3(
    .x(UI_IN[3]),
    .weight_zero(w[6]),
    .weight_sign(w[7]),
    .y(y3));

  wire signed [3:0] y = y0 + y1 + y2 + y3;
  assign UO_OUT = { {4{y[3]}}, y };
  assign sum_hi =   {8{y[3]}};

`elsif SYNAPSES_4_ALT

  reg [7:0] w;
  `ifdef SERIAL_WEIGHTS
    always @(posedge clk) w <= { w[5:0], uio_in[1:0] };
  `else
    always @(posedge clk) w <= uio_in[7:0];
  `endif

  wire [3:0] yp;
  wire [3:0] yn;
  generate
    genvar i;
    for (i = 0; i < 4; i = i+1) begin : syna
      synapse_alt alt(
        .x(UIO_IN[i]),
        .weight_zero(w[i*2+0]),
        .weight_sign(w[i*2+1]),
        .positive(yp[i]),
        .negative(yn[i]));
    end
  endgenerate

  wire [3:0] p = yp[0] + yp[1] + yp[2] + yp[3];
  wire [3:0] n = yn[0] + yn[1] + yn[2] + yn[3];
  wire signed [3:0] sum = $signed(p) - $signed(n);
  assign UO_OUT = { {4{sum[3]}}, sum };
  assign sum_hi =   {8{sum[3]}};

`elsif SYNAPSES_N
  wire [N-1:0] x = {(N/8){UI_IN}};
  wire signed [1:0] y[N-1:0];
  // wire yp[N-1:0];
  // wire yn[N-1:0];
  wire [N-1:0] yp;
  wire [N-1:0] yn;


  reg [N*2-1:0] w;
  wire [N*2-1:0] w_buf;
  always @(posedge clk) w <= { w_buf[N*2-2-1:0], uio_in[1:0] };
`ifdef SIM
  /* verilator lint_off ASSIGNDLY */
  buf i_w_buf[N*2-1:0] (w_buf, w[N*2-1:0]);
  /* verilator lint_on ASSIGNDLY */
// `elsif SCL_sky130_fd_sc_hd
//   sky130_fd_sc_hd__clkbuf_2 i_w_buf[N*2-1:0] ( .X(w_buf), .A(w[N*2-1:0]) );
// `elsif SCL_sky130_fd_sc_hs
//   sky130_fd_sc_hs__clkbuf_2 i_w_buf[N*2-1:0] ( .X(w_buf), .A(w[N*2-1:0]) );
// `else
//   assign w_buf = w[N*2-1:0];   // On SG13G2 no buffer is required, use direct assignment
`else
  /* verilator lint_off PINMISSING */
  // sky130_fd_sc_hd__clkbuf_2 i_w_buf[N*2-1:0] ( .X(w_buf), .A(w[N*2-1:0]) );
  sky130_fd_sc_hd__dlygate4sd3_1 i_w_buf[N*2-1:0] ( .X(w_buf), .A(w[N*2-1:0]) );
  /* verilator lint_on PINMISSING */
`endif


  generate
    genvar i;
    for (i = 0; i < N; i = i+1) begin : syna
      synapse_mul mul(
        .x(x[i]),
        .weight_zero(w_buf[i*2+0]),
        .weight_sign(w_buf[i*2+1]),
        .y(y[i]));

      synapse_alt alt(
        .x(x[i]),
        .weight_zero(w_buf[i*2+0]),
        .weight_sign(w_buf[i*2+1]),
        .positive(yp[i]),
        .negative(yn[i]));
    end

    if (N == 256) begin : adder_tree_128
      wire [1:0] p2 [(N/2)-1:0];
      wire [1:0] n2 [(N/2)-1:0];
      for (i = 0; i < N/2; i = i+1) begin : add0
        assign p2[i] = yp[i*2+0] + yp[i*2+1];
        assign n2[i] = yn[i*2+0] + yn[i*2+1];
      end

      wire [2:0] p3 [(N/4)-1:0];
      wire [2:0] n3 [(N/4)-1:0];
      for (i = 0; i < N/4; i = i+1) begin : add1
        assign p3[i] = p2[i*2+0] + p2[i*2+1];
        assign n3[i] = n2[i*2+0] + n2[i*2+1];
      end

      wire [3:0] p4 [(N/8)-1:0];
      wire [3:0] n4 [(N/8)-1:0];
      for (i = 0; i < N/8; i = i+1) begin : add2
        assign p4[i] = p3[i*2+0] + p3[i*2+1];
        assign n4[i] = n3[i*2+0] + n3[i*2+1];
      end

      wire [4:0] p5 [(N/16)-1:0];
      wire [4:0] n5 [(N/16)-1:0];
      for (i = 0; i < N/16; i = i+1) begin : add3
        assign p5[i] = p4[i*2+0] + p4[i*2+1];
        assign n5[i] = n4[i*2+0] + n4[i*2+1];
      end

      wire [5:0] p6 [(N/32)-1:0];
      wire [5:0] n6 [(N/32)-1:0];
      for (i = 0; i < N/32; i = i+1) begin : add4
        assign p6[i] = p5[i*2+0] + p5[i*2+1];
        assign n6[i] = n5[i*2+0] + n5[i*2+1];
      end

      wire [6:0] p7 [(N/64)-1:0];
      wire [6:0] n7 [(N/64)-1:0];
      for (i = 0; i < N/64; i = i+1) begin : add5
        assign p7[i] = p6[i*2+0] + p6[i*2+1];
        assign n7[i] = n6[i*2+0] + n6[i*2+1];
      end

      wire [7:0] p8 [(N/128)-1:0];
      wire [7:0] n8 [(N/128)-1:0];
      for (i = 0; i < N/128; i = i+1) begin : add6
        assign p8[i] = p7[i*2+0] + p7[i*2+1];
        assign n8[i] = n7[i*2+0] + n7[i*2+1];
      end

      wire [9:0] p = p8[0] + p8[1];
      wire [9:0] n = n8[0] + n8[1];

      wire signed [9:0] sum = $signed(p) - $signed(n);

      // output
      assign UO_OUT = sum[7:0];
      assign sum_hi = {{6{sum[9]}}, sum[9:8]};

    end else if (N == 128) begin : adder_tree_128

      wire [1:0] p2 [(N/2)-1:0];
      wire [1:0] n2 [(N/2)-1:0];
      for (i = 0; i < N/2; i = i+1) begin : add0
        assign p2[i] = yp[i*2+0] + yp[i*2+1];
        assign n2[i] = yn[i*2+0] + yn[i*2+1];
      end

      wire [2:0] p3 [(N/4)-1:0];
      wire [2:0] n3 [(N/4)-1:0];
      for (i = 0; i < N/4; i = i+1) begin : add1
        assign p3[i] = p2[i*2+0] + p2[i*2+1];
        assign n3[i] = n2[i*2+0] + n2[i*2+1];
      end

      wire [3:0] p4 [(N/8)-1:0];
      wire [3:0] n4 [(N/8)-1:0];
      for (i = 0; i < N/8; i = i+1) begin : add2
        assign p4[i] = p3[i*2+0] + p3[i*2+1];
        assign n4[i] = n3[i*2+0] + n3[i*2+1];
      end

      wire [4:0] p5 [(N/16)-1:0];
      wire [4:0] n5 [(N/16)-1:0];
      for (i = 0; i < N/16; i = i+1) begin : add3
        assign p5[i] = p4[i*2+0] + p4[i*2+1];
        assign n5[i] = n4[i*2+0] + n4[i*2+1];
      end

      wire [5:0] p6 [(N/32)-1:0];
      wire [5:0] n6 [(N/32)-1:0];
      for (i = 0; i < N/32; i = i+1) begin : add4
        assign p6[i] = p5[i*2+0] + p5[i*2+1];
        assign n6[i] = n5[i*2+0] + n5[i*2+1];
      end

      wire [6:0] p7 [(N/64)-1:0];
      wire [6:0] n7 [(N/64)-1:0];
      for (i = 0; i < N/64; i = i+1) begin : add5
        assign p7[i] = p6[i*2+0] + p6[i*2+1];
        assign n7[i] = n6[i*2+0] + n6[i*2+1];
      end

      wire [8:0] p = p7[0] + p7[1];
      wire [8:0] n = n7[0] + n7[1];

      wire signed [8:0] sum = $signed(p) - $signed(n);

      // output
      assign UO_OUT = sum[7:0];
      assign sum_hi = {8{sum[8]}};

    end else if (N == 64) begin : adder_tree_64
      wire [1:0] p2 [(N/2)-1:0];
      wire [1:0] n2 [(N/2)-1:0];
      for (i = 0; i < N/2; i = i+1) begin : add0
        assign p2[i] = yp[i*2+0] + yp[i*2+1];
        assign n2[i] = yn[i*2+0] + yn[i*2+1];
      end

      wire [2:0] p3 [(N/4)-1:0];
      wire [2:0] n3 [(N/4)-1:0];
      for (i = 0; i < N/4; i = i+1) begin : add1
        assign p3[i] = p2[i*2+0] + p2[i*2+1];
        assign n3[i] = n2[i*2+0] + n2[i*2+1];
      end

      wire [3:0] p4 [(N/8)-1:0];
      wire [3:0] n4 [(N/8)-1:0];
      for (i = 0; i < N/8; i = i+1) begin : add2
        assign p4[i] = p3[i*2+0] + p3[i*2+1];
        assign n4[i] = n3[i*2+0] + n3[i*2+1];
      end

      wire [4:0] p5 [(N/16)-1:0];
      wire [4:0] n5 [(N/16)-1:0];
      for (i = 0; i < N/16; i = i+1) begin : add3
        assign p5[i] = p4[i*2+0] + p4[i*2+1];
        assign n5[i] = n4[i*2+0] + n4[i*2+1];
      end

      wire [5:0] p6 [(N/32)-1:0];
      wire [5:0] n6 [(N/32)-1:0];
      for (i = 0; i < N/32; i = i+1) begin : add4
        assign p6[i] = p5[i*2+0] + p5[i*2+1];
        assign n6[i] = n5[i*2+0] + n5[i*2+1];
      end

      wire [7:0] p = p6[0] + p6[1];
      wire [7:0] n = n6[0] + n6[1];

      wire signed [7:0] sum = $signed(p) - $signed(n);

      // output
      assign UO_OUT = sum;
      assign sum_hi = {8{sum[7]}};
    end else if (N == 32) begin : adder_tree_32
      // A
      wire signed [6:0] sum
                         = y[ 0] + y[ 1] + y[ 2] + y[ 3] + y[ 4] + y[ 5] + y[ 6] + y[ 7] + y[ 8] + y[ 9]
                         + y[10] + y[11] + y[12] + y[13] + y[14] + y[15] + y[16] + y[17] + y[18] + y[19]
                         + y[20] + y[21] + y[22] + y[23] + y[24] + y[25] + y[26] + y[27] + y[28] + y[29]
                         + y[30] + y[31];

      // // B
      // wire signed [2:0] y2 [(N/2)-1:0];
      // for (i = 0; i < N/2; i = i+1) begin : add0
      //   assign y2[i] = y[i*2+0] + y[i*2+1];
      // end

      // wire signed [3:0] y3 [(N/4)-1:0];
      // for (i = 0; i < N/4; i = i+1) begin : add1
      //   assign y3[i] = y2[i*2+0] + y2[i*2+1];
      // end

      // wire signed [4:0] y4 [(N/8)-1:0];
      // for (i = 0; i < N/8; i = i+1) begin : add2
      //   assign y4[i] = y3[i*2+0] + y3[i*2+1];
      // end

      // wire signed [5:0] y5 [(N/16)-1:0];
      // for (i = 0; i < N/16; i = i+1) begin : add3
      //   assign y5[i] = y4[i*2+0] + y4[i*2+1];
      // end

      // wire signed [6:0] sum = y5[0] + y5[1];

      // // C FAULTY
      // reg signed [6:0] sum = 0;
      // // integer n;
      // for (i = 0; i < N; i = i+1) begin : adder
      //   // for (n = 0; n < N; n = n+1)
      //   always @(*)
      //     sum = sum + y[i];
      // end

      // D
      // wire [1:0] p2 [(N/2)-1:0];
      // wire [1:0] n2 [(N/2)-1:0];
      // for (i = 0; i < N/2; i = i+1) begin : add0
      //   assign p2[i] = yp[i*2+0] + yp[i*2+1];
      //   assign n2[i] = yn[i*2+0] + yn[i*2+1];
      // end

      // wire [2:0] p3 [(N/4)-1:0];
      // wire [2:0] n3 [(N/4)-1:0];
      // for (i = 0; i < N/4; i = i+1) begin : add1
      //   assign p3[i] = p2[i*2+0] + p2[i*2+1];
      //   assign n3[i] = n2[i*2+0] + n2[i*2+1];
      // end

      // wire [3:0] p4 [(N/8)-1:0];
      // wire [3:0] n4 [(N/8)-1:0];
      // for (i = 0; i < N/8; i = i+1) begin : add2
      //   assign p4[i] = p3[i*2+0] + p3[i*2+1];
      //   assign n4[i] = n3[i*2+0] + n3[i*2+1];
      // end

      // wire [4:0] p5 [(N/16)-1:0];
      // wire [4:0] n5 [(N/16)-1:0];
      // for (i = 0; i < N/16; i = i+1) begin : add3
      //   assign p5[i] = p4[i*2+0] + p4[i*2+1];
      //   assign n5[i] = n4[i*2+0] + n4[i*2+1];
      // end

      // wire [6:0] p = p5[0] + p5[1];
      // wire [6:0] n = n5[0] + n5[1];

      // wire signed [6:0] sum = $signed(p) - $signed(n);

      // E
      // wire [5:0] pcount;
      // wire [5:0] ncount;
      // PopCount32 p(.data(yp), .count(pcount));
      // PopCount32 n(.data(yn), .count(ncount));
      // wire signed [6:0] sum = $signed({1'b0, pcount}) - $signed({1'b0, ncount});

      // output
      assign UO_OUT = {  sum[6], sum };
      assign sum_hi = {8{sum[6]}};

    end else if (N == 16) begin : adder_tree_16
      wire signed [5:0] sum
                         = y[ 0] + y[ 1] + y[ 2] + y[ 3] + y[ 4] + y[ 5] + y[ 6] + y[ 7] + y[ 8] + y[ 9]
                         + y[10] + y[11] + y[12] + y[13] + y[14] + y[15];
      assign UO_OUT = { {2{sum[5]}}, sum };
      assign sum_hi =   {8{sum[5]}};
    end else if (N == 8) begin : adder_tree_8
      wire signed [4:0] sum
                         = y[ 0] + y[ 1] + y[ 2] + y[ 3] + y[ 4] + y[ 5] + y[ 6] + y[ 7];
      assign UO_OUT = { {3{sum[4]}}, sum };
      assign sum_hi =   {8{sum[4]}};
    end else if (N == 4) begin : adder_tree_4
      wire signed [3:0] sum
                         = y[ 0] + y[ 1] + y[ 2] + y[ 3];
      assign UO_OUT = { {4{sum[3]}}, sum };
      assign sum_hi =   {8{sum[3]}};
    end

  endgenerate
  

`else

  assign UO_OUT = 0;
`endif

endmodule
