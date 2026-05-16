`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  logic test;
  // at every rising edge the test has the value of sig_in. 
  always_ff @(posedge clk) test <= sig_in;
  // then if the sig_in changes between the clock cycles, this will result in the test and sig_in having opposite values. 
  // then the rise will be dependent on the signal being low at the pos clk edge, and high at any other point. 
  always_comb rise = (!test && sig_in);
endmodule
