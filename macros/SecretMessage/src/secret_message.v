`default_nettype none

module secret_message(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input clk_i,
	input rst_override_n,
	input io_in_buffered,
	output [8:0] io_out
);

reg [7:0] pointer;

always @(posedge clk_i) begin
	if(!rst_override_n || !io_in_buffered) begin
		pointer <= 0;
	end else begin
		pointer <= pointer + 1;
	end
end

message message(
	.pointer(pointer),
	.value(io_out)
);

endmodule
