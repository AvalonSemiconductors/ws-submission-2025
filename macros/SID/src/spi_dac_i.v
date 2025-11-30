`default_nettype none

module spi_dac_i(
	input [11:0] sample_in_1,
	input [11:0] sample_in_2,
	
	input clk,
	input rst,
	
	output reg spi_leb = 1'b1,
	output reg spi_clk = 0,
	output reg spi_dat_1 = 0,
	output reg spi_dat_2 = 0,
	output reg spi_csb = 1'b1,
	input sample_ready,
	
	input buffered
);

reg [15:0] spi_dat_buff_1 = 0;
reg [15:0] spi_dat_buff_2 = 0;
reg [5:0] counter = 0;
reg [1:0] clkdiv = 0;

always @(posedge clk) begin
	if(rst) begin
		spi_leb <= 1;
		spi_csb <= 1;
		spi_clk <= 0;
		spi_dat_1 <= 0;
		spi_dat_2 <= 0;
		counter <= 0;
		spi_dat_buff_1 <= 16'h7000;
		spi_dat_buff_2 <= 16'h7000;
	end else begin
		clkdiv <= clkdiv + 1;
		if(clkdiv == 0) begin
			spi_leb <= 1;
			if(counter != 35) counter <= counter + 1;
			if(counter == 33) begin
				//Load next sample & reset counter
				spi_clk <= 0;
				//Pulse LEb
				spi_leb <= 0;
			end else if(counter == 34) begin
			end else if(counter == 35) begin
				spi_leb <= 1;
				spi_csb <= 1;
				if(sample_ready) counter <= 0;
				spi_dat_buff_1 <= {buffered ? 4'b0111 : 4'b0011, sample_in_1};
				spi_dat_buff_2 <= {buffered ? 4'b0111 : 4'b0011, sample_in_2};
			end else begin
				if(counter[0]) begin
					//Clock in current bit
					spi_clk <= 1;
				end else begin
					//Shift out next bit
					spi_dat_1 <= spi_dat_buff_1[15];
					spi_dat_2 <= spi_dat_buff_2[15];
					spi_dat_buff_1 <= {spi_dat_buff_1[14:0], 1'bx};
					spi_dat_buff_2 <= {spi_dat_buff_2[14:0], 1'bx};
					spi_clk <= 0;
					spi_csb <= 0;
				end
			end
		end
	end
end

endmodule
