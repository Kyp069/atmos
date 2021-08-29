//-------------------------------------------------------------------------------------------------
module joystick
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	input  wire       reset,
	input  wire       hsync,

	output wire[ 7:0] joy,

	output wire       joySl,
	output wire       joyCk,
	output wire       joyLd,
	input  wire       joyD
);
//-------------------------------------------------------------------------------------------------

wire[11:0] joy1;
wire[11:0] joy2;

joydecoder Joystick
(
	.clk       (clock  ),
	.reset     (~reset ),
	.hsync_n_s (hsync  ),
	.joy_clk   (joyCk  ),
	.joy_data  (joyD   ),
	.joy_load_n(joyLd  ),
	.joy1_o    (joy1   ), // -- MXYZ SACB RLDU  Negative Logic
	.joy2_o    (joy2   )  // -- MXYZ SACB RLDU  Negative Logic
  );
//-------------------------------------------------------------------------------------------------

assign joy = ~{ joy1[7:4], joy1[0], joy1[1], joy1[2], joy1[3] } | ~{ joy2[7:4], joy2[0], joy2[1], joy2[2], joy2[3] };
assign joySl = hsync;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
