`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);
  initial armed = 0;
  always_ff @(posedge clk) begin
    if (disarm == 1) armed <= 0;
    else if (arm == 1) armed <= 1;
  end
endmodule
