`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);
  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );
  logic tick_event;
  logic dec_event;
  logic inc_event;
  assign tick_event = !edit_mode && tick && !clr;
  assign dec_event  = dec && edit_mode && !inc && !clr;
  assign inc_event  = inc && !dec && edit_mode && !clr;
  logic enable;
  logic up;
  assign enable = dec_event || tick_event || inc_event;
  assign up = (inc_event);
  assign borrow_out = (tick_event && (count == 0));

endmodule
