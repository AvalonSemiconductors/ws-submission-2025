v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 280 -90 290 -90 {lab=TRI}
N 180 -180 180 -160 {lab=VDD}
N 290 -90 310 -90 {lab=TRI}
N 90 -100 140 -100 {lab=VGND}
N -20 -80 -10 -80 {lab=#net1}
N 50 -80 140 -80 {lab=#net2}
N 300 -90 300 -40 {lab=TRI}
N 120 -80 120 50 {lab=#net2}
N 120 50 300 50 {lab=#net2}
N 300 20 300 50 {lab=#net2}
N 630 -170 630 -150 {lab=VDD}
N 730 -80 760 -80 {lab=COSINE}
N 760 -80 760 -40 {lab=COSINE}
N 570 -70 590 -70 {lab=#net3}
N 570 -70 570 70 {lab=#net3}
N 570 70 760 70 {lab=#net3}
N 760 20 760 70 {lab=#net3}
N 560 -70 570 -70 {lab=#net3}
N 590 -130 590 -90 {lab=VGND}
N 310 -90 420 -90 {lab=TRI}
N 420 -90 420 -70 {lab=TRI}
N 1060 -160 1060 -130 {lab=VDD}
N 1060 10 1060 20 {lab=VSS}
N 760 -330 760 -80 {lab=COSINE}
N 760 -330 780 -330 {lab=COSINE}
N 1020 -110 1020 -70 {lab=VGND}
N 980 -50 1020 -50 {lab=#net4}
N 980 -50 980 60 {lab=#net4}
N 1040 60 1160 60 {lab=SINE}
N 1160 -60 1160 60 {lab=SINE}
N 920 -80 920 -50 {lab=COSINE}
N 760 -80 920 -80 {lab=COSINE}
N 1160 -60 1180 -60 {lab=SINE}
N 90 -330 130 -330 {lab=ADJ1}
N 130 -260 130 -250 {lab=VSS}
N 180 -20 180 -10 {lab=VSS}
N 630 -10 630 -0 {lab=VSS}
N 210 -40 230 -40 {lab=ADJ1}
N 660 -30 680 -30 {lab=ADJ2}
N 1090 -10 1110 -10 {lab=ADJ3}
N 320 -330 360 -330 {lab=ADJ2}
N 360 -260 360 -250 {lab=VSS}
N 520 -330 560 -330 {lab=ADJ3}
N 560 -260 560 -250 {lab=VSS}
N -350 -80 -300 -80 {lab=CLK}
N -240 -80 -200 -80 {lab=#net1}
N -200 -120 -200 -80 {lab=#net1}
N -270 -150 -270 -100 {lab=VSS}
N -270 -150 -220 -150 {lab=VSS}
N -200 -200 -200 -180 {lab=VGND}
N -200 -80 -20 -80 {lab=#net1}
N -410 -80 -350 -80 {lab=CLK}
N -450 -330 -420 -330 {lab=VDD}
N -450 -360 -420 -360 {lab=VGND}
N -450 -300 -420 -300 {lab=VSS}
N 130 -330 130 -320 {lab=ADJ1}
N 110 -290 110 -260 {lab=VSS}
N 110 -260 130 -260 {lab=VSS}
N 360 -330 360 -320 {lab=ADJ2}
N 340 -290 340 -260 {lab=VSS}
N 340 -260 360 -260 {lab=VSS}
N 560 -330 560 -320 {lab=ADJ3}
N 540 -290 540 -260 {lab=VSS}
N 540 -260 560 -260 {lab=VSS}
N 20 -60 20 -50 {lab=VSS}
N 950 -30 950 -20 {lab=VSS}
N 1010 80 1010 90 {lab=VSS}
N 420 -120 420 -90 {lab=TRI}
N 530 -50 530 -40 {lab=VSS}
N 420 -70 500 -70 {lab=TRI}
C {devices/lab_pin.sym} 180 -180 0 0 {name=p2 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 90 -100 0 0 {name=p7 sig_type=std_logic lab=VGND}
C {symbols/cap_mim_2f0fF.sym} 300 -10 0 0 {name=C2
W=2e-5
L=2e-5
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 630 -170 0 0 {name=p8 sig_type=std_logic lab=VDD}
C {symbols/cap_mim_2f0fF.sym} 760 -10 0 0 {name=C1
W=2e-5
L=2e-5
model=cap_mim_2f0fF
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 590 -130 0 0 {name=p9 sig_type=std_logic lab=VGND}
C {symbols/ppolyf_u_1k_6p0.sym} 530 -70 3 0 {name=R2
W=1e-6
L=4.4e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {symbols/ppolyf_u_1k_6p0.sym} 20 -80 3 0 {name=R1
W=1e-6
L=3.5e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 1060 -160 0 0 {name=p12 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1020 -110 0 0 {name=p13 sig_type=std_logic lab=VGND}
C {symbols/ppolyf_u_1k_6p0.sym} 950 -50 3 0 {name=R3
W=1e-6
L=2e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {symbols/ppolyf_u_1k_6p0.sym} 1010 60 3 0 {name=R4
W=1e-6
L=2e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {symbols/ppolyf_u_1k_6p0.sym} 130 -290 0 0 {name=R6
W=1e-6
L=3e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 90 -330 0 0 {name=p15 sig_type=std_logic lab=ADJ1}
C {devices/lab_pin.sym} 230 -40 3 0 {name=p17 sig_type=std_logic lab=ADJ1}
C {devices/lab_pin.sym} 680 -30 3 0 {name=p18 sig_type=std_logic lab=ADJ2}
C {devices/lab_pin.sym} 1110 -10 3 0 {name=p19 sig_type=std_logic lab=ADJ3}
C {symbols/ppolyf_u_1k_6p0.sym} 360 -290 0 0 {name=R8
W=1e-6
L=1e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 320 -330 0 0 {name=p21 sig_type=std_logic lab=ADJ2}
C {symbols/ppolyf_u_1k_6p0.sym} 560 -290 0 0 {name=R10
W=1e-6
L=1e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} 520 -330 0 0 {name=p23 sig_type=std_logic lab=ADJ3}
C {symbols/ppolyf_u_1k_6p0.sym} -270 -80 1 0 {name=R11
W=1e-6
L=3e-6
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {symbols/ppolyf_u_1k_6p0.sym} -200 -150 2 1 {name=R12
W=1e-6
L=3e-6
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {devices/lab_pin.sym} -270 -150 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -200 -200 0 0 {name=p25 sig_type=std_logic lab=VGND}
C {ipin.sym} -450 -360 0 0 {name=p26 lab=VGND}
C {ipin.sym} -450 -330 0 0 {name=p27 lab=VDD}
C {ipin.sym} -450 -300 0 0 {name=p28 lab=VSS}
C {opin.sym} 780 -330 0 0 {name=p10 lab=COSINE}
C {opin.sym} 1180 -60 0 0 {name=p14 lab=SINE}
C {ipin.sym} -410 -80 0 0 {name=p29 lab=CLK}
C {devices/lab_pin.sym} -420 -300 0 1 {name=p3 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 180 -10 1 1 {name=p6 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 630 0 1 1 {name=p30 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 1060 20 1 1 {name=p31 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 560 -250 1 1 {name=p33 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 360 -250 1 1 {name=p34 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 130 -250 1 1 {name=p35 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -420 -330 0 1 {name=p36 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -420 -360 0 1 {name=p37 sig_type=std_logic lab=VGND}
C {devices/lab_pin.sym} 20 -50 1 1 {name=p1 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 950 -20 1 1 {name=p4 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 1010 90 1 1 {name=p16 sig_type=std_logic lab=VSS}
C {/foss/designs/Analog/R2R_DAC/xschem/opamp_slim.sym} 290 -90 0 0 {name=x1}
C {/foss/designs/Analog/R2R_DAC/xschem/opamp_slim.sym} 740 -80 0 0 {name=x2}
C {/foss/designs/Analog/R2R_DAC/xschem/opamp_slim.sym} 1170 -60 0 0 {name=x4}
C {devices/lab_pin.sym} 420 -120 0 0 {name=p22 sig_type=std_logic lab=TRI}
C {devices/lab_pin.sym} 530 -40 1 1 {name=p38 sig_type=std_logic lab=VSS}
