`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,
    output logic [3:0] key_sync
);
  logic [3:0] inv_key;
  logic [3:0] flip_key = 4'b0000;
  logic [3:0] key_sync_r = 4'b0000;

  assign key_sync = key_sync_r;
  assign inv_key  = ~key_n;

  always_ff @(posedge clk) flip_key <= inv_key;
  always_ff @(posedge clk) key_sync_r <= flip_key;

endmodule
