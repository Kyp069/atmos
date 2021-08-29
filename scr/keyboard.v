module keyboard
(
	input  wire      clock,
	input  wire      make,   // 1-make (pressed), 0-break (released)
	input  wire      extd,   // extended code
	input  wire      strb,   // strobe
	input  wire[7:0] code,   // key scan code
	input  wire[5:0] jstick, // joystick
	input  wire[2:0] row,
	input  wire[7:0] col,
	output wire      keyHit
);

reg sw0 = 1'b1;
reg sw1 = 1'b1;
reg sw2 = 1'b1;
reg sw3 = 1'b1;
reg sw4 = 1'b1;
reg sw5 = 1'b1;
reg sw6 = 1'b1;
reg sw7 = 1'b1;
reg sw8 = 1'b1;
reg sw9 = 1'b1;

reg swa = 1'b1;
reg swb = 1'b1;
reg swc = 1'b1;
reg swd = 1'b1;
reg swe = 1'b1;
reg swf = 1'b1;
reg swg = 1'b1;
reg swh = 1'b1;
reg swi = 1'b1;
reg swj = 1'b1;
reg swk = 1'b1;
reg swl = 1'b1;
reg swm = 1'b1;
reg swn = 1'b1;
reg swo = 1'b1;
reg swp = 1'b1;
reg swq = 1'b1;
reg swr = 1'b1;
reg sws = 1'b1;
reg swt = 1'b1;
reg swu = 1'b1;
reg swv = 1'b1;
reg sww = 1'b1;
reg swx = 1'b1;
reg swy = 1'b1;
reg swz = 1'b1;

reg swU = 1'b1; // up
reg swD = 1'b1; // down
reg swL = 1'b1; // left
reg swR = 1'b1; // right

reg swrs  = 1'b1; // right shift
reg swls  = 1'b1; // left shift
reg swsp  = 1'b1; // space
reg swcom = 1'b1; // ,
reg swdot = 1'b1; // .
reg swret = 1'b1; // return
reg swfs  = 1'b1; // forward slash
reg sweq  = 1'b1; // =
reg swdel = 1'b1; // delete
reg swrsb = 1'b1; // ]
reg swlsb = 1'b1; // [
reg swbs  = 1'b1; // back slash
reg swdsh = 1'b1; // -
reg swsq  = 1'b1; // '
reg swsc  = 1'b1; // ;
reg swesc = 1'b1; // escape
reg swctl = 1'b1; // left ctrl
reg swctr = 1'b1; // right ctrl

reg swf1 = 1'b1;
reg swf2 = 1'b1;
reg swf3 = 1'b1;
reg swf4 = 1'b1;
reg swf5 = 1'b1;
reg swf6 = 1'b1;

reg lwin = 1'b1;
reg lalt = 1'b1;
reg ralt = 1'b1;
reg rwin = 1'b1;
reg menu = 1'b1;

always @(posedge clock)
if(strb)
	if(extd)
		case(code)
			8'h1F: lwin  <= make; // lwin
			8'h11: ralt  <= make; // ralt
			8'h27: rwin  <= make; // rwin
			8'h2f: menu  <= make; // menu
			8'h75: swU   <= make; // up
			8'h72: swD   <= make; // down
			8'h6b: swL   <= make; // left
			8'h74: swR   <= make; // right
			8'h71: swdel <= make; // delete
			8'h14: swctr <= make; // right control
		endcase
	else
		case(code)
			8'h11: lalt  <= make; // lalt

			8'h45: sw0   <= make; // 0
			8'h16: sw1   <= make; // 1
			8'h1e: sw2   <= make; // 2
			8'h26: sw3   <= make; // 3
			8'h25: sw4   <= make; // 4
			8'h2e: sw5   <= make; // 5
			8'h36: sw6   <= make; // 6
			8'h3d: sw7   <= make; // 7
			8'h3e: sw8   <= make; // 8
			8'h46: sw9   <= make; // 9

			8'h1c: swa   <= make; // a
			8'h32: swb   <= make; // b
			8'h21: swc   <= make; // c
			8'h23: swd   <= make; // d
			8'h24: swe   <= make; // e
			8'h2b: swf   <= make; // f
			8'h34: swg   <= make; // g
			8'h33: swh   <= make; // h
			8'h43: swi   <= make; // i
			8'h3b: swj   <= make; // j
			8'h42: swk   <= make; // k
			8'h4b: swl   <= make; // l
			8'h3a: swm   <= make; // m
			8'h31: swn   <= make; // n
			8'h44: swo   <= make; // o
			8'h4d: swp   <= make; // p
			8'h15: swq   <= make; // q
			8'h2d: swr   <= make; // r
			8'h1b: sws   <= make; // s
			8'h2c: swt   <= make; // t
			8'h3c: swu   <= make; // u
			8'h2a: swv   <= make; // v
			8'h1d: sww   <= make; // w
			8'h22: swx   <= make; // x
			8'h35: swy   <= make; // y
			8'h1a: swz   <= make; // z

			8'h66: swdel <= make; // delete
			8'h59: swrs  <= make; // right shift
			8'h12: swls  <= make; // left shift
			8'h29: swsp  <= make; // space
			8'h41: swcom <= make; // comma
			8'h49: swdot <= make; // full stop
			8'h5a: swret <= make; // return
			8'h4a: swfs  <= make; // forward slash
			8'h55: sweq  <= make; // equals
			8'h5b: swrsb <= make; // right sq bracket
			8'h54: swlsb <= make; // left sq bracket
			8'h5d: swbs  <= make; // back slash h05d
			8'h4e: swdsh <= make; // dash
			8'h52: swsq  <= make; // single quote
			8'h4c: swsc  <= make; // semi colon
			8'h76: swesc <= make; // escape
			8'h14: swctl <= make; // left control
			8'h05: swf1  <= make; // f1
			8'h06: swf2  <= make; // f2
			8'h04: swf3  <= make; // f3
			8'h0c: swf4  <= make; // f4
			8'h03: swf5  <= make; // f5
			8'h0b: swf6  <= make; // f6
		endcase

reg [7:0] pressed;
always @(posedge clock) begin
	case (row)
		3'b000: pressed <= {sw3,swx,sw1,swf6,swv,sw5,swn,sw7};
		3'b001: pressed <= {swd,swq,swesc,swf5,swf,swr,swt,swj};
		3'b010: pressed <= {swc,sw2,swz,(swctl & swctr),sw4,swb,sw6,swm};
		3'b011: pressed <= {swsq,swbs,swf3,swf4,swdsh,swsc,sw9,swk};
		3'b100: pressed <= {(swR & jstick[0] & menu),(swD & jstick[2] & lalt),(swL & jstick[1] & lwin),swls,(swU & jstick[3] & rwin),swdot,swcom,(swsp & jstick[4])};
		3'b101: pressed <= {swlsb,swrsb,swdel,ralt,swp,swo,swi,swu};
		3'b110: pressed <= {sww,(sws & jstick[5]),swa,swf2,swe,swg,swh,swy};
		3'b111: pressed <= {sweq,swf1,swret,swrs,swfs,sw0,swl,sw8};
	endcase;
end

assign keyHit = (pressed | col) != 8'hFF;

endmodule
