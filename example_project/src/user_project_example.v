`default_nettype none

module user_project_example(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	input rst_n,
	
	output [53:0] io_out,
	input [53:0] io_in,
	output [53:0] io_oe,
	output [53:0] io_cs,
	output [53:0] io_sl,
	output [53:0] io_pu,
	output [53:0] io_pd,
	output [53:0] io_ie,
	
	output const_one,
	output [3:0] const_zero
);

assign io_cs = 54'h0;
assign io_sl = 54'h0;
assign io_pd = 54'h0;
assign io_pu = {2'b11, 52'h0};

wire OE  = !io_in[52];
wire WEb = io_in[53];

assign io_oe = {2'b00, {52{OE}}};
assign io_ie = ~io_oe;
assign const_one = 1'b1;
assign const_zero = 4'h0;

reg [51:0] count;
assign io_out = {2'b00, count};

always @(posedge clk_i) begin
	if(!rst_n) begin
		count <= 0;
	end else begin
		count <= count + 1;
		if(!WEb) count <= io_in[51:0];
	end
end

endmodule
