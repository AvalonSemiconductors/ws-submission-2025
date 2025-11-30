`default_nettype none

module sid_adc(
	input rst_n,
	input clk,
	input pot_in,
	output pot_oe,
	output reg [7:0] measurement
);

reg [8:0] timer;
reg [2:0] clockdiv;
reg last_pot_in;
assign pot_oe = timer == 0;

always @(posedge clk) begin
	if(!rst_n) begin
		clockdiv <= 0;
		timer <= 1;
		last_pot_in <= 0;
	end else begin
		clockdiv <= clockdiv + 1;
		if(clockdiv == 0) begin
			timer <= timer + 1;
			last_pot_in <= pot_in;
			if(pot_in && !last_pot_in) measurement <= timer[8:1];
		end
	end
end

endmodule
