/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// `define SYNAPSES_1
// `define SYNAPSES_2
// `define SYNAPSES_4
`define SYNAPSES_N
`define SERIAL_WEIGHTS

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

module tt_um_rejunity_fractal_nn (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, ui_in, uio_in, 1'b0};

`ifdef SYNAPSES_1

  `ifdef SERIAL_WEIGHTS
    always @(posedge clk) w <= { w[0], ui_in[0] };
  `else
    always @(posedge clk) w <= ui_in[1:0];
  `endif

  synapse_mul synapse(
    .x(uio_in[0]),
    .weight_zero(w[0]),
    .weight_sign(w[1]),
    .y(uo_out[1:0]));
  assign uo_out[7:2] = 0;

`elsif SYNAPSES_2

  reg [3:0] w;
  `ifdef SERIAL_WEIGHTS
    always @(posedge clk) w <= { w[2:0], ui_in[0] };
  `else
    always @(posedge clk) w <= ui_in[3:0];
  `endif


  wire signed [1:0] y0, y1;
  synapse_mul synapse0(
    .x(uio_in[0]),
    .weight_zero(w[0]),
    .weight_sign(w[1]),
    .y(y0));

  synapse_mul synapse1(
    .x(uio_in[1]),
    .weight_zero(w[2]),
    .weight_sign(w[3]),
    .y(y1));

  wire signed [2:0] y = y0 + y1;
  assign uo_out[2:0] = y;
  assign uo_out[7:3] = 0;
  // assign uo_out = {4'b0, y1, y0};

`elsif SYNAPSES_4

  reg [7:0] w;
  `ifdef SERIAL_WEIGHTS
    always @(posedge clk) w <= { w[6:0], ui_in[0] };
  `else
    always @(posedge clk) w <= ui_in[7:0];
  `endif

  wire signed [1:0] y0, y1, y2, y3;
  synapse_mul synapse0(
    .x(uio_in[0]),
    .weight_zero(w[0]),
    .weight_sign(w[1]),
    .y(y0));

  synapse_mul synapse1(
    .x(uio_in[1]),
    .weight_zero(w[2]),
    .weight_sign(w[3]),
    .y(y1));

  synapse_mul synapse2(
    .x(uio_in[2]),
    .weight_zero(w[4]),
    .weight_sign(w[5]),
    .y(y2));

  synapse_mul synapse3(
    .x(uio_in[3]),
    .weight_zero(w[6]),
    .weight_sign(w[7]),
    .y(y3));

  wire signed [3:0] y = y0 + y1 + y2 + y3;
  assign uo_out[3:0] = y;
  assign uo_out[7:4] = 0;

`elsif SYNAPSES_N
  localparam N = 32;
  wire [N-1:0] x = { uio_in, uio_in, uio_in, uio_in };
  wire signed [1:0] y[N-1:0];


  reg [N*2-1:0] w;
  wire [N*2-1:0] w_buf;
  // always @(posedge clk) w <= { w[N*2-2:0], ui_in[0] };
  always @(posedge clk) w <= { w_buf[N*2-2:0], ui_in[0] };
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
  // sky130_fd_sc_hd__clkbuf_2 i_w_buf[N*2-1:0] ( .X(w_buf), .A(w[N*2-1:0]) );
  sky130_fd_sc_hd__dlygate4sd3_1 i_w_buf[N*2-1:0] ( .X(w_buf), .A(w[N*2-1:0]) );
`endif

  generate
    genvar i;
    for (i = 0; i < N; i = i+1) begin : syna
      synapse_mul mul(
        .x(x[i]),
        .weight_zero(w_buf[i*2+0]),
        .weight_sign(w_buf[i*2+1]),
        .y(y[i]));
    end

    if (N == 32) begin
      // wire signed [6:0] sum
      //                    = y[ 0] + y[ 1] + y[ 2] + y[ 3] + y[ 4] + y[ 5] + y[ 6] + y[ 7] + y[ 8] + y[ 9]
      //                    + y[10] + y[11] + y[12] + y[13] + y[14] + y[15] + y[16] + y[17] + y[18] + y[19]
      //                    + y[20] + y[21] + y[22] + y[23] + y[24] + y[25] + y[26] + y[27] + y[28] + y[29]
      //                    + y[30] + y[31];

      wire signed [2:0] y2[(N/2)-1:0];
      for (i = 0; i < N/2; i = i+1) begin : add0
        assign y2[i] = y[i*2+0] + y[i*2+1];
      end

      wire signed [3:0] y3[(N/4)-1:0];
      for (i = 0; i < N/4; i = i+1) begin : add1
        assign y3[i] = y2[i*2+0] + y2[i*2+1];
      end

      wire signed [4:0] y4[(N/8)-1:0];
      for (i = 0; i < N/8; i = i+1) begin : add2
        assign y4[i] = y3[i*2+0] + y3[i*2+1];
      end

      wire signed [5:0] y5[(N/16)-1:0];
      for (i = 0; i < N/16; i = i+1) begin : add3
        assign y5[i] = y4[i*2+0] + y4[i*2+1];
      end

      wire signed [6:0] sum = y5[0] + y5[1];
      assign uo_out = { 1'b0, sum };
    end else if (N == 16) begin
      wire signed [5:0] sum
                         = y[ 0] + y[ 1] + y[ 2] + y[ 3] + y[ 4] + y[ 5] + y[ 6] + y[ 7] + y[ 8] + y[ 9]
                         + y[10] + y[11] + y[12] + y[13] + y[14] + y[15];
      assign uo_out = { 2'b0, sum };
    end else if (N == 8) begin
      wire signed [4:0] sum
                         = y[ 0] + y[ 1] + y[ 2] + y[ 3] + y[ 4] + y[ 5] + y[ 6] + y[ 7];
      assign uo_out = { 3'b0, sum };
    end else if (N == 4) begin
      wire signed [3:0] sum
                         = y[ 0] + y[ 1] + y[ 2] + y[ 3];
      assign uo_out = { 4'b0, sum };
    end

  endgenerate
  

`else

    

  assign uo_out = 0;
`endif

endmodule
