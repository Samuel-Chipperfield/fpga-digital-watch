`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH - 1:0] count
);
  initial count = WIDTH'(0);
  logic [WIDTH-1:0] Max = WIDTH'(N - 1);
  logic [WIDTH-1:0] next_count;
  always_ff @(posedge clk)
    if (rst) count <= WIDTH'(0);
    else if (enable) count <= next_count;

  always_comb next_count = (count == Max) ? WIDTH'(0) : count + WIDTH'(1);
endmodule
