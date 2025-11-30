module MCP4921(
	input clk,
	input dat1,
	input dat2,
	input cs_b,
	input ldac_b,
	input rst_b
);

reg [15:0] serial_buff_1;
reg [15:0] serial_buff_2;
reg [11:0] sample_latch_1;
reg [11:0] sample_latch_2;
wire shdn_b_1 = serial_buff_1[12];
wire shdn_b_2 = serial_buff_2[12];

reg sample_clock;

always #18.14 sample_clock <= (sample_clock === 1'b0);

integer sample_count;
integer fhandle;
initial begin
	sample_clock = 1'b0;
`ifndef IVERILOG
	fhandle = $fopen("samples.bin", "w");
	$fwrite(fhandle, "bbbb");
	$fflush();
	$fclose(fhandle);
`endif
	sample_count = 0;
end

always @(posedge clk or negedge rst_b) begin
	if(rst_b) begin
		if(!cs_b) begin
			serial_buff_1 <= {serial_buff_1[14:0], dat1};
			serial_buff_2 <= {serial_buff_2[14:0], dat2};
		end
	end else begin
		serial_buff_1 <= 16'h0000;
		serial_buff_2 <= 16'h0000;
	end
end

wire [12:0] sample_1 = (serial_buff_1 & {12{shdn_b_1}}) * (serial_buff_1[13] ? 1 : 2);
wire [12:0] sample_2 = (serial_buff_2 & {12{shdn_b_2}}) * (serial_buff_2[13] ? 1 : 2);

always @(posedge ldac_b or negedge rst_b) begin
	if(rst_b) begin
		if(!serial_buff_1[15]) sample_latch_1 <= sample_1 > 12'hFFF ? 12'hFFF : sample_1;
		if(!serial_buff_2[15]) sample_latch_2 <= sample_2 > 12'hFFF ? 12'hFFF : sample_2;
	end else begin
		sample_latch_1 <= 12'h000;
		sample_latch_2 <= 12'h000;
	end
end

always @(posedge sample_clock) begin
`ifndef IVERILOG
	fhandle = $fopen("samples.bin", "a+b");
	$fwrite(fhandle, "%u", sample_latch_1);
	$fwrite(fhandle, "%u", sample_latch_2);
	$fflush();
	$fclose(fhandle);
`endif
	sample_count <= sample_count + 1;
end

endmodule
