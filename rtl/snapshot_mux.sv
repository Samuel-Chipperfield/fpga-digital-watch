`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  logic [WIDTH-1:0] e = '0;
  // stores the last value before holding from ff.
  always_ff @(posedge clk) if (!hold) e <= d;
  // when not holding the output should just be the input of the flip flop, when holding the output will be the last input before the hold
  always_comb q = hold ? e : d;


endmodule
