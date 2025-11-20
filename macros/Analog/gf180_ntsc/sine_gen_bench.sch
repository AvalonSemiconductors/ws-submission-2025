v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 1020 340 1610 800 {flags=graph
y1=-0.001
y2=5
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=2.1054073e-06
x2=2.8318012e-06
divx=5
subdivx=1



unitx=1
dataset=-1


color="4 10"
node="v(SINE90)
v(SINE270)"
digital=0}
B 2 1640 340 2230 800 {flags=graph
y1=-0.001
y2=5
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=2.1054073e-06
x2=2.8318012e-06
divx=5
subdivx=1



unitx=1
dataset=-1


color="4 10"
node="v(SINE0)
v(SINE180)"
digital=0}
B 2 400 340 990 800 {flags=graph
y1=-0.001
y2=5
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=2.1054073e-06
x2=2.8318012e-06
divx=5
subdivx=1



unitx=1
dataset=-1


color="4 10"
node="v(CLK)
v(CLK90)"
digital=0}
B 2 1640 810 2230 1270 {flags=graph
y1=-0.001
y2=5
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=2.1054073e-06
x2=2.8318012e-06
divx=5
subdivx=1



unitx=1
dataset=-1


color=4
node=v(COMBINED)
digital=0}
N -220 -40 -220 -30 {lab=GND}
N -220 -30 -220 -20 {lab=GND}
N -370 -40 -370 -30 {lab=GND}
N -370 -30 -370 -20 {lab=GND}
N -490 -40 -490 -30 {lab=GND}
N -490 -30 -490 -20 {lab=GND}
N -490 -240 -190 -240 {lab=#net1}
N -490 -240 -490 -100 {lab=#net1}
N -370 -220 -190 -220 {lab=#net2}
N -370 -220 -370 -100 {lab=#net2}
N -290 -200 -190 -200 {lab=GND}
N -290 -200 -290 -170 {lab=GND}
N -220 -180 -220 -100 {lab=CLK}
N -220 -180 -190 -180 {lab=CLK}
N 110 -240 140 -240 {lab=SINE0}
N 110 -220 140 -220 {lab=SINE180}
N 110 -370 140 -370 {lab=SINE90}
N 110 -350 140 -350 {lab=SINE270}
N -220 -330 -190 -330 {lab=GND}
N -370 -350 -370 -220 {lab=#net2}
N -370 -350 -190 -350 {lab=#net2}
N -490 -370 -490 -240 {lab=#net1}
N -490 -370 -190 -370 {lab=#net1}
N -760 -40 -760 -30 {lab=GND}
N -760 -30 -760 -20 {lab=GND}
N -760 -310 -190 -310 {lab=CLK90}
N -760 -310 -760 -100 {lab=CLK90}
N -370 -600 -370 -350 {lab=#net2}
N -370 -600 -190 -600 {lab=#net2}
N -230 -580 -190 -580 {lab=GND}
N -240 -500 -190 -500 {lab=SINE90}
N -240 -520 -190 -520 {lab=SINE270}
N -240 -540 -190 -540 {lab=SINE0}
N -260 -560 -190 -560 {lab=SINE180}
N -220 -460 -190 -460 {lab=GND}
N -190 -480 -190 -460 {lab=GND}
N 110 -600 140 -600 {lab=COMBINED}
C {devices/code_shown.sym} -600 180 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/smbb000149.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice res_typical
.param mim_corner_1p5fF=1
.param mim_corner_1p0fF=1
.param mim_corner_2p0fF=1

.param mc_c_cox_1p0fF=0
.param mc_c_cox_1p5fF=0
.param mc_c_cox_2p0fF=0
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice cap_mim
"}
C {devices/code_shown.sym} -610 510 0 0 {name=NGSPICE only_toplevel=true
value="
.control
save all
tran 0.1n 2800n
write sine_gen_bench.raw
.endc
"}
C {devices/launcher.sym} 1135 855 0 0 {name=h1
descr="Click left mouse button here with control key
pressed to load/unload waveforms in graph."
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw
"
}
C {devices/vsource.sym} -220 -70 0 0 {name=V1 value="PULSE(0 5 2ns 0.2ns 0.2ns 139.682ns 279.365ns)"}
C {devices/gnd.sym} -220 -20 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} -370 -70 0 0 {name=V2 value="5"}
C {devices/gnd.sym} -370 -20 0 0 {name=l3 lab=GND}
C {devices/vsource.sym} -490 -70 0 0 {name=V3 value="2.5"}
C {devices/gnd.sym} -490 -20 0 0 {name=l4 lab=GND}
C {sine_gen.sym} -40 -210 0 0 {name=x1}
C {devices/gnd.sym} -290 -170 0 0 {name=l2 lab=GND}
C {devices/lab_pin.sym} 140 -240 0 1 {name=p15 sig_type=std_logic lab=SINE0}
C {devices/lab_pin.sym} 140 -220 0 1 {name=p1 sig_type=std_logic lab=SINE180}
C {devices/lab_pin.sym} -220 -140 0 1 {name=p2 sig_type=std_logic lab=CLK}
C {sine_mixer.sym} -40 -540 0 0 {name=x2}
C {sine_gen.sym} -40 -340 0 0 {name=x3}
C {devices/lab_pin.sym} 140 -370 0 1 {name=p3 sig_type=std_logic lab=SINE90}
C {devices/lab_pin.sym} 140 -350 0 1 {name=p4 sig_type=std_logic lab=SINE270}
C {devices/gnd.sym} -220 -330 1 0 {name=l5 lab=GND}
C {devices/vsource.sym} -760 -70 0 0 {name=V4 value="PULSE(0 5 71.841ns 0.2ns 0.2ns 139.682ns 279.365ns)"}
C {devices/gnd.sym} -760 -20 0 0 {name=l6 lab=GND}
C {devices/gnd.sym} -230 -580 1 0 {name=l7 lab=GND}
C {devices/lab_pin.sym} -240 -500 0 0 {name=p5 sig_type=std_logic lab=SINE90}
C {devices/lab_pin.sym} -240 -520 0 0 {name=p6 sig_type=std_logic lab=SINE270}
C {devices/lab_pin.sym} -240 -540 0 0 {name=p7 sig_type=std_logic lab=SINE0}
C {devices/lab_pin.sym} -260 -560 0 0 {name=p8 sig_type=std_logic lab=SINE180}
C {devices/gnd.sym} -220 -460 1 0 {name=l8 lab=GND}
C {devices/lab_pin.sym} -760 -140 0 1 {name=p9 sig_type=std_logic lab=CLK90}
C {devices/lab_pin.sym} 140 -600 0 1 {name=p10 sig_type=std_logic lab=COMBINED}
