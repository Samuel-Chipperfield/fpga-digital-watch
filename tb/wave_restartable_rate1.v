`timescale 1ns / 1ps
module wave_restartable_rate1;
  reg  clk = 0;
  reg  run = 0;
  wire tick;
  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) u_test (
      .clk (clk),
      .run (run),
      .tick(tick)
  );
  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_restartable_rate1.vcd");
    $dumpvars(0, wave_restartable_rate1);

    #30;
    run = 1;
    #25;
    run = 0;
    #10;
    run = 1;
    #15;
    run = 0;
    #30;
    run = 1;
    #90;
    run = 0;
    #20 $finish;
  end
endmodule
