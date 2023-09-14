module lfsr (
    output reg [7:0] x,
    input clk
);

  always @(posedge clk) begin
    if (x == 0) begin
      x <= 1;
    end else begin
      x[0] <= x[1];
      x[1] <= x[2];
      x[2] <= x[3];
      x[3] <= x[4];
      x[4] <= x[5];
      x[5] <= x[6];
      x[6] <= x[7];
      x[7] <= x[4] ^ x[3] ^ x[2] ^ x[0];
    end
  end

endmodule
