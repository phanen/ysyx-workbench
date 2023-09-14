/* verilator lint_off PINMISSING */

module barrel_shifter(
  output reg [7:0] dout,
  input [7:0] din,
  input [2:0] shamt,
  input l_or_r,
  input a_or_l,
  input clk
);

always@(posedge clk) begin
  // TODO:
end

endmodule
