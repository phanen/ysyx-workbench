module top (
    input [7:0] in,
    input en,
    output [3:0] led_out,
    output reg [6:0] seg_out
);

  wire [2:0] enc_out;
  wire enc_ok;
  wire [3:0] seg_in;

  encode83_casez enc (
      .in (in),
      .en (en),
      .out(enc_out),
      // when out = 0:
      //  ok     -> output 0
      //  not ok -> no input
      .ok (enc_ok)
  );

  assign led_out[2:0] = enc_out;
  assign led_out[3] = enc_ok;
  assign seg_in = enc_ok ? {1'b0, enc_out} : 8;

  // seg should only show when `en=1`
  bcd7seg seg (
      .b(seg_in),
      .h(seg_out)
  );
endmodule


module encode83_casez (
    input [7:0] in,
    input en,
    output reg [2:0] out,
    output reg ok
);

  always @(in or en) begin
    if (en) begin
      casez (in)
        8'b00000001: out = 0;
        8'b0000001?: out = 1;
        8'b000001??: out = 2;
        8'b00001???: out = 3;
        8'b0001????: out = 4;
        8'b001?????: out = 5;
        8'b01??????: out = 6;
        8'b1???????: out = 7;
        default: out = 0;
      endcase
    end else begin
      out = 0;
    end
  end

  assign ok = en && (in != 0);
endmodule

module encode83 (
    input [7:0] in,
    input en,
    output reg [2:0] out,
    output ok
);
  integer i;

  always @(in or en) begin
    if (en) begin
      out = 0;
      for (i = 0; i <= 7; i = i + 1) begin
        if (in[i] == 1) begin
          out = i[2:0];
        end
      end
    end else begin
      out = 0;
    end
  end

  assign ok = en && (in != 0);
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
      4'd3: h = 7'b0000110;  // 0 1 2 3 6
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
