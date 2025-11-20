`default_nettype none

module hellorld(
	input wb_clk_i,
	input rst_n,
	output reg io_out, //Only one output required for this design
	input [11:0] custom_settings //Settable by the management controller over wishbone bus
);

reg [11:0] baud_delay;
reg [3:0] char_pointer;

reg [6:0] char_at;
always @(*) begin
	case(char_pointer)
		0: char_at = 7'h48;
		1: char_at = 7'h65;
		2: char_at = 7'h6C;
		3: char_at = 7'h6C;
		4: char_at = 7'h6F;
		5: char_at = 7'h72;
		6: char_at = 7'h6C;
		7: char_at = 7'h64;
		8: char_at = 7'h21;
		9: char_at = 13;
		10: char_at = 10;
		default: char_at = 7'h45;
	endcase
end

reg [9:0] uart_frame;
reg [3:0] frame_counter;

always @(posedge wb_clk_i) begin
	if(!rst_n) begin
		baud_delay <= 0;
		char_pointer <= 0;
		frame_counter <= 4'b1010;
		io_out <= 1'b1;
	end else begin
		baud_delay <= baud_delay + 1;
		if(baud_delay == custom_settings) begin
			baud_delay <= 0;
			if(frame_counter == 4'b1010) begin
				frame_counter <= 0;
				char_pointer <= char_pointer == 10 ? 0 : char_pointer + 1;
				uart_frame <= {1'b1, 1'b0, char_at, 1'b0};
			end else begin
				frame_counter <= frame_counter + 1;
				io_out <= uart_frame[0];
				uart_frame <= {1'b0, uart_frame[9:1]};
			end
		end
	end
end

endmodule
