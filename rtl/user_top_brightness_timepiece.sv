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

module user_top_brightness_timepiece #(
    parameter int CYCLES_PER_SECOND = 50000000
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

  localparam int CountWidth = $clog2(CYCLES_PER_SECOND / 1000);
  logic [1:0] brightness;
  localparam int Max = CYCLES_PER_SECOND / 1000;
  assign brightness = {sw[9], sw[8]};
  logic [2:0] app_blanking;
  logic [CountWidth-1:0] count;

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blanking[2]),
      .blank_minutes(app_blanking[1]),
      .blank_seconds(app_blanking[0])
  );

  mod_n_counter #(
      .N(CYCLES_PER_SECOND / 1000),
      .WIDTH(CountWidth)
  ) u_pwm (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(count)
  );
  logic pwm;
  always_comb begin
    case (brightness)
      2'b00: pwm = ((count < (Max / 8)));
      2'b01: pwm = (count < (Max / 4));
      2'b11: pwm = (count < (Max / 2));
      default pwm = 1'b1;
    endcase
  end

  assign blank_hours   = (app_blanking[2]) || !pwm;
  assign blank_minutes = (app_blanking[1]) || !pwm;
  assign blank_seconds = (app_blanking[0]) || !pwm;


endmodule

