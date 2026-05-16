`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  localparam logic [1:0] Hz_1 = 2'b00;
  localparam logic [1:0] Hz_25 = 2'b01;
  localparam logic [1:0] Hz_0 = 2'b10;
  localparam logic [1:0] Hz_500 = 2'b11;

  logic [1:0] state;
  logic adj_clk;
  logic tick_1hz, tick_25hz, tick_1khz;
  logic [4:0] bin_hours;
  logic [5:0] bin_minutes;
  logic [5:0] bin_seconds;

  logic [3:0] tens_hour;
  logic [3:0] ones_hours;
  logic [3:0] tens_minutes;
  logic [3:0] ones_minutes;
  logic [3:0] tens_seconds;
  logic [3:0] ones_seconds;

  always_comb state[1:0] = SW[1:0];

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) hz1 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1hz)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) hz25 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25hz)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) khz1 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1khz)
  );
  //gives the rate of the clk based on the sw. 
  always_comb begin
    unique case (state)
      Hz_1:   adj_clk = tick_1hz;
      Hz_25:  adj_clk = tick_25hz;
      Hz_0:   adj_clk = tick_1khz;
      Hz_500: adj_clk = 1'b1;
    endcase
  end
  hms_counter one (
      .clk(CLOCK_50),
      .enable(adj_clk),
      .hours(bin_hours),
      .minutes(bin_minutes),
      .seconds(bin_seconds)
  );

  binary_to_bcd uhour (
      .bin ({2'b0, bin_hours}),
      .tens(tens_hour),
      .ones(ones_hours)
  );
  binary_to_bcd uminute (
      .bin ({1'b0, bin_minutes}),
      .tens(tens_minutes),
      .ones(ones_minutes)
  );
  binary_to_bcd usecond (
      .bin ({1'b0, bin_seconds}),
      .tens(tens_seconds),
      .ones(ones_seconds)
  );
  seven_segment #(
      .ACTIVE_LOW(32'd1)
  ) tens_hours (
      .digit(tens_hour),
      .blank(1'b0),
      .segments(HEX5)
  );
  seven_segment #(
      .ACTIVE_LOW(32'd1)
  ) ones_hour (
      .digit(ones_hours),
      .blank(1'b0),
      .segments(HEX4)
  );
  seven_segment #(
      .ACTIVE_LOW(32'd1)
  ) tens_minute (
      .digit(tens_minutes),
      .blank(1'b0),
      .segments(HEX3)
  );
  seven_segment #(
      .ACTIVE_LOW(32'd1)
  ) ones_minute (
      .digit(ones_minutes),
      .blank(1'b0),
      .segments(HEX2)
  );
  seven_segment #(
      .ACTIVE_LOW(32'd1)
  ) tens_second (
      .digit(tens_seconds),
      .blank(1'b0),
      .segments(HEX1)
  );
  seven_segment #(
      .ACTIVE_LOW(32'd1)
  ) ones_second (
      .digit(ones_seconds),
      .blank(1'b0),
      .segments(HEX0)
  );
endmodule
