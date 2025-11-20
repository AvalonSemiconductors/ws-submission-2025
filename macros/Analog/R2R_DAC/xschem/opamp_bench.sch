v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 620 -160 1210 300 {flags=graph
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-3.2125458e-09
x2=8.6527282e-07
divx=5
subdivx=1

unitx=1
dataset=-1
color="7 12"
node="INWAVE
OUT"
y1=0
y2=5}
N 0 70 0 80 {lab=GND}
N 0 -80 -0 10 {lab=#net1}
N -0 -80 240 -80 {lab=#net1}
N 240 -80 240 -70 {lab=#net1}
N 240 70 240 80 {lab=GND}
N 340 -0 400 0 {lab=OUT}
N 400 0 400 130 {lab=OUT}
N 250 130 400 130 {lab=OUT}
N 190 10 190 130 {lab=MINUS}
N 190 10 200 10 {lab=MINUS}
N -100 70 -100 80 {lab=GND}
N -100 -10 200 -10 {lab=PLUS}
N -100 -10 -100 10 {lab=PLUS}
N 160 130 190 130 {lab=MINUS}
N 130 -30 130 -10 {lab=PLUS}
N 100 130 100 180 {lab=INWAVE}
N 20 220 20 230 {lab=GND}
N 20 160 100 160 {lab=INWAVE}
N 320 170 350 170 {lab=GND}
N 350 170 350 190 {lab=GND}
N 350 190 370 190 {lab=GND}
N 270 50 290 50 {lab=#net2}
N 290 50 290 190 {lab=#net2}
N 400 70 450 70 {lab=OUT}
N 510 70 540 70 {lab=GND}
N 130 110 220 110 {lab=GND}
N 220 80 220 110 {lab=GND}
N 220 80 240 80 {lab=GND}
C {vsource.sym} 0 40 0 0 {name=V1 value=5 savecurrent=false}
C {gnd.sym} 0 80 0 0 {name=l15 lab=GND}
C {gnd.sym} 240 80 0 0 {name=l1 lab=GND}
C {vsource.sym} -100 40 0 0 {name=V2 value=2.5 savecurrent=false}
C {gnd.sym} -100 80 0 0 {name=l2 lab=GND
value=2.5}
C {devices/code_shown.sym} -1030 -150 0 0 {name=NGSPICE only_toplevel=true
value="
.option method=gear
.include /foss/designs/Analog/R2R_DAC/xschem/opamp_chonky_spice.spice
.control
save all
tran 1n 1u
remzerovec
write opamp_bench.raw
.endc
"}
C {devices/code_shown.sym} -1040 80 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include /foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical
.lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice res_typical
"}
C {devices/launcher.sym} -35 335 0 0 {name=h1
descr="Click left mouse button here with control key
pressed to load/unload waveforms in graph."
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw
"
}
C {lab_pin.sym} 130 -30 0 0 {name=p1 sig_type=std_logic lab=PLUS}
C {lab_pin.sym} 190 30 0 0 {name=p2 sig_type=std_logic lab=MINUS}
C {lab_pin.sym} 400 0 2 0 {name=p3 sig_type=std_logic lab=OUT}
C {lab_pin.sym} 100 180 2 0 {name=p4 sig_type=std_logic lab=INWAVE}
C {vsource.sym} 20 190 0 0 {name=V3 value="SIN(2.5 2.5 2000000)" savecurrent=false}
C {gnd.sym} 20 230 0 0 {name=l3 lab=GND}
C {symbols/ppolyf_u_1k_6p0.sym} 320 190 1 0 {name=R22
W=1e-6
L=2e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {gnd.sym} 370 190 0 0 {name=l4 lab=GND}
C {res.sym} 480 70 1 0 {name=R3
value=1k
footprint=1206
device=resistor
m=1}
C {gnd.sym} 540 70 0 0 {name=l5 lab=GND}
C {symbols/ppolyf_u_1k_6p0.sym} 220 130 1 0 {name=R1
W=1e-6
L=1e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {symbols/ppolyf_u_1k_6p0.sym} 130 130 1 0 {name=R2
W=1e-6
L=1e-5
model=ppolyf_u_1k_6p0
spiceprefix=X
m=1}
C {opamp_chonky_spice.sym} 350 0 0 0 {name=x1}
