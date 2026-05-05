`timescale 1ns/1ps

module stopwatch_control (
    input logic clk,
    input logic rise_start_stop,
    input logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);
logic [2:0] state = {counter_rst,counter_enable,lap_hold};
initial state = 3'd0;
logic rise_start;
always_ff@(posedge clk) rise_start<=rise_start_stop;
assign counter_enable = (rise_start == 1)?  !counter_enable:counter_enable;
assign lap_hold = (counter_enable && rise_lap)? !lap_hold:lap_hold;
always_comb begin
    case(state) begin
        3'b000:
    endcase
end
endmodule
