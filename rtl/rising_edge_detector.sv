`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  logic test;
  always_ff @(posedge clk) test <= sig_in;
  always_comb rise = (!test && sig_in);
endmodule
