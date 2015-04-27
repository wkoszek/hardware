module main(clk_i, button_i, led_o);
	input wire		clk_i;
	input wire [3:0]	button_i;
	output wire [7:0]	led_o;

	wire	buttor_right;
	wire	button_left;
	wire	button_reset;
	wire	dir;
	wire	strobe;

// "button<0>"  # east
// "button<1>" # north
// "button<2>" # south
// "button<3>"  # west
	wire	dummy = button_i[1];

	debouncer #(
		.DEBOUNCER_DELAY(`TRIGGER_CNT / 10)
	) reset_debouncer (
		.clk_i(clk_i),
		.d_i(button_i[2]),
		.d_o(button_reset)
	);

	debouncer #(
		.DEBOUNCER_DELAY(`TRIGGER_CNT / 10)
	) debouncer0 (
		.clk_i(clk_i),
		.d_i(button_i[0]),
		.d_o(button_right)
	);

	debouncer #(
		.DEBOUNCER_DELAY(`TRIGGER_CNT / 10)
	) debouncer1 (
		.clk_i(clk_i),
		.d_i(button_i[3]),
		.d_o(button_left)
	);

	assign	strobe = (button_left ^ button_right);
	assign	dir = (~button_left | button_right); // left:dir==0,right:dir==1

	ruler #(
		.RULER_WIDTH(8)
	) ruler0 (
		.clk_i(clk_i),
		.rst_i(button_reset),
		.stb_i(strobe),
		.dir_i(dir),
		.ruler_o(led_o)
	);

endmodule
