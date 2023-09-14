/* verilator lint_off PINMISSING */
module naive_shifter (
    output reg [7:0] out,
    input [2:0] ctrl,
    input [7:0] in,
    input clk,
    input b
);

  reg [31:0] count;

  always @(posedge clk) begin
    if (count == 0) begin
      case (ctrl)
        // verilog_format: off
      3'b000: begin out <= 0; end
      3'b001: begin out <= in; end
      3'b010: begin out <= {1'b0, out[7:1]}; end
      3'b011: begin out <= {out[7:1], 1'b0}; end
      3'b100: begin out <= {out[7], out[7:1]}; end
      3'b101: begin out <= {b, out[7:1]}; end
      3'b110: begin out <= {out[0], out[7:1]}; end
      3'b111: begin out <= {out[6:0], 1'b0}; end
      default: out <= 0;
      // verilog_format: on
      endcase
    end
    count <= (count >= 5000000 ? 32'b0 : count + 1);
  end
endmodule

module naive_shifter_slow (
    output reg [7:0] dout,
    input [2:0] ctrl,
    input [7:0] din,
    input clk,
    input b
);

  wire o_clk;

  slower slower (
      .o_clk(o_clk),
      .i_clk(clk)
  );

  always @(posedge o_clk) begin
    case (ctrl)
      // verilog_format: off
      3'b000: begin dout <= 0; end
      3'b001: begin dout <= din; end
      3'b010: begin dout <= {1'b0, dout[7:1]}; end
      3'b011: begin dout <= {dout[7:1], 1'b0}; end
      3'b100: begin dout <= {dout[7], dout[7:1]}; end
      3'b101: begin dout <= {b, dout[7:1]}; end
      3'b110: begin dout <= {dout[0], dout[7:1]}; end
      3'b111: begin dout <= {dout[6:0], 1'b0}; end
      default: dout <= 0;
      // verilog_format: on
    endcase
  end

endmodule
