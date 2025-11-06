`default_nettype none

module pla(
	input FE,
	input A13,
	input A14,
	input A15,
	input VA14n,
	input CHARENn,
	input HIRAMn,
	input LORAMn,
	input CASn,
	output ROMHn,
	output ROMLn,
	output IOn,
	output GRWn,
	//GND
	output CHAROMn,
	output KERNALn,
	output BASICn,
	output CASRAMn,
	input OEn,
	input VA12,
	input VA13,
	input GAMEn,
	input EXROMn,
	input RWn,
	input AECn,
	input BA,
	input A12
	//VCC
);

wire ROMH = (HIRAMn  & A15  & !A14  & A13  & !AECn  & 
               RWn  & !EXROMn  & !GAMEn 
             | A15  & A14  & A13  & !AECn  & EXROMn  & 
               !GAMEn 
             | AECn  & EXROMn  & !GAMEn  & VA13  & VA12 );
assign ROMHn = !ROMH;

wire ROML = (LORAMn  & HIRAMn  & A15  & !A14  & !A13  & 
               !AECn  & RWn  & !EXROMn 
             | A15  & !A14  & !A13  & !AECn  & EXROMn  & 
               !GAMEn );
assign ROMLn = !ROML;

wire IO = (HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & GAMEn 
             | HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & GAMEn 
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & GAMEn 
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & GAMEn 
             | HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & !EXROMn  & 
               !GAMEn 
             | HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & !EXROMn  & !GAMEn 
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & !EXROMn  & 
               !GAMEn 
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & !EXROMn  & !GAMEn 
             | A15  & A14  & !A13  & A12  & BA  & 
               !AECn  & RWn  & EXROMn  & !GAMEn 
             | A15  & A14  & !A13  & A12  & !AECn  & 
               !RWn  & EXROMn  & !GAMEn );
assign IOn = !IO;

wire GRW = (!CASn  & A15  & A14  & !A13  & A12  & 
               !AECn  & !RWn );
assign GRWn = !GRW;

wire CHAROM = (HIRAMn  & !CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & RWn  & GAMEn 
             | LORAMn  & !CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & RWn  & GAMEn 
             | HIRAMn  & !CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & RWn  & !EXROMn  & !GAMEn 
             | VA14n  & AECn  & GAMEn  & !VA13  & VA12 
             | VA14n  & AECn  & !EXROMn  & !GAMEn  & !VA13  & 
               VA12 );
assign CHAROMn = !CHAROM;

wire KERNAL = (HIRAMn  & A15  & A14  & A13  & !AECn  & 
               RWn  & GAMEn 
             | HIRAMn  & A15  & A14  & A13  & !AECn  & 
               RWn  & !EXROMn  & !GAMEn );
assign KERNALn = !KERNAL;

wire BASIC = (LORAMn  & HIRAMn  & A15  & !A14  & A13  & 
               !AECn  & RWn  & GAMEn );
assign BASICn = !BASIC;

wire CASRAM = !(LORAMn  & HIRAMn  & A15  & !A14  & A13  & 
               !AECn  & RWn  & GAMEn 
             | HIRAMn  & A15  & A14  & A13  & !AECn  & 
               RWn  & GAMEn 
             | HIRAMn  & A15  & A14  & A13  & !AECn  & 
               RWn & !EXROMn & !GAMEn
             | HIRAMn  & !CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & RWn  & GAMEn 
             | LORAMn  & !CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & RWn  & GAMEn 
             | HIRAMn  & !CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & RWn  & !EXROMn  & !GAMEn 
             | VA14n  & AECn  & GAMEn  & !VA13  & VA12 
             | VA14n  & AECn  & !EXROMn  & !GAMEn  & !VA13  & 
               VA12 
             | HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & GAMEn 
             | HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & GAMEn 
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & GAMEn 
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & GAMEn 
             | HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & !EXROMn  & 
               !GAMEn
             | HIRAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & !EXROMn  & !GAMEn 
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & BA  & !AECn  & RWn  & !EXROMn  & 
               !GAMEn
             | LORAMn  & CHARENn  & A15  & A14  & !A13  & 
               A12  & !AECn  & !RWn  & !EXROMn  & !GAMEn 
             | A15  & A14  & !A13  & A12  & BA  & 
               !AECn  & RWn  & EXROMn  & !GAMEn 
             | A15  & A14  & !A13  & A12  & !AECn  & 
               !RWn  & EXROMn  & !GAMEn 
             | LORAMn  & HIRAMn  & A15  & !A14  & !A13  & 
               !AECn  & RWn  & !EXROMn 
             | A15  & !A14  & !A13  & !AECn  & EXROMn  & 
               !GAMEn 
             | HIRAMn  & A15  & !A14  & A13  & !AECn  & 
               RWn  & !EXROMn  & !GAMEn
             | A15  & A14  & A13  & !AECn  & EXROMn  & 
               !GAMEn 
             | AECn  & EXROMn  & !GAMEn  & VA13  & VA12 
             | !A15  & !A14  & A12  & EXROMn  & !GAMEn 
             | !A15  & !A14  & A13  & EXROMn  & !GAMEn 
             | !A15  & A14  & EXROMn  & !GAMEn 
             | A15  & !A14  & A13  & EXROMn  & !GAMEn 
             | A15  & A14  & !A13  & !A12  & EXROMn  & 
               !GAMEn
             | CASn );
assign CASRAMn = !CASRAM;

endmodule
