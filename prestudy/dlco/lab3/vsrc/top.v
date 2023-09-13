/* verilator lint_off PINMISSING */

// calc all, mux one
module top(
  output reg [3:0] out,
  output reg o_cf,
  output reg o_of,
  output o_zf,
  input [3:0] i_a,
  input [3:0] i_b,
  input [2:0] i_op
);

wire [3:0] add_out;
wire add_cf, add_of;
wire [3:0] sub_out;
wire sub_cf, sub_of;

// adder
adder_4bit adder1(
  .o_s(add_out),
  .o_cf(add_cf),
  .o_of(add_of),
  .i_a(i_a),
  .i_b(i_b),
  .i_c(0)
);

suber_4bit suber1(
  .o_s(sub_out),
  .o_cf(sub_cf),
  .o_of(sub_of),
  .i_a(i_a),
  .i_b(i_b)
);


wire [3:0] le_out;
wire le_cf, le_of;
le_4bit le1(
  .o_s(le_out),
  .o_of(le_of),
  .i_a(i_a),
  .i_b(i_b)
);

// selector
always@(*) begin
  case(i_op)
    3'b000: begin out = add_out; o_cf = add_cf; o_of = add_of; end
    3'b001: begin out = sub_out; o_cf = sub_cf; o_of = sub_of; end
    3'b010: begin out = ~i_a; o_cf = 0; o_of = 0; end
    3'b011: begin out = i_a & i_b; o_cf = 0; o_of = 0; end
    3'b100: begin out = i_a | i_b; o_cf = 0; o_of = 0; end
    3'b101: begin out = i_a ^ i_b; o_cf = 0; o_of = 0; end
    3'b110: begin out = le_out; o_cf = 0; o_of = le_of; end
    3'b111: begin out = {3'b0, ~(|(i_a ^ i_b))}; o_cf = 0; o_of = 0; end
    default: out = 0;
  endcase
end

assign o_zf = ~(|out);
endmodule

// TODO: refactor, no add sym
module adder_4bit(
  output [3:0] o_s,
  output o_cf,
  output o_of,
  input [3:0] i_a, 
  input [3:0] i_b,
  input i_c
);

wire c1, c2;
wire [3:0] s1;
assign {c1, s1} = i_a + {3'b0, i_c};
assign {c2, o_s} = s1 + i_b;
assign o_cf = c1 | c2;
assign o_of = (i_a[3] == i_b[3]) && (o_s[3] != i_a[3]);
endmodule

module suber_4bit(
  output [3:0] o_s,
  output o_cf,
  output o_of,
  input [3:0] i_a, 
  input [3:0] i_b
);

adder_4bit adder(
   .o_s(o_s),
   .o_cf(o_cf),
   .o_of(o_of),
   .i_a(i_a),
   .i_b(~i_b),
   .i_c(1'b1)
);
endmodule

module le_4bit (
  output [3:0] o_s,
  output o_of,
  input [3:0] i_a, 
  input [3:0] i_b
);
  

wire [3:0]sub_out; 
wire sub_of;

// same sign
// a < b -> a - b < 0 (never overflow)
suber_4bit suber(
  .o_s(sub_out),
  .o_of(sub_of),
  .i_a(i_a),
  .i_b(i_b)
);

// not same sign and overflow
assign o_s = {3'b0, sub_out[3] ^ sub_of};

endmodule

