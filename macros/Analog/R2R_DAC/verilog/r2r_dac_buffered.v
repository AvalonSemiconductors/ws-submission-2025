(* blackbox *)
module r2r_dac_buffered(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input D0,
	input D1,
	input D2,
	input D3,
	input D4,
	input D5,
	input D6,
	input D7,
	input D8,
	input D9,
	input D10,
	input D11,
	
	output OUT
);

assign OUT = 1'b0;

`ifdef SIM
real voltage;
assign voltage = (1.0 - {D11, D10, D9, D8, D7, D6, D5, D4, D3, D2, D1, D0} / 4095.0) * 5.0;
`endif

endmodule
