module mux21a (
    a,
    b,
    s,
    y
);
  input a, b, s;
  output y;

  assign y = (~s & a) | (s & b);

endmodule

module my_and (
    a,
    b,
    c
);
  input a, b;
  output c;

  assign c = a & b;
endmodule

module my_or (
    a,
    b,
    c
);
  input a, b;
  output c;

  assign c = a | b;
endmodule

module my_not (
    a,
    b
);
  input a;
  output b;

  assign b = ~a;
endmodule

module mux21b (
    a,
    b,
    s,
    y
);
  input a, b, s;
  output y;

  wire l, r, s_n;
  my_not i1 (
      .a(s),
      .b(s_n)
  );
  my_and i2 (
      .a(s_n),
      .b(a),
      .c(l)
  );
  my_and i3 (
      .a(s),
      .b(b),
      .c(r)
  );
  my_or i4 (
      .a(l),
      .b(r),
      .c(y)
  );
endmodule


module mux21c (
    a,
    b,
    s,
    y
);
  input a, b, s;
  output reg y;

  always @(*)
    if (s == 0) y = a;
    else y = b;
endmodule


module mux41a (
    a,
    s,
    y
);
  input [3:0] a;
  input [1:0] s;
  output reg y;

  always @(s or a)
    case (s)
      0: y = a[0];
      1: y = a[1];
      2: y = a[2];
      3: y = a[3];
      default: y = 1'b0;
    endcase
endmodule

module mux21e (
    a,
    b,
    s,
    y
);
  input a, b, s;
  output y;
  MuxKey #(2, 1, 1) i0 (
      y,
      s,
      {1'b0, a, 1'b1, b}
  );
endmodule

module mux41b (
    a,
    s,
    y
);
  input [3:0] a;
  input [1:0] s;
  output y;
  MuxKeyWithDefault #(4, 2, 1) i0 (
      y,
      s,
      1'b0,
      {2'b00, a[0], 2'b01, a[1], 2'b10, a[2], 2'b11, a[3]}
  );
endmodule
