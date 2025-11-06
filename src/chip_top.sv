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
    wire sid_pot_x;
    wire sid_pot_y;
    wire sid_audio_0_vic_r;
    wire sid_audio_1_vic_g;
    wire vic_b;
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
        .rst_override_n_sid(rst_override_n_sid)
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
        .io_in(bidir_PAD2CORE),
        .io_out(io_out_c64pla),
        .io_oe(io_oe_c64pla)
    );
    
    sid sid(
    `ifdef USE_POWER_PINS
        .VSS(VSS),
        .VDD(VDD),
    `endif
        .clk_i(clk_PAD2CORE),
        .rst_override_n(rst_override_n_sid),
        .io_in(bidir_PAD2CORE),
        .io_out(io_out_sid),
        .io_oe(io_oe_sid)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_0(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vic_luma)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_1(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vic_chroma)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_2(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(sid_pot_y)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_3(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(sid_pot_x)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_4(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(sid_audio_0_vic_r)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_5(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(sid_audio_1_vic_g)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_6(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(vic_b)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_7(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_0)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_8(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_1)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_9(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_2)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_10(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_3)
    );
    
    (* keep *)
    gf180mcu_fd_io__asig_5p0 analog_11(
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
        .ASIG5V(spare_analog_4)
    );
    
    // Die ID - do not remove, necessary for tapeout
    (* keep *)
    gf180mcu_ws_ip__id chip_id ();
    
    (* keep *)
    gf180mcu_ws_ip__logo wafer_space_logo ();
    
    (* keep *)
    avali_logo avali_logo ();

endmodule

`default_nettype wire
