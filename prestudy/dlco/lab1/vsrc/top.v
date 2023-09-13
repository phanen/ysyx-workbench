module top (
    input  [1:0] y,
    input  [1:0] x0,
    input  [1:0] x1,
    input  [1:0] x2,
    input  [1:0] x3,
    output [1:0] f
);
  // NR_KEY KEY_LEN DATA_LEN
  MuxKey #(4, 2, 2) i0 (
      f,
      y,
      {2'b00, x0, 2'b01, x1, 2'b10, x2, 2'b11, x3}
  );
endmodule
