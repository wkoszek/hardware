module main(clk, button, led);
	input wire		clk;
	input wire [3:0]	button;
	output reg [7:0]	led;

	wire [3:0]		button_dbc;

	initial begin
		led <= 0;
	end

	debouncer debouncer0(
		.clk_i(clk),
		.d_i(button[0]),
		.d_o(button_dbc[0])
	);
	debouncer debouncer1(
		.clk_i(clk),
		.d_i(button[1]),
		.d_o(button_dbc[1])
	);
	debouncer debouncer2(
		.clk_i(clk),
		.d_i(button[2]),
		.d_o(button_dbc[2])
	);
	debouncer debouncer3(
		.clk_i(clk),
		.d_i(button[3]),
		.d_o(button_dbc[3])
	);

	always @(posedge clk) begin
		if (button_dbc != 4'b0000) begin
			led <= led + 1;
		end
	end
endmodule
