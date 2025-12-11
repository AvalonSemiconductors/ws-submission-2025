`default_nettype none

module c64pla(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	input rst_override_n,
	
	input [41:0] io_in_buffered,
	output [41:0] io_out,
	output io_oe
);

wire ROMHn_fast;
wire ROMLn_fast;
wire IOn_fast;
wire GRWn_fast;
wire CHAROMn_fast;
wire KERNALn_fast;
wire BASICn_fast;
wire CASRAMn_fast;

wire speed_sel = io_in_buffered[37];
wire [1:0] speed_sel_cas = io_in_buffered[39:38];

//A "modern" process node like GF180 produces way too fast logic - there would be timing violations (particularly holds) all over the C64
//So, delay needs to be intentionally added through delay buffer cells
//However, due to process corners and other unknowns, the exact number of buffers needed cannot be determined
//So, extra input pins allow delay selection. These inputs can be expoded to solder bridges on dev boards and finally bonded to ground in production
//boards to always produce the needed delay
//Each dylb_2 produces ~1ns of delay at the typical corner

//CASRAMn needs particularly long delay of 30ns total
(* keep *) wire [39:0] CASRAMn_dyl; //Each entry is ~1ns more delayed than the previous
(* keep = "true" *)
gf180mcu_fd_sc_mcu7t5v0__dlyb_2 dylb(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.I(CASRAMn_fast),
	.Z(CASRAMn_dyl[0])
);
generate
for (genvar i=1; i<40; i++) begin : casram_dyl
	(* keep *)
	gf180mcu_fd_sc_mcu7t5v0__dlyb_2 dylb(
	`ifdef USE_POWER_PINS
		.VSS(VSS),
		.VDD(VDD),
	`endif
		.I(CASRAMn_dyl[i-1]),
		.Z(CASRAMn_dyl[i])
	);
end
endgenerate
wire CASRAMn = speed_sel_cas == 0 ? CASRAMn_dyl[9] : (speed_sel_cas == 1 ? CASRAMn_dyl[24] : (speed_sel_cas == 2 ? CASRAMn_fast : CASRAMn_dyl[39]));

//All other signals get no or just a little delay
wire ROMHn;
cond_delay dyl_romhn(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.in(ROMHn_fast),
	.out(ROMHn),
	.speed_sel(speed_sel)
);

wire ROMLn;
cond_delay dyl_romln(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.in(ROMLn_fast),
	.out(ROMLn),
	.speed_sel(speed_sel)
);

wire IOn;
cond_delay dyl_ion(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.in(IOn_fast),
	.out(IOn),
	.speed_sel(speed_sel)
);

wire GRWn;
cond_delay dyl_grwn(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.in(GRWn_fast),
	.out(GRWn),
	.speed_sel(speed_sel)
);

wire CHAROMn;
cond_delay dyl_charomn(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.in(CHAROMn_fast),
	.out(CHAROMn),
	.speed_sel(speed_sel)
);

wire KERNALn;
cond_delay dyl_kernaln(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.in(KERNALn_fast),
	.out(KERNALn),
	.speed_sel(speed_sel)
);

wire BASICn;
cond_delay dyl_basicn(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.in(BASICn_fast),
	.out(BASICn),
	.speed_sel(speed_sel)
);

pla pla(
	.FE(io_in_buffered[7]),
	.A13(io_in_buffered[8]),
	.A14(io_in_buffered[9]),
	.A15(io_in_buffered[10]),
	.VA14n(io_in_buffered[12]),
	.CHARENn(io_in_buffered[13]),
	.HIRAMn(io_in_buffered[14]),
	.LORAMn(io_in_buffered[19]),
	.CASn(io_in_buffered[20]),
	.ROMHn(ROMHn_fast),
	.ROMLn(ROMLn_fast),
	.IOn(IOn_fast),
	.GRWn(GRWn_fast),
	.CHAROMn(CHAROMn_fast),
	.KERNALn(KERNALn_fast),
	.BASICn(BASICn_fast),
	.CASRAMn(CASRAMn_fast),
	.OEn(io_in_buffered[32]),
	.VA12(io_in_buffered[33]),
	.VA13(io_in_buffered[35]),
	.GAMEn(io_in_buffered[40]),
	.EXROMn(io_in_buffered[41]),
	.RWn(io_in_buffered[0]),
	.AECn(io_in_buffered[1]),
	.BA(io_in_buffered[2]),
	.A12(io_in_buffered[3])
);
assign io_out[20:0] = 0;
assign io_out[21] = ROMHn;
assign io_out[22] = ROMLn;
assign io_out[23] = IOn;
assign io_out[24] = GRWn;
assign io_out[25] = 0;
assign io_out[26] = CHAROMn;
assign io_out[27] = KERNALn;
assign io_out[29:28] = 0;
assign io_out[30] = BASICn;
assign io_out[31] = CASRAMn;
assign io_out[41:32] = 0;
assign io_oe = !io_in_buffered[32];

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
		.I(io_in_buffered[i])
	);
end
endgenerate

endmodule

module cond_delay(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input in,
	output out,
	input speed_sel
);

(* keep *) wire [4:0] dyl;
(* keep *)
gf180mcu_fd_sc_mcu7t5v0__dlyb_2 dylb(
`ifdef USE_POWER_PINS
	.VSS(VSS),
	.VDD(VDD),
`endif
	.I(in),
	.Z(dyl[0])
);
generate
for (genvar i=1; i<5; i++) begin : cond_delay_dyl
	(* keep *)
	gf180mcu_fd_sc_mcu7t5v0__dlyb_2 dylb(
	`ifdef USE_POWER_PINS
		.VSS(VSS),
		.VDD(VDD),
	`endif
		.I(dyl[i-1]),
		.Z(dyl[i])
	);
end
endgenerate

assign out = speed_sel ? dyl[4] : in;

endmodule
