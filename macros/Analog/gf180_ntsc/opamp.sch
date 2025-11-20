v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
F {}
E {}
N -20 -330 30 -330 {lab=#net1}
N -60 -300 -10 -300 {lab=#net1}
N -10 -330 -10 -300 {lab=#net1}
N -70 -330 -60 -330 {lab=VDD}
N -70 -360 -70 -330 {lab=VDD}
N -70 -360 -60 -360 {lab=VDD}
N 70 -330 80 -330 {lab=VDD}
N 80 -360 80 -330 {lab=VDD}
N 70 -360 80 -360 {lab=VDD}
N -60 -410 -60 -360 {lab=VDD}
N -60 -410 70 -410 {lab=VDD}
N 70 -410 70 -360 {lab=VDD}
N -60 -300 -60 -250 {lab=#net1}
N 70 -300 70 -250 {lab=OUT}
N -60 -190 70 -190 {lab=#net2}
N -120 -220 -100 -220 {lab=PLUS}
N 260 -330 270 -330 {lab=VDD}
N 270 -360 270 -330 {lab=VDD}
N 260 -360 270 -360 {lab=VDD}
N 70 -410 260 -410 {lab=VDD}
N 260 -410 260 -360 {lab=VDD}
N 210 -300 260 -300 {lab=OUT}
N 210 -330 210 -300 {lab=OUT}
N 210 -330 220 -330 {lab=OUT}
N 70 -300 210 -300 {lab=OUT}
N -0 -190 0 -160 {lab=#net2}
N -10 -130 -0 -130 {lab=VSS}
N -10 -130 -10 -100 {lab=VSS}
N -10 -100 -0 -100 {lab=VSS}
N -20 -70 -0 -70 {lab=VSS}
N -0 -100 -0 -70 {lab=VSS}
N 260 -300 260 -160 {lab=OUT}
N -0 -70 260 -70 {lab=VSS}
N 260 -100 260 -70 {lab=VSS}
N 260 -130 270 -130 {lab=VSS}
N 270 -130 270 -100 {lab=VSS}
N 260 -100 270 -100 {lab=VSS}
N 260 -230 280 -230 {lab=OUT}
N 40 -130 220 -130 {lab=ADJ}
N 110 -220 130 -220 {lab=MINUS}
N -60 -220 70 -220 {lab=VSS}
N -60 -70 -20 -70 {lab=VSS}
N -30 -220 -30 -70 {lab=VSS}
N 140 -160 140 -130 {lab=ADJ}
C {symbols/pfet_06v0.sym} -40 -330 0 1 {name=M1
L=1u
W=7u
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
C {symbols/pfet_06v0.sym} 50 -330 0 0 {name=M3
L=1u
W=7u
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
C {ipin.sym} -60 -410 0 0 {name=p1 lab=VDD}
C {symbols/nfet_06v0.sym} 90 -220 0 1 {name=M4
L=1u
W=7u
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
C {symbols/nfet_06v0.sym} -80 -220 0 0 {name=M5
L=1u
W=7u
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
C {ipin.sym} -120 -220 0 0 {name=p2 lab=PLUS}
C {symbols/pfet_06v0.sym} 240 -330 0 0 {name=M6
L=1u
W=3u
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
C {symbols/nfet_06v0.sym} 20 -130 0 1 {name=M7
L=1u
W=9.5u
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
C {ipin.sym} -60 -70 0 0 {name=p3 lab=VSS}
C {symbols/nfet_06v0.sym} 240 -130 0 0 {name=M8
L=1u
W=3u
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
C {opin.sym} 280 -230 0 0 {name=p4 lab=OUT}
C {ipin.sym} 130 -220 0 1 {name=p5 lab=MINUS}
C {ipin.sym} 140 -160 0 0 {name=p6 lab=ADJ}
