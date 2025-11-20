v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 60 70 60 90 {lab=VSS}
N 60 -90 60 -70 {lab=VDD}
N 210 210 250 210 {lab=#net1}
N 250 280 250 290 {lab=VSS}
N 90 50 90 210 {lab=#net1}
N 90 210 210 210 {lab=#net1}
N -730 -470 -730 -320 {lab=SIN0}
N -670 -470 -670 -320 {lab=WAVE1}
N -700 -470 -700 -440 {lab=VDD}
N -700 -350 -700 -320 {lab=VSS}
N -600 -470 -600 -320 {lab=WAVE1}
N -540 -470 -540 -320 {lab=SIN180}
N -570 -470 -570 -440 {lab=VDD}
N -570 -350 -570 -320 {lab=VSS}
N -840 -400 -730 -400 {lab=SIN0}
N -540 -400 -450 -400 {lab=SIN180}
N -730 -60 -730 90 {lab=SIN270}
N -670 -60 -670 90 {lab=WAVE2}
N -700 -60 -700 -30 {lab=VDD}
N -700 60 -700 90 {lab=VSS}
N -600 -60 -600 90 {lab=WAVE2}
N -540 -60 -540 90 {lab=SIN90}
N -570 -60 -570 -30 {lab=VDD}
N -570 60 -570 90 {lab=VSS}
N -670 10 -600 10 {lab=WAVE2}
N -840 10 -730 10 {lab=SIN270}
N -540 10 -450 10 {lab=SIN90}
N -750 -510 -700 -510 {lab=WAVE_SELECT}
N -750 -510 -750 -100 {lab=WAVE_SELECT}
N -750 -100 -700 -100 {lab=WAVE_SELECT}
N -620 -510 -570 -510 {lab=#net2}
N -620 -510 -620 -100 {lab=#net2}
N -620 -100 -570 -100 {lab=#net2}
N -700 -280 -650 -280 {lab=#net2}
N -650 -280 -650 130 {lab=#net2}
N -700 130 -650 130 {lab=#net2}
N -570 -280 -520 -280 {lab=WAVE_SELECT}
N -520 -280 -520 130 {lab=WAVE_SELECT}
N -570 130 -520 130 {lab=WAVE_SELECT}
N -950 300 -800 300 {lab=WAVE_SELECT}
N -800 240 -800 300 {lab=WAVE_SELECT}
N -800 300 -800 360 {lab=WAVE_SELECT}
N -760 270 -760 330 {lab=#net2}
N -760 390 -760 400 {lab=VSS}
N -760 200 -760 210 {lab=VDD}
N -760 300 -650 300 {lab=#net2}
N -650 130 -650 300 {lab=#net2}
N -800 -100 -800 240 {lab=WAVE_SELECT}
N -800 -100 -750 -100 {lab=WAVE_SELECT}
N -650 -100 -620 -100 {lab=#net2}
N -750 -180 -520 -180 {lab=WAVE_SELECT}
N -250 140 -230 140 {lab=WAVE1}
N -860 -640 -830 -640 {lab=VDD}
N -860 -610 -830 -610 {lab=VSS}
N -760 240 -750 240 {lab=VDD}
N -750 200 -750 240 {lab=VDD}
N -760 200 -750 200 {lab=VDD}
N -760 360 -750 360 {lab=VSS}
N -750 360 -750 400 {lab=VSS}
N -760 400 -750 400 {lab=VSS}
N 250 210 250 220 {lab=#net1}
N 230 250 230 280 {lab=VSS}
N 230 280 250 280 {lab=VSS}
N -200 160 -200 170 {lab=VSS}
N -90 -10 20 -10 {lab=#net3}
N -90 -20 -90 -10 {lab=#net3}
N -110 20 -110 50 {lab=VSS}
N -110 50 -90 50 {lab=VSS}
N -110 -50 -110 20 {lab=VSS}
N -90 50 -90 60 {lab=VSS}
N -90 -90 -90 -80 {lab=VDD}
N 20 10 20 140 {lab=#net4}
N 160 130 160 140 {lab=VSS}
N 160 -0 230 -0 {lab=COMBINED}
N 190 0 190 110 {lab=COMBINED}
N 130 110 130 140 {lab=#net4}
N 20 140 130 140 {lab=#net4}
N -670 -400 -640 -400 {lab=WAVE1}
N -640 -400 -600 -400 {lab=WAVE1}
N -250 320 -230 320 {lab=WAVE2}
N -170 320 -140 320 {lab=#net5}
N -140 140 -140 320 {lab=#net5}
N -200 340 -200 350 {lab=VSS}
N -10 140 20 140 {lab=#net4}
N -170 140 -70 140 {lab=#net5}
N -40 160 -40 170 {lab=VSS}
C {devices/lab_pin.sym} 60 90 1 1 {name=p2 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 60 -90 3 1 {name=p1 sig_type=std_logic lab=VDD}
C {symbols/ppolyf_u_1k_6p0.sym} 250 250 0 0 {name=R10
W=1e-6
L=1e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 250 290 1 1 {name=p33 sig_type=std_logic lab=VSS}
C {ipin.sym} -840 -400 0 0 {name=p4 lab=SIN0}
C {ipin.sym} -450 10 2 0 {name=p5 lab=SIN90}
C {ipin.sym} -450 -400 2 0 {name=p6 lab=SIN180}
C {ipin.sym} -840 10 0 0 {name=p7 lab=SIN270}
C {symbols/pfet_06v0.sym} -700 -490 1 0 {name=M3
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -700 -300 1 1 {name=M4
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -700 -440 1 1 {name=p8 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -700 -350 3 1 {name=p9 sig_type=std_logic lab=VSS}
C {ipin.sym} -950 300 0 0 {name=p10 lab=WAVE_SELECT}
C {symbols/pfet_06v0.sym} -570 -490 1 0 {name=M1
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -570 -300 1 1 {name=M2
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -570 -440 1 1 {name=p11 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -570 -350 3 1 {name=p12 sig_type=std_logic lab=VSS}
C {symbols/pfet_06v0.sym} -700 -80 1 0 {name=M5
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -700 110 1 1 {name=M6
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -700 -30 1 1 {name=p13 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -700 60 3 1 {name=p14 sig_type=std_logic lab=VSS}
C {symbols/pfet_06v0.sym} -570 -80 1 0 {name=M7
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -570 110 1 1 {name=M8
L=1u
W=10u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -570 -30 1 1 {name=p15 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -570 60 3 1 {name=p16 sig_type=std_logic lab=VSS}
C {symbols/pfet_06v0.sym} -780 240 0 0 {name=M9
L=0.65u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_06v0
spiceprefix=X
}
C {symbols/nfet_06v0.sym} -780 360 0 0 {name=M10
L=0.7u
W=2u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_06v0
spiceprefix=X
}
C {devices/lab_pin.sym} -760 200 3 1 {name=p17 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -760 400 1 1 {name=p18 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -640 -400 1 1 {name=p19 sig_type=std_logic lab=WAVE1}
C {devices/lab_pin.sym} -630 10 1 1 {name=p20 sig_type=std_logic lab=WAVE2}
C {devices/lab_pin.sym} -250 140 2 1 {name=p21 sig_type=std_logic lab=WAVE1}
C {symbols/ppolyf_u_1k_6p0.sym} -200 140 1 1 {name=R2
W=1e-6
L=1.6e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {opin.sym} 230 0 0 0 {name=p23 lab=COMBINED}
C {ipin.sym} -860 -640 0 0 {name=p25 lab=VDD}
C {ipin.sym} -860 -610 0 0 {name=p26 lab=VSS}
C {devices/lab_pin.sym} -830 -640 0 1 {name=p27 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -830 -610 0 1 {name=p28 sig_type=std_logic lab=VSS}
C {/foss/designs/Analog/R2R_DAC/xschem/opamp_slim.sym} 170 0 0 0 {name=x1}
C {devices/lab_pin.sym} -200 170 1 1 {name=p22 sig_type=std_logic lab=VSS}
C {symbols/ppolyf_u_1k_6p0.sym} -90 -50 2 1 {name=R1
W=1e-6
L=1e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {symbols/ppolyf_u_1k_6p0.sym} -90 20 2 1 {name=R3
W=1e-6
L=1e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} -90 60 1 1 {name=p3 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -90 -90 3 1 {name=p24 sig_type=std_logic lab=VDD}
C {symbols/ppolyf_u_1k_6p0.sym} 160 110 1 1 {name=R4
W=1e-6
L=2e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 160 140 1 1 {name=p29 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -250 320 2 1 {name=p30 sig_type=std_logic lab=WAVE2}
C {symbols/ppolyf_u_1k_6p0.sym} -200 320 1 1 {name=R5
W=1e-6
L=3.4e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} -200 350 1 1 {name=p31 sig_type=std_logic lab=VSS}
C {symbols/ppolyf_u_1k_6p0.sym} -40 140 1 1 {name=R6
W=1e-6
L=5e-6
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} -40 170 1 1 {name=p32 sig_type=std_logic lab=VSS}
