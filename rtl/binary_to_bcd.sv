`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,
    output logic [3:0] tens,
    output logic [3:0] ones
);
// dividing number by ten will give tens. 
  assign tens = 4'(bin / 7'd10);
  // use of the modulo % operator gives the remainder after division. 
  assign ones = 4'(bin % 7'd10);
endmodule
