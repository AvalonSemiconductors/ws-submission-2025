`default_nettype none

module wrapped_qcpu(
 // Required so LVS passes
`ifdef USE_POWER_PINS
  inout vdd,
  inout vss,
`endif
  input clk_i, //Clock input
  input rst_n, //Active low
  input [32:0] io_in,
  output [32:0] io_out,
  output [32:0] io_oeb, //Output Enable Bar ; 0 = Output, 1 = Input
  output [6:0] sram_addr,
  output [7:0] sram_in,
  input [7:0] sram_out,
  output sram_gwe //Global write-enable
);

wire CS_ROM;
wire SCLK_ROM;
wire [3:0] ROM_DO;
wire ROM_OEB;
wire ROM_spi_mode;

wire [7:0] PORTA_DDR;
wire [7:0] PORTB_DDR;
wire [7:0] PORTA;
wire [7:0] PORTB;
wire txd;
wire spi_sclk;
wire spi_do;
wire M1;
wire pwm;
wire toggle;

assign io_out = {ROM_spi_mode ? 1'b0 : ROM_OEB, toggle, pwm, 1'b0, 1'b0, M1, 1'b0, spi_do, spi_sclk, 1'b0, txd, PORTB, PORTA, SCLK_ROM, CS_ROM, ROM_DO};
assign io_oeb = {1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, ~PORTB_DDR, ~PORTA_DDR, 1'b0, 1'b0, ROM_spi_mode ? 1'b0 : ROM_OEB, ROM_spi_mode ? 1'b0 : ROM_OEB, ROM_spi_mode ? 1'b1 : ROM_OEB, ROM_spi_mode ? 1'b0 : ROM_OEB};

qcpu cpu(
  .clk(clk_i),
  .rst_n(rst_n),
  
  .CS_ROM(CS_ROM),
  .SCLK_ROM(SCLK_ROM),
  .ROM_DO(ROM_DO),
  .ROM_DI(io_in[3:0]),
  .ROM_OEB(ROM_OEB),
  .ROM_spi_mode(ROM_spi_mode),

  .PORTA_DDR(PORTA_DDR),
  .PORTB_DDR(PORTB_DDR),
  .PORTA(PORTA),
  .PORTB(PORTB),
  .PINA(io_in[13:6]),
  .PINB(io_in[21:14]),

  .RAM_we(sram_gwe),
  .RAM_addr(sram_addr),
  .RAM_in(sram_in),
  .RAM_out(sram_out),

  .rxd(io_in[23]),
  .txd(txd),
  .spi_sclk(spi_sclk),
  .spi_do(spi_do),
  .spi_di(io_in[26]),

  .M1(M1),

  .intb(io_in[28]),
  .pause(io_in[29]),
  .pwm(pwm),
  .toggle(toggle)
);

endmodule
