/* verilator lint_off PINMISSING */
module top(
  output reg [7:0] out,
  input [2:0] ctrl,
  input [7:0] in,
  input clk,
  input b
);

reg [31:0] count;

always@(posedge clk) begin
  if (count == 0) begin
    case(ctrl)
      3'b000: begin out <= 0; end
      3'b001: begin out <= in; end
      3'b010: begin out <= {1'b0, out[7:1]}; end
      3'b011: begin out <= {out[7:1], 1'b0}; end
      3'b100: begin out <= {out[7], out[7:1]}; end
      3'b101: begin out <= {b, out[7:1]}; end
      3'b110: begin out <= {out[0], out[7:1]}; end
      3'b111: begin out <= {out[6:0], 1'b0}; end
      default: out <= 0;
    endcase
  end
  count <= (count >= 5000000 ? 32'b0 : count + 1);
end
endmodule
