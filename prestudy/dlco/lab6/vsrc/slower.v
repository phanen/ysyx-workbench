module slower(
  output reg o_clk,
  input i_clk
);

reg [31:0] count;
always@(i_clk) begin
  if (count == 0) begin
    case(o_clk)
      1'b0: o_clk = 1'b1;
      1'b1: o_clk = 1'b0;
    endcase
  end
  count <= (count >= 5000000)? 32'b0: count + 1;
end
endmodule

