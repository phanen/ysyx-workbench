module top (
  output reg [7:0] x,
  input clk
);

  wire slow_clk;
  slower slower(
    .o_clk(slow_clk),
    .i_clk(clk)
  );
  lfsr lfsr(
    .x(x),
    .clk(slow_clk)
  );

endmodule
