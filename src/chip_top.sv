// SPDX-FileCopyrightText: © 2025 wafer.space
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module chip_top #(
    parameter NUM_BIDIR = 42
    )(
    `ifdef USE_POWER_PINS
    inout wire VDD,
    inout wire VSS,
    `endif

    inout  wire       clk_PAD,
    inout  wire [4:0] design_sel_PAD,
    
    inout  wire [NUM_BIDIR-1:0] bidir_PAD
);

    wire clk_PAD2CORE;
    wire [4:0] design_sel_PAD2CORE;

    wire [NUM_BIDIR-1:0] bidir_PAD2CORE;
    wire [NUM_BIDIR-1:0] bidir_CORE2PAD;
    wire [NUM_BIDIR-1:0] bidir_CORE2PAD_OE;
    wire [NUM_BIDIR-1:0] bidir_CORE2PAD_CS;
    wire [NUM_BIDIR-1:0] bidir_CORE2PAD_SL;
    wire [NUM_BIDIR-1:0] bidir_CORE2PAD_IE;
    wire [NUM_BIDIR-1:0] bidir_CORE2PAD_PU;
    wire [NUM_BIDIR-1:0] bidir_CORE2PAD_PD;
    
    wire [6:0] const_zero;
    wire [4:0] const_one;
    
    wire vic_luma;
    wire vic_chroma;
    wire vga_r;
    wire vga_g;
    wire vga_b;
    wire sid_audio_0;
    wire sid_audio_1;
    wire spare_analog_0;
    wire spare_analog_1;
    wire spare_analog_2;
    wire spare_analog_3;
    wire spare_analog_4;

    // Power / ground IO pad instances

    // South
    (* keep *)
    gf180mcu_ws_io__dvdd dvdd_south_0 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VSS    (VSS)
        `endif
    );

    // East
    (* keep *)
    gf180mcu_ws_io__dvss dvss_east_0 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VDD    (VDD)
        `endif
    );
    
    (* keep *)
    gf180mcu_ws_io__dvdd dvdd_east_0 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VSS    (VSS)
        `endif
    );

    (* keep *)
    gf180mcu_ws_io__dvss dvss_east_1 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VDD    (VDD)
        `endif
    );

    (* keep *)
    gf180mcu_ws_io__dvdd dvdd_east_1 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VSS    (VSS)
        `endif
    );
    
   (* keep *)
    gf180mcu_ws_io__dvss dvss_east_2 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VDD    (VDD)
        `endif
    );
    
    // North
    (* keep *)
    gf180mcu_fd_io__dvss dvss_north_0 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VDD    (VDD)
        `endif
    );
    
    (* keep *)
    gf180mcu_ws_io__dvdd dvdd_north_0 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VSS    (VSS)
        `endif
    );
    
    // West
    (* keep *)
    gf180mcu_ws_io__dvdd dvdd_west_0 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VSS    (VSS)
        `endif
    );

    (* keep *)
    gf180mcu_ws_io__dvss dvss_west_0 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VDD    (VDD)
        `endif
    );

    (* keep *)
    gf180mcu_ws_io__dvdd dvdd_west_1 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VSS    (VSS)
        `endif
    );

    (* keep *)
    gf180mcu_ws_io__dvss dvss_west_1 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VDD    (VDD)
        `endif
    );

    (* keep *)
    gf180mcu_ws_io__dvss dvss_west_2 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VDD    (VDD)
        `endif
    );

    (* keep *)
    gf180mcu_ws_io__dvdd dvdd_west_2 (
        `ifdef USE_POWER_PINS
        	.DVDD   (VDD),
	    .DVSS   (VSS),
	    .VSS    (VSS)
        `endif
    );

    // Signal IO pad instances

    gf180mcu_fd_io__in_c clk_pad (
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
    
        .Y      (clk_PAD2CORE),
        .PAD    (clk_PAD),
        
        .PU     (const_zero[0]),
        .PD     (const_zero[1])
    );

    generate
    for (genvar i=0; i<NUM_BIDIR; i++) begin : bidir
        (* keep *)
        gf180mcu_fd_io__bi_24t pad (
            `ifdef USE_POWER_PINS
            .DVDD   (VDD),
            .DVSS   (VSS),
            .VDD    (VDD),
            .VSS    (VSS),
            `endif
        
            .A      (bidir_CORE2PAD[i]),
            .OE     (bidir_CORE2PAD_OE[i]),
            .Y      (bidir_PAD2CORE[i]),
            .PAD    (bidir_PAD[i]),
            
            .CS     (bidir_CORE2PAD_CS[i]),
            .SL     (bidir_CORE2PAD_SL[i]),
            .IE     (bidir_CORE2PAD_IE[i]),

            .PU     (bidir_CORE2PAD_PU[i]),
            .PD     (bidir_CORE2PAD_PD[i])
        );
    end
    endgenerate
    
    generate
    for (genvar i=0; i<5; i++) begin : design_sel
        (* keep *)
        gf180mcu_fd_io__in_s pad (
            `ifdef USE_POWER_PINS
            .DVDD   (VDD),
            .DVSS   (VSS),
            .VDD    (VDD),
            .VSS    (VSS),
            `endif
            
            .Y      (design_sel_PAD2CORE[i]),
            .PAD    (design_sel_PAD[i]),
            .PU     (const_one[i]),
            .PD     (const_zero[2+i])
        );
    end
    endgenerate
    
    wire [41:0] io_in_buffered;
    wire [4:0] design_sel_buffered;
    wire clk_buffered;
    
    repeater repeater(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .clk_o(clk_buffered),
        .io_in(bidir_PAD2CORE),
        .design_sel(design_sel_PAD2CORE),
        .io_in_buffered(io_in_buffered),
        .design_sel_buffered(design_sel_buffered)
    );
    
    wire [41:0] io_out_6502;
    wire [41:0] io_oe_6502;
    wire rst_override_n_6502;
    wire select_6502;
    
    wire rst_override_n_c64pla;
    wire [41:0] io_out_c64pla;
    wire io_oe_c64pla;
    
    wire [41:0] io_out_sid;
    wire [2:0] io_oe_sid;
    wire rst_override_n_sid;
    
    wire [41:0] io_out_gpiochip;
    wire [16:0] io_oe_gpiochip;
    wire [15:0] io_pu_gpiochip;
    wire [15:0] io_pd_gpiochip;
    wire rst_override_n_gpiochip;
    
    wire [41:0] io_out_dram_controller;
    wire rst_override_n_dram_controller;
    
    wire [11:0] io_out_ntsc;
    wire rst_override_n_ntsc;
    
    wire [41:0] io_out_misc;
    wire [41:0] io_oe_misc;
    wire [41:0] io_pu_misc;
    wire [41:0] io_pd_misc;
    wire [41:0] io_cs_misc;
    wire rst_override_n_misc;
    
    wire [41:0] io_out_65rv32;
    wire [41:0] io_oe_65rv32;
    wire rst_override_n_65rv32;
    
    wire [41:0] io_out_fm;
    wire [2:0] io_oe_fm;
    wire rst_override_n_fm;
    
    multiplexer multiplexer(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .io_out(bidir_CORE2PAD),
        .io_oe(bidir_CORE2PAD_OE),
        .io_cs(bidir_CORE2PAD_CS),
        .io_sl(bidir_CORE2PAD_SL),
        .io_pu(bidir_CORE2PAD_PU),
        .io_pd(bidir_CORE2PAD_PD),
        .io_ie(bidir_CORE2PAD_IE),
        .const_one(const_one),
        .const_zero(const_zero),
        .design_sel(design_sel_PAD2CORE),
        
        .io_out_6502(io_out_6502),
        .io_oe_6502(io_oe_6502),
        .rst_override_n_6502(rst_override_n_6502),
        .select_6502(select_6502),
        
        .io_out_c64pla(io_out_c64pla),
        .io_oe_c64pla(io_oe_c64pla),
        .rst_override_n_c64pla(rst_override_n_c64pla),
        
        .io_out_sid(io_out_sid),
        .io_oe_sid(io_oe_sid),
        .rst_override_n_sid(rst_override_n_sid),
        
        .io_out_gpiochip(io_out_gpiochip),
        .io_oe_gpiochip(io_oe_gpiochip),
        .io_pu_gpiochip(io_pu_gpiochip),
        .io_pd_gpiochip(io_pd_gpiochip),
        .rst_override_n_gpiochip(rst_override_n_gpiochip),
        
        .io_out_dram_controller(io_out_dram_controller),
        .rst_override_n_dram_controller(rst_override_n_dram_controller),
        
        .io_out_ntsc(io_out_ntsc),
        .rst_override_n_ntsc(rst_override_n_ntsc),
        
        .io_out_misc(io_out_misc),
        .io_oe_misc(io_oe_misc),
        .io_pu_misc(io_pu_misc),
        .io_pd_misc(io_pd_misc),
        .io_cs_misc(io_cs_misc),
        .rst_override_n_misc(rst_override_n_misc),
        
        .io_out_65rv32(io_out_65rv32),
        .io_oe_65rv32(io_oe_65rv32),
        .rst_override_n_65rv32(rst_override_n_65rv32),
        
        .io_out_fm(io_out_fm),
        .io_oe_fm(io_oe_fm),
        .rst_override_n_fm(rst_override_n_fm)
    );

    as65x as65x(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_6502),
        .io_in(bidir_PAD2CORE),
        .io_out(io_out_6502),
        .io_oe(io_oe_6502),
        .select_6502(select_6502)
    );
    
    c64pla c64pla(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_c64pla),
        .io_in_buffered(io_in_buffered),
        .io_out(io_out_c64pla),
        .io_oe(io_oe_c64pla)
    );
    
    wire [11:0] gpiochip_sample_1;
    wire [11:0] gpiochip_sample_2;
    wire [11:0] gpiochip_sample_3;
    wire [11:0] sample_raw_1;
    wire [11:0] sample_raw_2;
    wire [11:0] sample_raw_3;
    sid sid(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_sid),
        .io_in_buffered(io_in_buffered),
        .io_out(io_out_sid),
        .io_oe(io_oe_sid),
        .gpiochip_sample_1(gpiochip_sample_1),
        .gpiochip_sample_2(gpiochip_sample_2),
        .gpiochip_sample_3(gpiochip_sample_3),
        .sample_raw_1(sample_raw_1),
        .sample_raw_2(sample_raw_2),
        .sample_raw_3(sample_raw_3)
    );
    
    (* keep *)
    r2r_dac_buffered dac0(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(sample_raw_1[0]),
        .D1(sample_raw_1[1]),
        .D2(sample_raw_1[2]),
        .D3(sample_raw_1[3]),
        .D4(sample_raw_1[4]),
        .D5(sample_raw_1[5]),
        .D6(sample_raw_1[6]),
        .D7(sample_raw_1[7]),
        .D8(sample_raw_1[8]),
        .D9(sample_raw_1[9]),
        .D10(sample_raw_1[10]),
        .D11(sample_raw_1[11]),
        .OUT(sid_audio_0)
    );
    
    (* keep *)
    r2r_dac_buffered dac1(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(sample_raw_2[0]),
        .D1(sample_raw_2[1]),
        .D2(sample_raw_2[2]),
        .D3(sample_raw_2[3]),
        .D4(sample_raw_2[4]),
        .D5(sample_raw_2[5]),
        .D6(sample_raw_2[6]),
        .D7(sample_raw_2[7]),
        .D8(sample_raw_2[8]),
        .D9(sample_raw_2[9]),
        .D10(sample_raw_2[10]),
        .D11(sample_raw_2[11]),
        .OUT(sid_audio_1)
    );
    
    (* keep *)
    r2r_dac_buffered dac2(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(sample_raw_3[0]),
        .D1(sample_raw_3[1]),
        .D2(sample_raw_3[2]),
        .D3(sample_raw_3[3]),
        .D4(sample_raw_3[4]),
        .D5(sample_raw_3[5]),
        .D6(sample_raw_3[6]),
        .D7(sample_raw_3[7]),
        .D8(sample_raw_3[8]),
        .D9(sample_raw_3[9]),
        .D10(sample_raw_3[10]),
        .D11(sample_raw_3[11]),
        .OUT(spare_analog_0)
    );
    
    gpiochip gpiochip(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_gpiochip),
        .io_in(bidir_PAD2CORE),
        .io_out(io_out_gpiochip),
        .io_oe(io_oe_gpiochip),
        .io_pu(io_pu_gpiochip),
        .io_pd(io_pd_gpiochip),
        .adc_out_1(gpiochip_sample_1),
        .adc_out_2(gpiochip_sample_2),
        .adc_out_3(gpiochip_sample_3)
    );
    
    dram_controller dram_controller(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_dram_controller),
        .io_out(io_out_dram_controller),
        .io_in_buffered(io_in_buffered)
    );
    
    wire [11:0] sample_raw_ntsc;
    ntsc ntsc(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_ntsc),
        .io_in_buffered(io_in_buffered),
        .io_out(io_out_ntsc),
        .sample_raw_1(sample_raw_ntsc)
    );
    
    (* keep *)
    r2r_dac_buffered dac3(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(sample_raw_ntsc[0]),
        .D1(sample_raw_ntsc[1]),
        .D2(sample_raw_ntsc[2]),
        .D3(sample_raw_ntsc[3]),
        .D4(sample_raw_ntsc[4]),
        .D5(sample_raw_ntsc[5]),
        .D6(sample_raw_ntsc[6]),
        .D7(sample_raw_ntsc[7]),
        .D8(sample_raw_ntsc[8]),
        .D9(sample_raw_ntsc[9]),
        .D10(sample_raw_ntsc[10]),
        .D11(sample_raw_ntsc[11]),
        .OUT(vic_luma)
    );
    
    wire [11:0] vga_sample_r;
    wire [11:0] vga_sample_g;
    wire [11:0] vga_sample_b;
    (* keep *)
    misc misc(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_misc),
        .io_in_buffered(io_in_buffered),
        .io_out(io_out_misc),
        .io_oe(io_oe_misc),
        .io_pu(io_pu_misc),
        .io_pd(io_pd_misc),
        .io_cs(io_cs_misc),
        .sample_raw_1(vga_sample_r),
        .sample_raw_2(vga_sample_g),
        .sample_raw_3(vga_sample_b),
        .design_sel_buffered(design_sel_buffered[2:0])
    );
    
    (* keep *)
    r2r_dac_buffered dac4(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(vga_sample_r[0]),
        .D1(vga_sample_r[1]),
        .D2(vga_sample_r[2]),
        .D3(vga_sample_r[3]),
        .D4(vga_sample_r[4]),
        .D5(vga_sample_r[5]),
        .D6(vga_sample_r[6]),
        .D7(vga_sample_r[7]),
        .D8(vga_sample_r[8]),
        .D9(vga_sample_r[9]),
        .D10(vga_sample_r[10]),
        .D11(vga_sample_r[11]),
        .OUT(vga_r)
    );
    
    (* keep *)
    r2r_dac_buffered dac5(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(vga_sample_g[0]),
        .D1(vga_sample_g[1]),
        .D2(vga_sample_g[2]),
        .D3(vga_sample_g[3]),
        .D4(vga_sample_g[4]),
        .D5(vga_sample_g[5]),
        .D6(vga_sample_g[6]),
        .D7(vga_sample_g[7]),
        .D8(vga_sample_g[8]),
        .D9(vga_sample_g[9]),
        .D10(vga_sample_g[10]),
        .D11(vga_sample_g[11]),
        .OUT(vga_g)
    );
    
    (* keep *)
    r2r_dac_buffered dac6(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(vga_sample_b[0]),
        .D1(vga_sample_b[1]),
        .D2(vga_sample_b[2]),
        .D3(vga_sample_b[3]),
        .D4(vga_sample_b[4]),
        .D5(vga_sample_b[5]),
        .D6(vga_sample_b[6]),
        .D7(vga_sample_b[7]),
        .D8(vga_sample_b[8]),
        .D9(vga_sample_b[9]),
        .D10(vga_sample_b[10]),
        .D11(vga_sample_b[11]),
        .OUT(vga_b)
    );
    
    as65rv32 as65rv32(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_65rv32),
        .io_in(bidir_PAD2CORE),
        .io_out(io_out_65rv32),
        .io_oe(io_oe_65rv32),
        .select_6502(select_6502)
    );
    
    wire [11:0] sample_raw_fm_1;
    wire [11:0] sample_raw_fm_2;
    wire [11:0] sample_raw_fm_3;
    fm fm(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_fm),
        .io_in_buffered(io_in_buffered),
        .io_out(io_out_fm),
        .io_oe(io_oe_fm),
        .sample_raw_1(sample_raw_fm_1),
        .sample_raw_2(sample_raw_fm_2),
        .sample_raw_3(sample_raw_fm_3)
    );
    
    (* keep *)
    r2r_dac_buffered dac7(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(sample_raw_fm_1[0]),
        .D1(sample_raw_fm_1[1]),
        .D2(sample_raw_fm_1[2]),
        .D3(sample_raw_fm_1[3]),
        .D4(sample_raw_fm_1[4]),
        .D5(sample_raw_fm_1[5]),
        .D6(sample_raw_fm_1[6]),
        .D7(sample_raw_fm_1[7]),
        .D8(sample_raw_fm_1[8]),
        .D9(sample_raw_fm_1[9]),
        .D10(sample_raw_fm_1[10]),
        .D11(sample_raw_fm_1[11]),
        .OUT(spare_analog_1)
    );
    
    (* keep *)
    r2r_dac_buffered dac8(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(sample_raw_fm_2[0]),
        .D1(sample_raw_fm_2[1]),
        .D2(sample_raw_fm_2[2]),
        .D3(sample_raw_fm_2[3]),
        .D4(sample_raw_fm_2[4]),
        .D5(sample_raw_fm_2[5]),
        .D6(sample_raw_fm_2[6]),
        .D7(sample_raw_fm_2[7]),
        .D8(sample_raw_fm_2[8]),
        .D9(sample_raw_fm_2[9]),
        .D10(sample_raw_fm_2[10]),
        .D11(sample_raw_fm_2[11]),
        .OUT(spare_analog_2)
    );
    
    (* keep *)
    r2r_dac_buffered dac9(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .D0(sample_raw_fm_3[0]),
        .D1(sample_raw_fm_3[1]),
        .D2(sample_raw_fm_3[2]),
        .D3(sample_raw_fm_3[3]),
        .D4(sample_raw_fm_3[4]),
        .D5(sample_raw_fm_3[5]),
        .D6(sample_raw_fm_3[6]),
        .D7(sample_raw_fm_3[7]),
        .D8(sample_raw_fm_3[8]),
        .D9(sample_raw_fm_3[9]),
        .D10(sample_raw_fm_3[10]),
        .D11(sample_raw_fm_3[11]),
        .OUT(spare_analog_3)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_0(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(sid_audio_0),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_1(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_4),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_2(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_3),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_3(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_2),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_4(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vic_luma),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_5(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(sid_audio_1),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_6(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vga_b),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_7(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vic_chroma),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_8(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vga_r),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_9(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vga_g),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_10(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_0),
        .PAD()
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0_fixed analog_11(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_1),
        .PAD()
    );
    
    // Die ID - do not remove, necessary for tapeout
    (* keep *)
    gf180mcu_ws_ip__id chip_id ();
    
    (* keep *)
    gf180mcu_ws_ip__logo wafer_space_logo ();
    
    (* keep *)
    avali_logo avali_logo ();
    
    (* keep *)
    aef2 aef2 ();
    
    (* keep *)
    tholin tholin ();

endmodule

`default_nettype wire
