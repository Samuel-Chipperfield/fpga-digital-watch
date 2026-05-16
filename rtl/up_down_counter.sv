`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH -1:0] count
);
  localparam logic [WIDTH -1:0] Max = WIDTH'(MAX);
  initial count = '0;
  logic [WIDTH-1:0] next_count;
  // ff 
  always_ff @(posedge clk) if (enable) count <= next_count;
// next state logic 
  always_comb begin
    if (up == 1) next_count = (count == Max) ? 0 : count + WIDTH'(1);
    else begin
      next_count = (count == 0) ? Max : count - WIDTH'(1);
    end
  end
endmodule
