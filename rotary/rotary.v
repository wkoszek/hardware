`define	FREQ	50*1000*1000

module rotary(clk_i, rot_i, strobe_o, dir_o, button_o);
	input wire		clk_i;
	input wire [2:0]	rot_i;

	output wire		strobe_o;
	output wire		dir_o;
	output wire [1:0]	button_o;

	wire [2:0] rot;
	wire [1:0] knob;

	debouncer #(
		.DEBOUNCER_DELAY(`FREQ/6)
	) debouncer0 (
		.clk_i(clk_i),
		.d_i(rot_i[0]),
		.d_o(rot[0])
	);

	debouncer #(
		.DEBOUNCER_DELAY(`FREQ/6)
	) debouncer1 (
		.clk_i(clk_i),
		.d_i(rot_i[1]),
		.d_o(rot[1])
	);

	reg strobe;
	reg dir;

	initial begin
		strobe <= 0;
		dir <= 0;
	end

	wire has_signal;
	assign has_signal = rot[0] | rot[1];

	always @(posedge clk_i or posedge has_signal) begin
		if (has_signal) begin
			strobe <= ~strobe;
			dir <= ~dir;
		end
	end

	assign	button_o[1:0] = { rot[1], rot[0] };

	assign strobe_o = strobe;
	assign dir_o = dir;

`ifdef ZERO
	debouncer #(
		.DEBOUNCER_DELAY(`FREQ/10)
	) debouncer2 (
		.clk_i(clk_i),
		.d_i(rot_i[2]),
		.d_o(button_o)
	);
	assign rot[2] = 0;
	assign knob = rot[1:0];

	reg	[1:0]	st_curr;
	reg	[1:0]	st_prev;

	initial begin
		st_curr <= 0;
		st_prev <= 0;
	end

	assign button_o = knob;

	always @(posedge clk_i) begin
		st_prev <= st_curr;
		st_curr <= knob;
		case (knob)
		2'b01:
			begin
				if (st_prev == 2'b10) begin
					strobe_o <= 1;
					dir_o <= 1'b1;
				end
			end
		2'b10:
			begin
				if (st_prev == 2'b01) begin
					strobe_o <= 1;
					dir_o <= 1'b0;
				end
			end
		default:
			begin
				strobe_o <= 0;
				dir_o <= 0;
			end
		endcase
	end
`endif
endmodule

module main(clk_i, button_i, rot_i, led_o);
	input wire		clk_i;
	input wire		button_i;
	input wire [2:0]	rot_i;
	output wire [7:0]	led_o;

	integer i = 0;

	wire		reset;
	wire		strobe;
	wire		dir;
	wire [7:0]	led;

	debouncer #(
		.DEBOUNCER_DELAY(`FREQ/12)
	) debouncer0 (
		.clk_i(clk_i),
		.d_i(button_i),
		.d_o(reset)
	);

	ruler #(
		.RULER_WIDTH(8)
	) ruler0 (
		.clk_i(clk_i),
		.rst_i(reset),
		.stb_i(strobe),
		.dir_i(dir),
		.ruler_o(led)
	);

	rotary rotary0(
		.clk_i(clk_i),
		.rot_i(rot_i),
		.strobe_o(strobe),
		.dir_o(dir),
		.button_o(led_o[1:0])
	);

	assign led_o[7:2] = led[7:2];
endmodule
