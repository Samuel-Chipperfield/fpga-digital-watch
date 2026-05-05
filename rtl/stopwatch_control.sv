`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  logic [2:0] state;
  initial counter_enable = 1'b0;
  initial counter_rst = 1'b0;
  initial lap_hold = 1'b0;
  logic [2:0] next_state;
  assign state = {counter_rst, counter_enable, lap_hold};
  logic ss_only = rise_start_stop && !rise_lap;
  logic lap_only = !rise_start_stop && rise_lap;
  assign next_state[1] = (ss_only == 1) ? !state[1] : state[1];
  assign next_state[2] = (lap_only && !state[1] && !state[0]) ? 1'b1 : 1'b0;

  always_comb begin
    if (lap_only) begin
      case (state)
        3'b010: next_state[0] = 1;
        3'b011: next_state[0] = 0;
        default next_state[0] = 0;
      endcase
    end else next_state[0] = state[0];
  end
  always_ff @(posedge clk) begin
    counter_rst <= next_state[2];
    counter_enable <= next_state[1];
    lap_hold <= next_state[0];
  end

endmodule


