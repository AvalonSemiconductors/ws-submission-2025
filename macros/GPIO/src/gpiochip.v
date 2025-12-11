`default_nettype none

module gpiochip(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	input rst_override_n,
	
	input [41:0] io_in,
	output [41:0] io_out,
	output [16:0] io_oe,
	output [15:0] io_pu,
	output [15:0] io_pd,
	
	output reg [11:0] adc_out_1,
	output reg [11:0] adc_out_2,
	output reg [11:0] adc_out_3
);

wire reset = !io_in[2] || !rst_override_n;
assign io_out[2] = 1'b1;

wire [5:0] address = io_in[12:7];
assign io_out[12:7] = 0;

wire CEb = io_in[21];
wire OEb = io_in[22];
wire WEb = io_in[23];
assign io_out[23:21] = 0;
assign io_oe[0] = !OEb && !CEb;

wire [7:0] D_in = io_in[20:13];
reg [7:0] D_out;
assign io_out[20:13] = D_out;

reg [7:0] DDRA;
reg [7:0] DDRB;
reg [7:0] PORTA;
reg [7:0] PORTB;
reg [7:0] PUA;
reg [7:0] PUB;
reg [7:0] PDA;
reg [7:0] PDB;
assign io_out[31:25] = PORTA[7:1];
assign io_oe[8:1] = DDRA;
assign io_out[39:32] = PORTB;
assign io_oe[16:9] = DDRB;

reg [15:0] uart_div;
reg flow_ctrl;
wire [7:0] uart_dout;
wire uart_busy;
wire uart_hb;
reg uart_int_en;
wire RXD = io_in[40];
assign io_out[40] = 1'b1;
wire TXD;
assign io_out[41] = TXD;
assign io_out[24] = flow_ctrl ? !uart_hb : PORTA[0];

wire spi_busy;
reg [7:0] spi_div;
wire [7:0] spi_dout;
wire SDI = io_in[1];
assign io_out[1] = 0;
wire SDO;
assign io_out[3] = SDO;
wire SCLK;
assign io_out[4] = SCLK;

reg tmr0_o;
reg tmr1_o;
assign io_out[5] = tmr0_o;
assign io_out[6] = tmr1_o;
wire tmr0_clk = io_in[24];
wire tmr1_clk = io_in[25];
reg [2:0] tmr_ie;
reg tmr0_ext;
reg tmr1_ext;
reg last_tmr0_clk;
reg last_tmr1_clk;
reg [15:0] timer0;
reg [15:0] timer1;
reg [15:0] timer2;
reg [15:0] t0_capture;
reg [15:0] t1_capture;
reg [15:0] t2_capture;
reg [15:0] t0pre;
reg [15:0] t1pre;
reg [15:0] t2pre;
reg [15:0] t0pre_counter;
reg [15:0] t1pre_counter;
reg [15:0] t2pre_counter;
reg [15:0] t0_top;
reg [15:0] t1_top;
reg [15:0] t2_top;
reg t0irq;
reg t1irq;
reg t2irq;

reg [63:0] xorshift_state;
wire [63:0] xorshift_1 = xorshift_state ^ {xorshift_state[50:0], 13'h0000};
wire [63:0] xorshift_2 = xorshift_1 ^ {7'h00, xorshift_state[63:7]};
wire [63:0] xorshift_3 = xorshift_2 ^ {xorshift_state[46:0], 17'h00000};

wire irupt = (uart_hb && uart_int_en) || t0irq || t1irq || t2irq;
assign io_out[0] = !irupt;

reg [7:0] memory [15:0];

always @(*) begin
	case(address)
		default: D_out = 8'hxx;
		0: D_out = DDRA;
		1: D_out = DDRB;
		2: D_out = PORTA;
		3: D_out = PORTB;
		4: D_out = io_in[31:24];
		5: D_out = io_in[39:32];
		6: D_out = spi_div;
		7: D_out = spi_dout;
		8: D_out = uart_div[7:0];
		9: D_out = uart_div[15:8];
		10: D_out = uart_dout;
		11: D_out = {uart_int_en, flow_ctrl, 3'h0, uart_busy, uart_hb, spi_busy};
		12: D_out = {3'h0, tmr1_ext, tmr0_ext, tmr_ie};
		13: D_out = {5'h0, t2irq, t1irq, t0irq};
		15: D_out = t0pre[7:0];
		16: D_out = t0pre[15:8];
		17: D_out = t1pre[7:0];
		18: D_out = t1pre[15:8];
		19: D_out = t2pre[7:0];
		20: D_out = t2pre[15:8];
		21: D_out = t0_top[7:0];
		22: D_out = t0_top[15:8];
		23: D_out = t1_top[7:0];
		24: D_out = t1_top[15:8];
		25: D_out = t2_top[7:0];
		26: D_out = t2_top[15:8];
		27: D_out = t0_capture[7:0];
		28: D_out = t0_capture[15:8];
		29: D_out = t1_capture[7:0];
		30: D_out = t1_capture[15:8];
		31: D_out = t2_capture[7:0];
		32: D_out = t2_capture[15:8];
		33: D_out = adc_out_1[7:0];
		34: D_out = {4'h0, adc_out_1[11:8]};
		35: D_out = adc_out_2[7:0];
		36: D_out = {4'h0, adc_out_2[11:8]};
		37: D_out = adc_out_3[7:0];
		38: D_out = {4'h0, adc_out_3[11:8]};
		39: D_out = xorshift_state[7:0];
		40: D_out = xorshift_state[15:8];
		41: D_out = xorshift_state[23:16];
		42: D_out = xorshift_state[31:24];
		43: D_out = PUA;
		44: D_out = PUB;
		45: D_out = PDA;
		46: D_out = PDB;
		
		48: D_out = memory[0];
		49: D_out = memory[1];
		50: D_out = memory[2];
		51: D_out = memory[3];
		52: D_out = memory[4];
		53: D_out = memory[5];
		54: D_out = memory[6];
		55: D_out = memory[7];
		56: D_out = memory[8];
		57: D_out = memory[9];
		58: D_out = memory[10];
		59: D_out = memory[11];
		60: D_out = memory[12];
		61: D_out = memory[13];
		62: D_out = memory[14];
		63: D_out = memory[15];
	endcase
end

assign io_pd = {PDB & ~DDRB, PDA & ~DDRA};
assign io_pu = {PUB & ~DDRB, PUA & ~DDRA};

wire write_cond = !CEb && !WEb && OEb;
wire read_cond = !CEb && !OEb;
reg [7:0] temp;
always @(posedge clk_i) begin
	if(reset) begin
		DDRA <= 0;
		DDRB <= 0;
		uart_int_en <= 0;
		tmr_ie <= 0;
		t0irq <= 0;
		t1irq <= 0;
		t2irq <= 0;
		adc_out_1 <= 12'hFFF;
		adc_out_2 <= 12'hFFF;
		adc_out_3 <= 12'hFFF;
		xorshift_state[7:0] <= 8'hA;
		flow_ctrl <= 0;
		PUA <= 0;
		PUB <= 0;
		PDA <= 0;
		PDB <= 0;
	end else begin
		xorshift_state <= xorshift_3;
		t0irq <= t0irq & tmr_ie[0];
		t1irq <= t1irq & tmr_ie[1];
		t2irq <= t2irq & tmr_ie[2];
		
		if(write_cond) begin
			case(address)
				0: DDRA <= D_in;
				1: DDRB <= D_in;
				2: PORTA <= D_in;
				3: PORTB <= D_in;
				6: spi_div <= D_in;
				8: uart_div[7:0] <= D_in;
				9: uart_div[15:8] <= D_in;
				11: begin
					uart_int_en <= D_in[7];
					flow_ctrl <= D_in[6];
				end
				12: begin
					tmr_ie <= D_in[2:0];
					tmr0_ext <= D_in[3];
					tmr1_ext <= D_in[4];
				end
				13: begin
					if(D_in[0]) t0irq <= 0;
					if(D_in[1]) t1irq <= 0;
					if(D_in[2]) t2irq <= 0;
				end
				14: begin
					t0_capture <= timer0;
					t1_capture <= timer1;
					t2_capture <= timer2;
				end
				15: temp <= D_in;
				16: t0pre <= {D_in, temp};
				17: temp <= D_in;
				18: t1pre <= {D_in, temp};
				19: temp <= D_in;
				20: t2pre <= {D_in, temp};
				21: temp <= D_in;
				22: t0_top <= {D_in, temp};
				23: temp <= D_in;
				24: t1_top <= {D_in, temp};
				25: temp <= D_in;
				26: t2_top <= {D_in, temp};
				27: temp <= D_in;
				28: timer0 <= {D_in, temp};
				29: temp <= D_in;
				30: timer1 <= {D_in, temp};
				31: temp <= D_in;
				32: timer2 <= {D_in, temp};
				33: temp <= D_in;
				34: adc_out_1 <= {D_in[3:0], temp};
				35: temp <= D_in;
				36: adc_out_2 <= {D_in[3:0], temp};
				37: temp <= D_in;
				38: adc_out_3 <= {D_in[3:0], temp};
				43: PUA <= D_in;
				44: PUB <= D_in;
				45: PDA <= D_in;
				46: PDB <= D_in;
				
				48: memory[0] <= D_in;
				49: memory[1] <= D_in;
				50: memory[2] <= D_in;
				51: memory[3] <= D_in;
				52: memory[4] <= D_in;
				53: memory[5] <= D_in;
				54: memory[6] <= D_in;
				55: memory[7] <= D_in;
				56: memory[8] <= D_in;
				57: memory[9] <= D_in;
				58: memory[10] <= D_in;
				59: memory[11] <= D_in;
				60: memory[12] <= D_in;
				61: memory[13] <= D_in;
				62: memory[14] <= D_in;
				63: memory[15] <= D_in;
			endcase
		end
		
		if(!tmr0_ext || (!last_tmr0_clk && tmr0_clk)) begin
			t0pre_counter <= t0pre_counter + 1;
			if((t0pre_counter+1) >= t0pre) begin
				t0pre_counter <= 0;
				timer0 <= timer0 + 1;
				if(timer0 >= t0_top) begin
					timer0 <= 16'h0000;
					tmr0_o <= ~tmr0_o;
					t0irq <= tmr_ie[0];
				end
			end
		end
		if(!tmr1_ext || (!last_tmr1_clk && tmr1_clk)) begin
			t1pre_counter <= t1pre_counter + 1;
			if((t1pre_counter+1) >= t1pre) begin
				t1pre_counter <= 0;
				timer1 <= timer1 + 1;
				if(timer1 >= t1_top) begin
					timer1 <= 16'h0000;
					tmr1_o <= ~tmr1_o;
					t1irq <= tmr_ie[1];
				end
			end
		end
		t2pre_counter <= t2pre_counter + 1;
		if((t2pre_counter+1) >= t2pre) begin
			t2pre_counter <= 0;
			timer2 <= timer2 + 1;
			if(timer2 > t2_top) begin
				timer2 <= 16'h0000;
				t2irq <= tmr_ie[2];
			end
		end
		last_tmr0_clk <= tmr0_clk;
		last_tmr1_clk <= tmr1_clk;
	end	
end

qcpu_uart qcpu_uart(
	.divisor(uart_div),
	.din(D_in),
	.dout(uart_dout),
	.TX(TXD),
	.RX(RXD),
	.start(write_cond && address == 10 && !uart_busy),
	.busy(uart_busy),
	.has_byte(uart_hb),
	.clr_hb(read_cond && address == 10),
	.clk(clk_i),
	.rst(reset)
);

qcpu_spi spi(
	.divisor(spi_div),
	.din(D_in),
	.dout(spi_dout),
	.SCLK(SCLK),
	.DO(SDO),
	.DI(SDI),
	.start(write_cond && address == 7 && !spi_busy),
	.busy(spi_busy),
	.clk(clk_i),
	.rst(reset)
);

generate
for (genvar i=1; i<42; i++) begin
	(* keep *)
	gf180mcu_fd_sc_mcu7t5v0__antenna input_tie (
		`ifdef USE_POWER_PINS
		.VNW    (VDD),
		.VPW    (VSS),
		.VDD    (VDD),
		.VSS    (VSS),
		`endif
		.I(io_in[i])
	);
end
endgenerate

endmodule
