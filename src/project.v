/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// `define SYNAPSES_1
// `define SYNAPSES_2
`define SYNAPSES_4
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

`else
  assign uo_out = 0;
`endif

endmodule
