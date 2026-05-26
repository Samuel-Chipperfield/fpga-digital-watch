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

module user_top_watch_v4 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /*verilator lint_off UNUSED*/
    input logic [3:0] button,
    input logic [9:0] sw,
    /*verilator lint_on UNUSED*/
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  // ----------
  // Core functionallity
  // -------
  //seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_counter #(
      .N(12),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (!seconds_edit),
      .tick(seconds_tick)
  );
  assign minutes_tick = ((seconds_disp == 7'd59) && (seconds_tick));
  assign hours_tick = ((minutes_disp == 7'd59) && (minutes_tick) && (seconds_tick));
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};
  assign led = 10'b0;
  assign blank_hours = (mode_enable[2] & !pwm_out);
  assign blank_minutes = (mode_enable[1] & !pwm_out);
  assign blank_seconds = (mode_enable[0] & !pwm_out);

  // ----------
  // Mode Selection
  // ----------
  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );
  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND * 0.8 / 2)
  ) u_pwm_generator (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );
  // ----------
  // Edit logic
  // ---------
  logic hold_dec;
  logic hold_inc;
  logic pulse_inc;
  logic pulse_dec;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_hold_inc (
      .clk(clk),
      .button(button[1]),
      .pulse(hold_inc)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_hold_dec (
      .clk(clk),
      .button(button[0]),
      .pulse(hold_dec)
  );
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND * 0.8 / 2)
  ) u_pwm_held_inc (
      .clk(clk),
      .rst(!button[1]),
      .pwm_out(pulse_inc)
  );
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND * 0.8 / 2)
  ) u_pwm_held_dec (
      .clk(clk),
      .rst(!button[0]),
      .pwm_out(pulse_dec)
  );
  // editing logic, for increments and decrements.
  assign seconds_dec = (seconds_edit && (hold_dec && pulse_dec) && button[0]);
  assign seconds_inc = (seconds_edit && (hold_inc && pulse_inc) && button[1]);
  assign minutes_dec = (minutes_edit && (hold_dec && pulse_dec) && button[0]);
  assign minutes_inc = (minutes_edit && (hold_inc && pulse_inc) && button[1]);
  assign hours_dec = (hours_edit && (hold_dec && pulse_dec) && button[0]);
  assign hours_inc = (hours_edit && (hold_inc && pulse_inc) && button[1]);

  assign seconds_edit = (mode_enable[0]);
  assign minutes_edit = (mode_enable[1]);
  assign hours_edit = (mode_enable[2]);


endmodule
