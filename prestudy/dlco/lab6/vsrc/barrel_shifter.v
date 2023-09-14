/* verilator lint_off PINMISSING */

module barrel_shifter(
  output [7:0] o,
  input [7:0] i,
  input [2:0] shamt,
  input lr,
  input al
);

// binary: 8 = 4*b2 + 2*b1 + 1*b0
wire pref;
wire [7:0] x, y;

mux21 m2(.y(pref), .sel(al), .x0(0), .x1(i[7]));

// 1bit
mux41 m410(.y(x[0]), .sel({lr,shamt[0]}), .x0(i[0]), .x1(i[1]), .x2(i[0]), .x3(0));
mux41 m411(.y(x[1]), .sel({lr,shamt[0]}), .x0(i[1]), .x1(i[2]), .x2(i[1]), .x3(i[0]));
mux41 m412(.y(x[2]), .sel({lr,shamt[0]}), .x0(i[2]), .x1(i[3]), .x2(i[2]), .x3(i[1]));
mux41 m413(.y(x[3]), .sel({lr,shamt[0]}), .x0(i[3]), .x1(i[4]), .x2(i[3]), .x3(i[2]));
mux41 m414(.y(x[4]), .sel({lr,shamt[0]}), .x0(i[4]), .x1(i[5]), .x2(i[4]), .x3(i[3]));
mux41 m415(.y(x[5]), .sel({lr,shamt[0]}), .x0(i[5]), .x1(i[6]), .x2(i[5]), .x3(i[4]));
mux41 m416(.y(x[6]), .sel({lr,shamt[0]}), .x0(i[6]), .x1(i[7]), .x2(i[6]), .x3(i[5]));
mux41 m417(.y(x[7]), .sel({lr,shamt[0]}), .x0(i[7]), .x1(pref), .x2(i[7]), .x3(i[6]));

// 2bit
mux41 m420(.y(y[0]), .sel({lr,shamt[1]}), .x0(x[0]), .x1(x[2]), .x2(x[0]), .x3(0));
mux41 m421(.y(y[1]), .sel({lr,shamt[1]}), .x0(x[1]), .x1(x[3]), .x2(x[1]), .x3(0));
mux41 m422(.y(y[2]), .sel({lr,shamt[1]}), .x0(x[2]), .x1(x[4]), .x2(x[2]), .x3(x[0]));
mux41 m423(.y(y[3]), .sel({lr,shamt[1]}), .x0(x[3]), .x1(x[5]), .x2(x[3]), .x3(x[1]));
mux41 m424(.y(y[4]), .sel({lr,shamt[1]}), .x0(x[4]), .x1(x[6]), .x2(x[4]), .x3(x[2]));
mux41 m425(.y(y[5]), .sel({lr,shamt[1]}), .x0(x[5]), .x1(x[7]), .x2(x[5]), .x3(x[3]));
mux41 m426(.y(y[6]), .sel({lr,shamt[1]}), .x0(x[6]), .x1(pref), .x2(x[6]), .x3(x[4]));
mux41 m427(.y(y[7]), .sel({lr,shamt[1]}), .x0(x[7]), .x1(pref), .x2(x[7]), .x3(x[5]));

// 4bit
mux41 m430(.y(o[0]), .sel({lr,shamt[2]}), .x0(y[0]), .x1(y[4]), .x2(y[0]), .x3(0));
mux41 m431(.y(o[1]), .sel({lr,shamt[2]}), .x0(y[1]), .x1(y[5]), .x2(y[1]), .x3(0));
mux41 m432(.y(o[2]), .sel({lr,shamt[2]}), .x0(y[2]), .x1(y[6]), .x2(y[2]), .x3(0));
mux41 m433(.y(o[3]), .sel({lr,shamt[2]}), .x0(y[3]), .x1(y[7]), .x2(y[3]), .x3(0));
mux41 m434(.y(o[4]), .sel({lr,shamt[2]}), .x0(y[4]), .x1(pref), .x2(y[4]), .x3(y[0]));
mux41 m435(.y(o[5]), .sel({lr,shamt[2]}), .x0(y[5]), .x1(pref), .x2(y[5]), .x3(y[1]));
mux41 m436(.y(o[6]), .sel({lr,shamt[2]}), .x0(y[6]), .x1(pref), .x2(y[6]), .x3(y[2]));
mux41 m437(.y(o[7]), .sel({lr,shamt[2]}), .x0(y[7]), .x1(pref), .x2(y[7]), .x3(y[3]));

endmodule

module mux41 (
  output reg y,
  input [1:0] sel,
  input x0,
  input x1,
  input x2,
  input x3
);

always@(*) begin
  case (sel)
     2'b00: y = x0;
     2'b01: y = x1;
     2'b10: y = x2;
     2'b11: y = x3;
  endcase
end

endmodule

module mux21 (
  output reg y,
  input sel,
  input x0,
  input x1
);

always@(*) begin
  case (sel)
     1'b0: y = x0;
     1'b1: y = x1;
  endcase
end

endmodule

