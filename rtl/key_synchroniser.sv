`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,
    output logic [3:0] key_sync
);

  logic [3:0] inv_key;
  logic [3:0] flip_key = 4'b0000;
  initial key_sync = 4'b0000;

  assign inv_key  = ~key_n;
// Passing the inverted key signal through 2 flip-flops, creating a synchroniser and improving stability. 
  always_ff @(posedge clk) flip_key <= inv_key;
  always_ff @(posedge clk) key_sync <= flip_key;

endmodule
