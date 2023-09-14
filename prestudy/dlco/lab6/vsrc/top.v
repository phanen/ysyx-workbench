module top (
    output [7:0] o,
    input [7:0] i,
    input [2:0] shamt,
    input lr,
    input al
);

  barrel_shifter b (
      .o(o),
      .i(i),
      .shamt(shamt),
      .lr(lr),
      .al(al)
  );
endmodule

module slow_lfsr (
    output reg [7:0] x,
    input clk
);

  wire slow_clk;
  slower slower (
      .o_clk(slow_clk),
      .i_clk(clk)
  );
  lfsr lfsr (
      .x  (x),
      .clk(slow_clk)
  );

endmodule
