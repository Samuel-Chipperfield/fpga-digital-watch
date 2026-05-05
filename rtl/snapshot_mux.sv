`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  logic [WIDTH-1:0] e;
  always_ff @(posedge hold) e <= d;
  always_comb begin
    if (hold == 0) q = d;
    else q = e;
  end

endmodule
