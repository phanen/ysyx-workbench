// module declaration for half adder
module half_adder (
    output o_s,
    output o_c,
    input  i_a,
    input  i_b
);

  assign o_s = i_a ^ i_b;
  assign o_c = i_a & i_b;
endmodule


// full adder built on half adder
module full_adder0 (
    output o_s,
    output o_c,
    input  i_a,
    input  i_b,
    input  i_c
);

  wire s;
  wire c1;
  wire c2;

  half_adder h1 (
      .o_s(s),
      .o_c(c1),
      .i_a(i_a),
      .i_b(i_b)
  );

  half_adder h2 (
      .o_s(o_s),
      .o_c(c2),
      .i_a(s),
      .i_b(i_cin)
  );

  assign o_c = c1 | c2;
endmodule

module full_adder (
    output o_s,
    output o_c,
    input  i_a,
    input  i_b,
    input  i_c
);

  assign o_s = i_a ^ i_b ^ i_c;
  assign o_c = (i_a & i_b) | (i_b & i_c) | (i_c & i_a);
endmodule

module full_adder_4bit0 (
    output [3:0] o_s,
    output o_c,
    input [3:0] i_a,
    input [3:0] i_b,
    input i_c
);

  wire [3:1] c;
  // verilog_format: off
  full_adder fa0 (o_s[0], c[1], i_a[0], i_b[0], i_c);
  full_adder fa[2:1] (o_s[2:1], c[3:2], i_a[2:1], i_b[2:1], c[2:1]);
  full_adder fa31 (o_s[3], o_c, i_a[3], i_b[3], c[3]);
  // verilog_format: on
endmodule

module full_adder_4bit (
    output [3:0] o_s,
    output o_c,
    input [3:0] i_a,
    input [3:0] i_b,
    input i_c
);

  wire c1, c2, s1;
  assign {c1, s1} = i_a + i_c;
  assign {c2, o_s} = s1 + i_b;
  assign out_c = c1 | c2;
  assign overflow = (i_a[3] == i_b[3]) && (o_s[3] != i_a[3]);

endmodule
