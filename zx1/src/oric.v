//-------------------------------------------------------------------------------------------------
module oric
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,

	output wire[ 1:0] stdn,
	output wire[ 1:0] sync,
	output wire[ 8:0] rgb,

	output wire       led,

	input  wire       ear,

	output wire       dsgR,
	output wire       dsgL,

	inout  wire       keybCk,
	inout  wire       keybDQ,

	input  wire[ 5:0] jstick,

	output wire       sramWe,
	inout  wire[ 7:0] sramDQ,
	output wire[20:0] sramA,


	output wire       fshCs,
	output wire       fshCk,
	output wire       fshMosi,
	input  wire       fshMiso
);
//-------------------------------------------------------------------------------------------------

wire clock;
wire clock8;
wire locked;

clock Clock
(
	.i50    (clock50), // 50 MHz input
	.o24    (clock  ), // 24 MHz output
	.o8     (clock8 ), //  8 MHz output
	.locked (locked )
);

reg[7:0] rs;
wire power = rs[7];
always @(posedge clock) if(locked) if(!power) rs <= rs+1'd1;

reg[2:0] cc;
always @(negedge clock) if(power) cc <= cc+1'd1;

wire ne12M = power & ~cc[0];
wire ne6M0 = power & ~cc[0] & ~cc[1];
wire pe3M0 = power & ~cc[0] & ~cc[1] &  cc[2];

//-------------------------------------------------------------------------------------------------

wire boot = F11 & (ctrl|alt|bs);

multiboot Multiboot
(
	.clock  (clock8 ),
	.boot   (boot   )
);

//-------------------------------------------------------------------------------------------------

wire strb;
wire[7:0] code;

ps2 PS2
(
	.clock  (clock  ),
	.ce     (ne6M0  ),
	.ps2Ck  (keybCk ),
	.ps2DQ  (keybDQ ),
	.strb   (strb   ),
	.code   (code   )
);

reg make;
reg extd;

reg F1 = 1'b1;
reg F2 = 1'b1;
reg F5 = 1'b1;
reg F10 = 1'b1;
reg F11 = 1'b1;
reg F12 = 1'b1;
reg bs = 1'b1;
reg del = 1'b1;
reg alt = 1'b1;
reg ctrl = 1'b1;
reg slck = 1'b1;

always @(posedge clock) if(ne6M0)
if(strb)
	if(code == 8'hF0) make <= 1'b1;
	else
	if(code == 8'hE0) extd <= 1'b1;
	else
	begin
		make <= 1'b0;
		extd <= 1'b0;

		case(code)
			8'h05: F1 <= make;
			8'h06: F2 <= make;
			8'h03: F5 <= make;
			8'h09: F10 <= make;
			8'h78: F11 <= make;
			8'h07: F12 <= make;
			8'h66: bs  <= make;
			8'h71: del <= make;
			8'h11: alt <= make;
			8'h14: ctrl <= make;
			8'h7E: slck <= make;
		endcase
	end

reg F1d, F1p;
always @(posedge clock)  if(ne6M0) begin F1d <= F1; F1p = !F1 && F1d; end

reg F2d, F2p;
always @(posedge clock)  if(ne6M0) begin F2d <= F2; F2p = !F2 && F2d; end

reg rom;
always @(posedge clock)  if(ne6M0) if(F1p) rom <= 1'b0; else if(F2p) rom <= 1'b1;

wire reset = power & F12 & (ctrl|alt|del) & ~F1p & ~F2p;
wire nmi = F5;

//-------------------------------------------------------------------------------------------------

wire tapein = ~ear;
wire tapeout;

wire hs;
wire vs;
wire r;
wire g;
wire b;

wire[ 8:0] laudio;
wire[ 8:0] raudio;

wire[15:0] ramA;
wire[ 7:0] ramD;
wire[ 7:0] ramQ = sramDQ;

wire[ 7:0] ioD;
wire[ 7:0] ioQ;
wire[15:0] ioA;

main Main
(
	.clock  (clock  ),
	.power  (power  ),
	.reset  (reset  ),
	.nmi    (nmi    ),
	.rom    (rom    ),

	.strb   (strb   ),
	.code   (code   ),
	.make   (make   ),
	.extd   (extd   ),

	.jstick (jstick ),

	.tapein (tapein ),
	.tapeout(tapeout),

	.laudio (laudio ),
	.raudio (raudio ),

	.hs     (hs     ),
	.vs     (vs     ),
	.r      (r      ),
	.g      (g      ),
	.b      (b      ),

	.ramWe  (ramWe  ),
	.ramA   (ramA   ),
	.ramD   (ramD   ),
	.ramQ   (ramQ   )
);

//-------------------------------------------------------------------------------------------------

assign sramWe = ~ramWe;
assign sramDQ = ~ramWe ? 8'bZ : ramD;
assign sramA = { 5'd0, ramA };

//-------------------------------------------------------------------------------------------------

reg save, F10d, F10p;
always @(posedge clock) if(ne6M0)
begin
	F10d <= F10;
	F10p <= !F10 && F10d;
	if(F10p) save <= ~save;
end

wire[9:0] lmix = { 1'd0, laudio } + { 8'd0, {2{tapein}} } + { 2'd0, {8{save&tapeout}} };
wire[9:0] rmix = { 1'd0, raudio } + { 8'd0, {2{tapein}} } + { 2'd0, {8{save&tapeout}} };

dac #(.MSBI(9)) LDac
(
	.clock  (clock  ),
	.reset  (reset  ),
	.d      (lmix   ),
	.q      (dsgL   )
);

dac #(.MSBI(9)) RDac
(
	.clock  (clock  ),
	.reset  (reset  ),
	.d      (rmix   ),
	.q      (dsgR   )
);

//-------------------------------------------------------------------------------------------------

flash Flash
(
	.clock  (clock  ),
	.pe1x   (pe3M0  ),
	.ne2x   (ne6M0  ),
	.fshVga (fshVga ),
	.fshCs  (fshCs  ),
	.fshCk  (fshCk  ),
	.fshDo  (fshMosi),
	.fshDi  (fshMiso)
);

//-------------------------------------------------------------------------------------------------

reg vga;
reg slckd;

always @(posedge clock) if(pe3M0)
begin
	slckd <= slck;
	if(!fshCs) vga <= fshVga; else if(!slck && slckd) vga <= ~vga;
end

//-------------------------------------------------------------------------------------------------

wire ohs;
wire ovs;

wire[8:0] irgb = { {3{r}}, {3{g}}, {3{b}} };
wire[8:0] orgb;

scandoubler #(.RGBW(9)) Scandoubler
(
	.clock  (clock  ),
	.ice    (ne6M0  ),
	.ihs    (~hs    ),
	.ivs    (~vs    ),
	.irgb   (irgb   ),
	.oce    (ne12M  ),
	.ohs    (ohs    ),
	.ovs    (ovs    ),
	.orgb   (orgb   )
);

//-------------------------------------------------------------------------------------------------

assign stdn = 2'b01;
assign sync = vga ? { ovs, ohs } : { 1'b1, ~(hs^vs) };
assign rgb = vga ? orgb : irgb;

assign led = rom^tapein;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
