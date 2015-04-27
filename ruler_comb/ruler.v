`define	TRIGGER_CNT	50*1000*1000
`define	DIR_RIGHT	1'b1
`define	DIR_LEFT	1'b0
`define	RCORNER		8'h1
`define	LCORNER		8'h80

module ruler(clk_i, rst_i, stb_i, dir_i, ruler_o);
	parameter		RULER_WIDTH = 8;
	input wire		clk_i;
	input wire		rst_i;
	input wire		stb_i;
	input wire		dir_i;
	output wire [RULER_WIDTH - 1:0]		ruler_o;

wire[RULER_WIDTH - 1:0]	bit_lshift = 1 << cnt;
wire[RULER_WIDTH - 1:0]	bit_rshift = 1 >> cnt;

reg[10:0] cnt_ff;
wire dir = cnf_ff[5];
wire[10:0] cnt = (dir == 1) ? bit_lshift : bit_rshift;

always @(posedge clk_i) begin
	cnt_ff <= cnt;
	$display("cnt_ff = %d\n", cnt_ff);
end

endmodule
