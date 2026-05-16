`timescale 1ns / 1ps

module user_top_timer_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input logic clk,
    /* verilator lint_off UNUSED*/
    input logic [3:0] button,
    /* verilator lint_on UNUSED */
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);
  ///
  // Countdown logic
  ///
  // button[0] starts the timer if the count is not zero

  //holding button[3] for 1 enters set mode

  // When in set mode button[0] decments and button[1] increments, holding either ticks at 10Hz,
  // pressing button[3] again moves to minutes, then hours, then takes out of set mode, and returns to stop mode
  // when running the counter decrements, pressing button[0] pauses the timer, when the counter reaches 0 it stops and is held at zero.
  logic running = 1'b0;
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [6:0] seconds;
  logic burrow_out_seconds;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(7)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick && !zero && running),
      .edit_mode(seconds_edit),
      .clr(seconds_edit && button_3_rise_r),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(burrow_out_seconds)
  );

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [6:0] minutes;
  logic burrow_out_minutes;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(7)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .clr(minutes_edit && button_3_rise_r),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(burrow_out_minutes)
  );
  logic button_3_rise;
  rising_edge_detector u_button_3 (
      .clk(clk),
      .sig_in(button[3]),
      .rise(button_3_rise)
  );

  logic button_3_rise_r;
  always_ff @(posedge clk) button_3_rise_r <= button_3_rise;
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [6:0] hours;
  logic burrow_out_hours;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(7)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .clr(hours_edit && button_3_rise_r),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(burrow_out_hours)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (!edit && running),
      .tick(seconds_tick)
  );
  // count should be paused when button[0] is pressed and not in set mode;
  logic button_0_rise;
  logic button_0_rise_r;
  always_ff @(posedge clk) button_0_rise_r <= button_0_rise;
  rising_edge_detector u_pause (
      .clk(clk),
      .sig_in(button[0]),
      .rise(button_0_rise)
  );
  always_ff @(posedge clk) begin
    if (!(mode_enable == 3'b000)) running <= 1'b0;
    else if (zero) running <= 1'b0;
    else if (button_0_rise_r) running <= !running;
  end

  // Count must stop at 00:00:00. so check at count, then if count = 0, then no ticks
  logic hours_0;
  logic minutes_0;
  logic seconds_0;
  wire  zero;
  assign hours_0 = (hours == 7'd0);
  assign minutes_0 = (minutes == 7'd0);
  assign seconds_0 = (seconds == 7'd0);
  assign zero = hours_0 && minutes_0 && seconds_0;

  assign minutes_tick = burrow_out_seconds && running;
  assign hours_tick = burrow_out_minutes && burrow_out_seconds && running;


  assign hours_disp = hours;
  assign minutes_disp = minutes;
  assign seconds_disp = seconds;
  assign led[9:0] = '0;
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
  // Edit logic//setting timer
  // ---------
  logic hold_dec;
  logic hold_inc;
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
  logic edit;
  assign seconds_dec = (seconds_edit && ((hold_dec)));
  assign seconds_inc = (seconds_edit && ((hold_inc)));
  assign minutes_dec = (minutes_edit && (hold_dec));
  assign minutes_inc = (minutes_edit && (hold_inc));
  assign hours_dec = (hours_edit && hold_dec);
  assign hours_inc = (hours_edit && hold_inc);

  assign seconds_edit = (mode_enable == 3'b001);
  assign minutes_edit = (mode_enable == 3'b010);
  assign hours_edit = (mode_enable == 3'b100);
  assign edit = seconds_edit || minutes_edit || hours_edit;

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule
