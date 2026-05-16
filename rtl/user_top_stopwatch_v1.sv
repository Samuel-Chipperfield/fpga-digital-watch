// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  assign led = 10'b0;

  assign blank_hours = button[2];
  assign blank_minutes = button[2];
  assign blank_seconds = button[3];

  logic rise_lap;
  logic rise_start_stop;
  logic counter_rst;
  logic counter_enable;
  logic lap_hold;
  logic [6:0] count_h;
  logic [5:0] count_m;
  logic [6:0] count_s;

  rising_edge_detector u_button_1 (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  rising_edge_detector u_button_0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_count (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(count_h),
      .seconds(count_m),
      .centiseconds(count_s)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snap_sec (
      .clk(clk),
      .hold(lap_hold),
      .d(count_s),
      .q(seconds_disp)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snap_min (
      .clk(clk),
      .hold(lap_hold),
      .d({1'b0, count_m}),
      .q(minutes_disp)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snap_hr (
      .clk(clk),
      .hold(lap_hold),
      .d(count_h),
      .q(hours_disp)
  );

endmodule
