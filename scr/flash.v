//-------------------------------------------------------------------------------------------------
module flash
//-------------------------------------------------------------------------------------------------
(
	input  wire clock,
	input  wire pe1x,
	input  wire ne2x,

	output reg  fshVga,
	output reg  fshCs,
	output wire fshCk,
	output wire fshDo,
	input  wire fshDi
);
//-------------------------------------------------------------------------------------------------

reg fshTx;
reg fshRx;

reg[7:0] fshD;
reg[7:0] fc;

always @(posedge clock) if(pe1x)
if(!fc[7])
begin
	fc <= fc+1'd1;
	case(fc)
		 0: fshCs <= 1'b1;
		14: fshCs <= 1'b0;

//		 0: begin fshTx <= 1'b1; fshD <= 8'h13; end
//		 1: begin fshTx <= 1'b0; end

		16: begin fshTx <= 1'b1; fshD <= 8'h03; end
		17: begin fshTx <= 1'b0; end

		32: begin fshTx <= 1'b1; fshD <= 8'h00; end
		33: begin fshTx <= 1'b0; end

		48: begin fshTx <= 1'b1; fshD <= 8'h70; end
		49: begin fshTx <= 1'b0; end

		64: begin fshTx <= 1'b1; fshD <= 8'h4D; end
		65: begin fshTx <= 1'b0; end

		80: fshRx <= 1'b1;
		81: fshRx <= 1'b0;

		96: fshRx <= 1'b1;
		97: fshRx <= 1'b0;

		98: fshVga <= fshQ[1:0] == 2'b10;
		99: fshCs <= 1'b1;
	endcase
end

wire[7:0] fshQ;

spi #(.QW(8)) Flash
(
	.clock  (clock  ),
	.ce     (ne2x   ),
	.tx     (fshTx  ),
	.rx     (fshRx  ),
	.d      (fshD   ),
	.q      (fshQ   ),
	.ck     (fshCk  ),
	.mosi   (fshDo  ),
	.miso   (fshDi  )
);

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
