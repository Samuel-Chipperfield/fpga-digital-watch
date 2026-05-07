`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH -1:0] Max = WIDTH'(MAX);
  initial count = '0;
  logic [WIDTH-1:0] next_count;
  always_ff @(posedge clk) count <= next_count;

  always_comb begin
    if (rst == 1) next_count = WIDTH'(0);
    else begin
      if (enable == 1) begin
        if (up == 1) next_count = (count == Max) ? 0 : count + WIDTH'(1);
        else next_count = (count == 0) ? Max : count - WIDTH'(1);
      end else next_count = count;
    end
  end
endmodule
