module test_counter(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input clk,
	input rst,
	output reg [11:0] counter
);

always @(posedge clk) begin
	counter <= rst ? 0 : counter + 1;
end

endmodule
