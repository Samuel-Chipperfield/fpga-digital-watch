`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;
  // should pulse when the button is first pressed, or when the repeat cycles is reached. 
  assign pulse = rise | (button & pulse_train);
  rising_edge_detector u_button (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );
  //Hold cycles should are subtracted by 2, this is because it should match the timing needed. 
  // it allows the restartable rate generator to run in time to create a pulse. 
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - 2)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_pulse (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );
endmodule
