module encode42a (
    x,
    en,
    y
);
  input [3:0] x;
  input en;
  output reg [1:0] y;

  always @(x or en) begin
    if (en) begin
      case (x)
        4'b0001: y = 2'b00;
        4'b0010: y = 2'b01;
        4'b0100: y = 2'b10;
        4'b1000: y = 2'b11;
        default: y = 2'b00;
      endcase
    end else y = 2'b00;
  end
endmodule

// priority
module encode42b (
    x,
    en,
    y
);
  input [3:0] x;
  input en;
  output reg [1:0] y;
  integer i;
  always @(x or en) begin
    if (en) begin
      y = 0;
      for (i = 0; i <= 3; i = i + 1) if (x[i] == 1) y = i[1:0];
    end else y = 0;
  end
endmodule
