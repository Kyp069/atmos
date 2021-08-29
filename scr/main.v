//-------------------------------------------------------------------------------------------------
module main
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	input  wire       power,
	input  wire       reset,
	input  wire       nmi,
	input  wire       rom,

	input  wire       strb,
	input  wire       make,
	input  wire       extd,
	input  wire[ 7:0] code,

	input  wire[ 5:0] jstick,

	input  wire       tapein,
	output wire       tapeout,

	output wire[ 8:0] laudio,
	output wire[ 8:0] raudio,

	output wire       hs,
	output wire       vs,
	output wire       r,
	output wire       g,
	output wire       b,

	output wire       ramWe,
	output wire[15:0] ramA,
	output wire[ 7:0] ramD,
	input  wire[ 7:0] ramQ
);
//-------------------------------------------------------------------------------------------------

wire ce1M;

wire irq;
wire rw;

reg [ 7:0] d;
wire[ 7:0] q;
wire[23:0] a;

T65 Cpu
(
	.Mode       (2'b00   ),
	.Res_n      (reset   ),
	.Clk        (clock   ),
	.Enable     (ce1M    ),
	.Rdy        (1'b1    ),
	.Abort_n    (1'b1    ),
	.IRQ_n      (irq     ),
	.NMI_n      (nmi     ),
	.SO_n       (1'b1    ),
	.R_W_n      (rw      ),
	.DI         (d       ),
	.DO         (q       ),
	.A          (a       )
);

//-------------------------------------------------------------------------------------------------

wire[ 7:0] romQ0;
wire[ 7:0] romQ1;
wire[13:0] romA = a[13:0];

rom #(.KB(16), .FN("basic11.hex")) Rom0
(
	.clock  (clock  ),
	.ce     (1'b1   ),
	.q      (romQ0  ),
	.a      (romA   )
);

wire[13:0] rom1A = a[13:0];

rom #(.KB(16), .FN("basic122.hex")) Rom1
(
	.clock  (clock  ),
	.ce     (1'b1   ),
	.q      (romQ1  ),
	.a      (romA   )
);

//-------------------------------------------------------------------------------------------------

assign ramA  = !ula_phi2 ? ula_AD_SRAM : a[15:0];
assign ramD  = q;
assign ramWe = !reset ? 1'b0 : ula_WE_SRAM;

//-------------------------------------------------------------------------------------------------

wire ula_phi2;
wire ula_WE_SRAM;
wire ula_CLK_4;
wire ula_CLK_4_en;
wire ula_LATCH_SRAM;
wire ula_CSIOn;
wire ula_CSROMn;
wire ula_CSRAMn;

wire[15:0] ula_AD_SRAM;
wire[15:0] ulaA = a[15:0];

ula ULA
(
	.RESETn    (power         ),
	.CLK       (clock         ),
	.PHI2      (ula_phi2      ),
	.PHI2_EN   (ce1M          ),
	.CLK_4     (ula_CLK_4     ),
	.CLK_4_EN  (ula_CLK_4_en  ),
	.RW        (rw            ),
	.MAPn      (1'b1          ),
	.DB        (ramQ          ),
	.ADDR      (ulaA          ),
	.SRAM_AD   (ula_AD_SRAM   ),
	.SRAM_OE   (              ),
	.SRAM_CE   (              ),
	.SRAM_WE   (ula_WE_SRAM   ),
	.LATCH_SRAM(ula_LATCH_SRAM),
	.CSIOn     (ula_CSIOn     ),
	.CSROMn    (ula_CSROMn    ),
	.CSRAMn    (ula_CSRAMn    ),
	.HSYNC     (hs            ),
	.VSYNC     (vs            ),
	.R         (r             ),
	.G         (g             ),
	.B         (b             )
);

//-------------------------------------------------------------------------------------------------

wire via_ca2_out;
wire via_cb2_out;
wire via_cb1_out;
wire via_cb1_oe_l;

wire[7:0] via_pa_out_oe_l;
wire[7:0] via_pa_out     ;
wire[7:0] via_pb_oe_l    ;
wire[7:0] via_pb_out     ;
wire[7:0] VIA_DO         ;

wire[7:0] via_pa_in      = (via_pa_out & ~via_pa_out_oe_l) | (psgQ & via_pa_out_oe_l);

wire[7:0] via_pb_in      = { via_pb_out[7:6], 1'bZ, via_pb_out[4], keyHit, via_pb_out[2:0] };

M6522 Via
(
	.RESET_L   (reset             ),
	.CLK       (clock             ),
	.ENA_4     (ula_CLK_4_en      ),
	.I_RS      (a[3:0]            ),
	.I_DATA    (q                 ),
	.O_DATA    (VIA_DO            ),
	.I_RW_L    (rw                ),
	.I_CS1     (1'b1              ),
	.I_CS2_L   (ula_CSIOn         ),
	.O_IRQ_L   (irq               ),
	.I_CA1     (1'b1              ),
	.I_CA2     (1'b1              ),
	.O_CA2     (via_ca2_out       ),
	.O_CA2_OE_L(                  ),
	.I_PA      (via_pa_in         ),
	.O_PA      (via_pa_out        ),
	.O_PA_OE_L (via_pa_out_oe_l   ),
	.I_CB1     (tapein            ),
	.O_CB1     (via_cb1_out       ),
	.O_CB1_OE_L(via_cb1_oe_l      ),
	.I_CB2     (1'b1              ),
	.O_CB2     (via_cb2_out       ),
	.O_CB2_OE_L(                  ),
	.I_PB      (via_pb_in         ),
	.O_PB      (via_pb_out        ),
	.I_P2_H    (ula_phi2          )
);

//-------------------------------------------------------------------------------------------------

wire[7:0] psgA;
wire[7:0] psgB;
wire[7:0] psgC;

wire[7:0] psgIoA;
wire[7:0] psgQ;

jt49_bus Psg
(
	.rst_n     (reset        ),
	.clk       (clock        ),
	.clk_en    (ce1M         ),
	.sel       (1'b1         ),
	.bc1       (via_ca2_out  ),
	.bdir      (via_cb2_out  ),
	.din       (via_pa_out   ),
	.dout      (psgQ         ),
	.A         (psgA         ),
	.B         (psgB         ),
	.C         (psgC         ),
	.IOA_in    (8'd0         ),
	.IOA_out   (psgIoA       ),
	.IOB_in    (8'd0         ),
	.IOB_out   (             )
);

//-------------------------------------------------------------------------------------------------

wire keyHit;

wire[2:0] row = via_pb_out[2:0];

keyboard Keyboard
(
	.clock  (clock  ),
	.make   (make   ),
	.extd   (extd   ),
	.strb   (strb   ),
	.code   (code   ),
	.jstick (jstick ),
	.row    (row    ),
	.col    (psgIoA ),
	.keyHit (keyHit )
);

//-------------------------------------------------------------------------------------------------

assign tapeout = ~via_pb_out[7];

assign laudio = { 1'b0, psgA } + { 1'b0, psgB };
assign raudio = { 1'b0, psgC } + { 1'b0, psgB };

always @(posedge clock)
	if(rw && ula_phi2 && !ula_CSIOn                    ) d <= VIA_DO; else
	if(rw && ula_phi2 &&  ula_CSIOn  && !ula_CSROMn    ) d <= rom ? romQ1 : romQ0 ; else
	if(rw && ula_phi2 && !ula_CSRAMn && !ula_LATCH_SRAM) d <= ramQ  ;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
