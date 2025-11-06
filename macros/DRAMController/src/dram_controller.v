`default_nettype none

module dram_controller(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	input rst_override_n,
	
	input [41:0] io_in,
	output [41:0] io_out,
	output io_oe
);

//TODO: additional A/DA lines on unused pads

wire rst_n = io_in[2];
wire reset = !rst_n || !rst_override_n;

wire [15:0] address = io_in[22:7];
wire CSn = io_in[23];
wire RWn = io_in[24];
wire CONFn = io_in[25];
wire [7:0] DA;
assign io_out[26] = DA[0];
assign io_out[27] = DA[1];
assign io_out[34:29] = DA[7:2];
wire RASn;
assign io_out[35] = RASn;
wire CASn;
assign io_out[36] = CASn;
wire DWn;
assign io_out[37] = DWn;
wire RDY;
assign io_out[38] = RDY;
wire BEn;
assign io_out[39] = BEn;
wire RLEn;
assign io_out[40] = RLEn;
wire WLEn;
assign io_out[41] = WLEn;

//Unused: 28, 0 (DIP-40 36), 1 (DIP-40 37), 3, 4, 5, 6
assign io_out[28] = 1'b0;
assign io_out[0] = 1'b0;
assign io_out[1] = 1'b0;
assign io_out[6:3] = 4'hA;

//Inputs
assign io_out[22:7] = 0;
assign io_out[23:25] = 0;

always @(posedge clk_i) begin
	if(reset) begin
	
	end else begin
	
	end
end

endmodule
