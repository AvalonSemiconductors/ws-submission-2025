`default_nettype none

module message(
	input [8:0] pointer,
	output [8:0] value
);

reg [8:0] rom;
assign value = rom;
always @(*) begin
	case(pointer)
		default: rom = 9'h1FF;
		0: rom = 78;
		1: rom = 400;
		2: rom = 116;
		3: rom = 32;
		4: rom = 115;
		5: rom = 400;
		6: rom = 32;
		7: rom = 410;
		8: rom = 414;
		9: rom = 396;
		10: rom = 390;
		11: rom = 478;
		12: rom = 32;
		13: rom = 59;
		14: rom = 80;
	endcase
end

endmodule
