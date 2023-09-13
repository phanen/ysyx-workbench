module top (
    input [7:0] in,
    input en,
    output [3:0] led_out,
    output reg [6:0] seg_out
);

  encode83 enc (
      .in (in),
      .en (en),
      .out(led_out[2:0]),
      .ok (led_out[3])
  );

  bcd7seg seg (
      .b({1'b0, led_out[2:0]}),
      .h(seg_out)
  );

endmodule

module encode83 (
    input [7:0] in,
    input en,
    output reg [2:0] out,
    output reg ok
);
  integer i;

  always @(in or en) begin
    if (en) begin
      out = 0;
      ok  = 0;
      for (i = 0; i <= 7; i = i + 1)
      if (in[i] == 1) begin
        out = i[2:0];
        ok  = 1;
      end
    end else begin
      out = 0;
      ok  = 0;
    end
  end
endmodule

// 0 -> light
// 1 -> dark
module bcd7seg (
    input [3:0] b,
    output reg [6:0] h
);
  //    0
  // 5     1
  //    6
  // 4     2
  //    3
  always @(b)
    case (b)
      4'd0: h = 7'b0000001;  // 0 1 2 3 4 5
      4'd1: h = 7'b1001111;  // 1 2
      4'd2: h = 7'b0010010;  // 0 1 3 4 6
      4'd3: h = 7'b1000110;  // 0 1 2 3 6
      4'd4: h = 7'b1001100;  // 1 2 5 6
      4'd5: h = 7'b0100100;  // 0 2 3 5 6
      4'd6: h = 7'b0100000;  // 0 2 3 4 5 6
      4'd7: h = 7'b0001111;  // 0 1 2
      4'd8: h = 7'b0000000;  // 0 1 2 3 4 5 6
      4'd9: h = 7'b0001100;  // 0 1 2 5 6
      default: h = 7'b0000000;
    endcase
endmodule

// bcd7seg seg5(cpudbgdata[23:20],HEX5);
