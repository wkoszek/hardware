`timescale 10ns/1ps
module glbl();
wire	GSR;

wire[7:0]	led;
reg	clk = 0;
reg	rst = 0;

always #1 clk = ~clk;

main main(
	.clk_pin_i(clk),
	.rst_pin_i(rst),
	.led_o(led)
);

endmodule
