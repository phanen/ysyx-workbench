module top (
    input clk,
    input clrn,
    input ps2_clk,
    input ps2_data,
    output [6:0] seg0,
    output [6:0] seg1,
    output [6:0] seg2,
    output [6:0] seg3,
    output [6:0] seg4,
    output [6:0] seg5
);
  wire [7:0] scan_code;
  wire wr;
  wire [15:0] cnt;
  wire [7:0] ascii;

  keyboard kbd (
      .clk(clk),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
      .scan_code(scan_code),
      .wr(wr),
      .cnt(cnt)
  );

  s2a scan2ascii(
      .scan_code(scan_code),
      .clk(clk),
      .ascii(ascii)
  );

  // verilog_format: off
  bcd7seg s0 (.b(cnt[3:0]), .h(seg0));
  bcd7seg s1 (.b(cnt[7:4]), .h(seg1));
  bcd7seg s2 (.b(ascii[3:0]), .h(seg2));
  bcd7seg s3 (.b(ascii[7:4]), .h(seg3));
  bcd7seg s4 (.b(scan_code[3:0]), .h(seg4));
  bcd7seg s5 (.b(scan_code[7:4]), .h(seg5));
  // verilog_format: on
endmodule

// lut, scancode to ascii
module s2a (
    input  [7:0] scan_code,
    input clk,
    output reg [7:0] ascii
);
  always @(posedge clk) begin
    case (scan_code[7:0])
      8'h45:   ascii <= 8'h30;  //0
      8'h16:   ascii <= 8'h31;  //1
      8'h1E:   ascii <= 8'h32;  //2
      8'h26:   ascii <= 8'h33;  //3
      8'h25:   ascii <= 8'h34;  //4
      8'h2E:   ascii <= 8'h35;  //5
      8'h36:   ascii <= 8'h36;  //6
      8'h3D:   ascii <= 8'h37;  //7
      8'h3E:   ascii <= 8'h38;  //8
      8'h46:   ascii <= 8'h39;  //9
      8'h52:   ascii <= 8'h27;  //'
      8'h41:   ascii <= 8'h2C;  //,
      8'h4E:   ascii <= 8'h2D;  //-
      8'h49:   ascii <= 8'h2E;  //.
      8'h4A:   ascii <= 8'h2F;  ///
      8'h4C:   ascii <= 8'h3B;  //;
      8'h55:   ascii <= 8'h3D;  //=
      8'h54:   ascii <= 8'h5B;  //[
      8'h5D:   ascii <= 8'h5C;  //\
      8'h5B:   ascii <= 8'h5D;  //]
      8'h0E:   ascii <= 8'h60;  //`
      8'h1C:   ascii <= 8'h61;  //a
      8'h32:   ascii <= 8'h62;  //b
      8'h21:   ascii <= 8'h63;  //c
      8'h23:   ascii <= 8'h64;  //d
      8'h24:   ascii <= 8'h65;  //e
      8'h2B:   ascii <= 8'h66;  //f
      8'h34:   ascii <= 8'h67;  //g
      8'h33:   ascii <= 8'h68;  //h
      8'h43:   ascii <= 8'h69;  //i
      8'h3B:   ascii <= 8'h6A;  //j
      8'h42:   ascii <= 8'h6B;  //k
      8'h4B:   ascii <= 8'h6C;  //l
      8'h3A:   ascii <= 8'h6D;  //m
      8'h31:   ascii <= 8'h6E;  //n
      8'h44:   ascii <= 8'h6F;  //o
      8'h4D:   ascii <= 8'h70;  //p
      8'h15:   ascii <= 8'h71;  //q
      8'h2D:   ascii <= 8'h72;  //r
      8'h1B:   ascii <= 8'h73;  //s
      8'h2C:   ascii <= 8'h74;  //t
      8'h3C:   ascii <= 8'h75;  //u
      8'h2A:   ascii <= 8'h76;  //v
      8'h1D:   ascii <= 8'h77;  //w
      8'h22:   ascii <= 8'h78;  //x
      8'h35:   ascii <= 8'h79;  //y
      8'h1A:   ascii <= 8'h7A;  //z
      default: ascii <= 8'h00;
    endcase
  end
endmodule

module keyboard (
    input clk,
    input ps2_clk,
    input ps2_data,
    output reg [7:0] scan_code,
    output reg wr,
    output reg [15:0] cnt
);
  reg nextdata_n;
  wire ready, overflow;
  wire [7:0] keycode;
  initial begin
    cnt = 16'b0;
  end

  ps2_keyboard ps2kbd (
      .clk(clk),
      .clrn(1'b1),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
      .data(keycode),
      .ready(ready),
      .nextdata_n(nextdata_n),
      .overflow(overflow)  // fifo overflow
  );

  always @(negedge clk) begin
    if (ready == 1'b1) begin
      nextdata_n <= 1'b0;
      scan_code <= keycode;
      wr <= 1'b1;
      cnt <= cnt + 16'b1;
    end else begin
      nextdata_n <= 1'b1;
      wr <= 1'b0;
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
      4'h0: h = 7'b0000001;  // 0 1 2 3 4 5
      4'h1: h = 7'b1001111;  // 1 2
      4'h2: h = 7'b0010010;  // 0 1 3 4 6
      4'h3: h = 7'b0000110;  // 0 1 2 3 6
      4'h4: h = 7'b1001100;  // 1 2 5 6
      4'h5: h = 7'b0100100;  // 0 2 3 5 6
      4'h6: h = 7'b0100000;  // 0 2 3 4 5 6
      4'h7: h = 7'b0001111;  // 0 1 2
      4'h8: h = 7'b0000000;  // 0 1 2 3 4 5 6
      4'h9: h = 7'b0001100;  // 0 1 2 5 6
      4'ha: h = 7'b0001000;
      4'hb: h = 7'b1100000;
      4'hc: h = 7'b0110001;
      4'hd: h = 7'b1000010;
      4'he: h = 7'b0010000;  // 0 1 2 5 6
      4'hf: h = 7'b0111000;  // 0 1 2 5 6
      default: h = 7'b0000000;
    endcase
endmodule
