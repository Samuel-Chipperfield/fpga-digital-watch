`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);
// initialisation 
  initial armed = 0;
// if disarm armed should be 0 - top priority, then if arm, should be armed. 
  always_ff @(posedge clk) begin
    if (disarm == 1) armed <= 0;
    else if (arm == 1) armed <= 1;
  end
endmodule
