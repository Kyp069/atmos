//-------------------------------------------------------------------------------------------------
module i2s
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	input  wire[15:0] ldata,
	input  wire[15:0] rdata,
	output reg        ck,
	output reg        lr,
	output reg        d
);
//-------------------------------------------------------------------------------------------------

reg[8:0] ce;
always @(posedge clock) ce <= ce+1'd1;

wire ce4 = &ce[3:0];
wire ce5 = &ce[4:0];
wire ce9a = ce[8] & ce[7] & ce[6] &  ce[5] & ce[4] & ce[3] & ce[2] & ce[1] & ce[0];
wire ce9b = ce[8] & ce[7] & ce[6] & ~ce[5] & ce[4] & ce[3] & ce[2] & ce[1] & ce[0];

always @(posedge clock) if(ce4) ck <= ~ck;
always @(posedge clock) if(ce9b) lr <= ~lr;

reg[14:0] sr;
always @(posedge clock) if(ce9a) { d, sr } <= lr ? rdata : ldata; else if(ce5) { d, sr } <= { sr, 1'b0 };

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
