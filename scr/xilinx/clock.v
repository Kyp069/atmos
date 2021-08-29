//-------------------------------------------------------------------------------------------------
module clock
//-------------------------------------------------------------------------------------------------
(
	input  wire i50,   // 50 MHz
	output wire o24,   // 24 MHz
	output wire o8,    //  8 MHz
	output wire locked
);
//-------------------------------------------------------------------------------------------------

wire ci;

IBUFG IBufg(.I(i50), .O(ci));

wire fb;
wire c0;
wire c1;

PLL_BASE #
(
	.CLKIN_PERIOD      (20.000),
	.CLKFBOUT_MULT     (12    ),
	.DIVCLK_DIVIDE     ( 1    ),
	.CLKOUT0_DIVIDE    (25    ),
	.CLKOUT1_DIVIDE    (75    )
)
PLL
(
.RST                   (1'b0),
.CLKIN                 (ci),
.CLKFBIN               (fb),
.CLKFBOUT              (fb),
.CLKOUT0               (c0),
.CLKOUT1               (c1),
.CLKOUT2               (),
.CLKOUT3               (),
.CLKOUT4               (),
.CLKOUT5               (),
.LOCKED                (locked)
);

BUFG Bufg24(.I(c0), .O(o24));
BUFG Bufg8(.I(c1), .O(o8));

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
