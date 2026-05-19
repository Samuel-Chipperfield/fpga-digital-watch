`timescale 1ns / 1ps

module knight_rider #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic ride,
    output logic [9:0] led
);
  logic [Width-1:0] count;
  localparam int Width = $clog2(CYCLES_PER_SECOND);
  localparam logic [Width-1:0] Cps = Width'(CYCLES_PER_SECOND);

  logic riding;

  arming_latch u_arm (
      .clk(clk),
      .arm(ride),
      .disarm(max),
      .armed(riding)
  );

  up_down_counter #(
      .MAX  (CYCLES_PER_SECOND),
      .WIDTH(Width)
  ) u_count (
      .clk(clk),
      .enable(riding),
      .up(1'b1),
      .count(count)
  );
  always_comb
    if (riding == 0) led[9:0] = '0;
    else begin
      led[9:9] = (count <= (Cps / 20) || count > (Cps * 19 / 20));
      led[8:8] = ((Cps / 20) < (count) && count<= (Cps / 10)) || (Cps * 19 / 20) >= (count) && (count > (Cps * 9 / 10));
      led[7:7] = (Cps / 10 < count && count <= (Cps * 3 / 20)) || (Cps * 17 / 20) < (count) && count <= (Cps * 9 / 10);
      led[6:6] = (Cps * 3 / 20) < (count) && count <= (Cps / 5) || (Cps * 4 / 5) < (count) && count <= (Cps * 17 / 20);
      led[5:5] = (Cps / 5) < (count) && count <= (Cps / 4) || (Cps * 3 / 4) < (count) && count <= (Cps * 4 / 5);
      led[4:4] = (Cps / 4) < (count) && count <= (Cps * 3 / 10) || (Cps * 7 / 10) < (count) && count <= (Cps * 3 / 4);
      led[3:3] = (Cps * 3 / 10 )< count && count <= (Cps * 7 / 20) ||(Cps * 13 / 20) < count && count <= (Cps * 7 / 10);
      led[2:2] = (Cps * 7 / 20 )< count && count <= (Cps * 2 / 5 )|| (Cps * 3 / 5) <count && count <= (Cps * 13 / 20);
      led[1:1] = (Cps * 2 / 5 )< (count) && count <= (Cps * 9 / 20) ||( Cps * 3 / 5)>= (count) && count > (Cps * 11/20);
      led[0:0] = (Cps * 9 / 20) < (count) && count <= (Cps * 11 / 20);
    end
  logic max;
  assign max = (count == Cps);

endmodule
