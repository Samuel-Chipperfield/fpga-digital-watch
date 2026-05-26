`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  initial counter_enable = 1'b0;
  initial counter_rst = 1'b0;
  initial lap_hold = 1'b0;
  // next state logic, if both are pressed nothing should happen, presses should be exclusive
  wire  both = rise_start_stop && rise_lap;
  wire  ss_only = rise_start_stop && !rise_lap;
  wire  lap_only = !rise_start_stop && rise_lap;
  //next state logic
  wire  next_enable = ss_only ? !counter_enable : counter_enable;
  wire  next_rst = lap_only && !counter_enable && !lap_hold && !counter_rst;

  logic next_lap_hold;

  always_comb begin
    if (both) next_lap_hold = lap_hold;
    else if (counter_enable && lap_only) next_lap_hold = !lap_hold;
    else if (!counter_enable && lap_only) next_lap_hold = 1'b0;
    else next_lap_hold = lap_hold;
  end
  // ff to give outputs the next values.
  always_ff @(posedge clk) begin
    if (!both) begin
      counter_enable <= next_enable;
      counter_rst    <= next_rst;
      lap_hold       <= next_lap_hold;
    end
  end

endmodule


