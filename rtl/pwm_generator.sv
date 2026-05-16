`timescale 1ns / 1ps
// Creates a signal that is high for DUTY_CYCLES out of PERIOD_CYCLES

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int CountWidth = (PERIOD_CYCLES > 1) ? $clog2(PERIOD_CYCLES) + 1 : 1;
  logic [CountWidth-1:0] count;
  //initialising a mod n counter to count for period cycles, should always be enabled, however reset based on input. 
  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(CountWidth)
  ) u (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );
  // THe output will only be high if the count is less than the DUTY CYCLES.
  assign pwm_out = 1'(count < CountWidth'(DUTY_CYCLES));
endmodule
