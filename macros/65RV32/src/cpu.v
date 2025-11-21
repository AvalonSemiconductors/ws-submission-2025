`default_nettype none

module cpurv32(
	input PH0IN,
	output PH1OUT,
	output PH2OUT,
	
	input rst_n,
	input RDY,
	input AEC,
	
	input IRQn,
	input NMIn,
	input SOn,
	output SYNC,
	
	output RWn,
	output RWn_oe,
	output [15:0] A_o,
	output A_oe,
	output MLn,
	output VPn,
	
	output [7:0] D_o,
	input [7:0] D_i,
	output D_oe,
	
	input sync_irqs,
	input sync_rdy,
	input rdy_writes,
	input do_latency
);

assign PH1OUT = PH0IN;
assign PH2OUT = !PH0IN;

assign A_oe = AEC;
assign RWn_oe = AEC;

//ISA TODO:
//I
//M
//Zicsr
//Smrnmi
//cycle(h), mcycle(h), minstret(h), mvendorid, marchid, mhartid, mnscratch, mnepc, mncause, mnstatus CSRs
//A, maybe?

// Vectors:
// $FFFA - NMI
// $FFFC - RESET
// $FFFE - IRQ

reg nmi_edge;
wire irq_actual = !(sync_irqs ? irqn_sync : IRQn);
wire nmi_actual = !(sync_irqs ? nmin_sync : NMIn);
wire son_actual = !(sync_irqs ? son_sync : SOn);
wire nmi_edge_detect = nmi_actual && !nmi_edge;

reg rdy_latched;
wire rdy_actual = (sync_rdy ? rdy_latched : RDY) || (!rdy_writes && !RWn);
always @(posedge PH0IN) begin
	rdy_latched <= RDY;
end

reg [4:0] mem_state;
reg [31:0] mem_buffer;
reg [31:0] addr_buffer;

always @(negedge PH0IN) begin
	nmi_edge <= nmi_actual;
	if(!rst_n) begin
		mem_state <= 0;
	end else if(rdy_actual) begin
		if(mem_state) begin
		
		end else begin
		
		end
	end
end

endmodule
