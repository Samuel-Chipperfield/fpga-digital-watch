`timescale 1ns / 1ps

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);
  localparam logic [25:0] Dutycycles = 26'(DUTY_CYCLES);
  logic [25:0] count;
  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(26)
  ) u (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );
  always_comb begin
    if (count == Dutycycles) pwm_out = 1'b0;
    else if (count == 0) pwm_out = 1'b1;
  end
endmodule
