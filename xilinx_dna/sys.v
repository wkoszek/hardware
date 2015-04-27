`timescale 10ns/1ps
module main(
	input clk_pin_i,
	input rst_pin_i,
	output[7:0] led_o
);

// Logic analyzer part
// -------------------
// This block consists of ICON controller, with 2 submodules: logic analyzer
// (ILA) nad GPIO module (VIO). They use la_ctl0 and la_ctl1 busses
// respectively.
wire[35:0]	la_ctl0;
wire[35:0]	la_ctl1;
wire[31:0]	la_data;
wire[7:0]	la_trig;
wire		la_trig_out;
wire[7:0]	la_async_in = { 8'd0 };
wire[7:0]	la_async_out;
wire[7:0]	la_sync_in = { 8'd0 };
wire[7:0]	la_sync_out;

chipscope_icon la_icon(
	.CONTROL0(la_ctl0[35:0]),
	.CONTROL1(la_ctl1[35:0]),
	.CONTROL2(),
	.CONTROL3()
);

chipscope_ila la_ila(
	.CONTROL(la_ctl0[35:0]),
	.CLK(clk_pin_i),
	.DATA(la_data),
	.TRIG0(la_trig),
	.TRIG_OUT(la_trig_out)
);

chipscope_vio la_vio(
	.CONTROL(la_ctl1[35:0]),
	.CLK(clk_pin_i),
	.ASYNC_IN(la_async_in[7:0]),
	.ASYNC_OUT(la_async_out[7:0]),
	.SYNC_IN(la_sync_in[7:0]),
	.SYNC_OUT(la_sync_out[7:0])
);

`define G_FREQ	25000000

wire	clk_i = clk_pin_i;
wire	rst_i = rst_pin_i;

// Actual logic gets generated here.
reg[31:0]	clkdiv_r = 0;
wire[31:0]	clkdiv = (clkdiv_r[31:0] < `G_FREQ) ?  (clkdiv_r[31:0] + 1) : 0;
wire		led_change = clkdiv_r[31:0] == 0;
reg[3:0]	cnt_r = 0;
wire[3:0]	cnt = led_change ? cnt_r + 1 : cnt_r;

always @(posedge clk_i) begin
	clkdiv_r <= rst_i ? 0 : clkdiv;
	cnt_r <= rst_i ? 0 : cnt;
end

wire		dna_dout;
wire		dna_din;

reg[7:0]	dna_cnt_r = 0;
wire		dna_ready = dna_cnt_r[7:0] > 57;
wire[7:0]	dna_cnt = !dna_ready ? dna_cnt_r[7:0] + 8'd1 : dna_cnt_r[7:0];
wire		dna_read = dna_cnt_r[7:0] == 8'd0;
reg		dna_read_r = 0;
wire		dna_shift = ~dna_read && ~dna_ready;
reg[63:0]	dna_reg_r = 64'd0;
wire[63:0]	dna_reg_shifted = { dna_reg_r[62:0], (dna_dout === 1'b1) };
// DNA_PORT simulation block puts 1'b1 in the register and you see it while
//  simulating. To get rid of that, we ignore gather data at start.
wire		dna_start = dna_read_r && dna_shift;		// start
wire		dna_end = (dna_read | dna_shift) == 0;		// finish
wire[63:0]	dna_reg = (dna_start || dna_end) ? dna_reg_r : dna_reg_shifted;

initial begin
	#1000;
	$finish;
end

integer cycle_num = 0;
always @(posedge clk_i) begin
	cycle_num <= cycle_num + 1;
	dna_cnt_r <= rst_i ? 8'd0 : dna_cnt;
	dna_reg_r <= rst_i ? 64'd0 : dna_reg;
	dna_read_r <= rst_i ? 1'b0 : dna_read;
	$display("%d %d dna_dout=%d dna_read:%d dna_read_r:%d dna_shift:%d dna_cnt_r=%x dna_reg_r=%x",
		$time, cycle_num, dna_dout, dna_read, dna_read_r, dna_shift, dna_cnt_r, dna_reg_r);
end
DNA_PORT #(
	.SIM_DNA_VALUE(57'habcdef12)	//  while picking 64-bit literal was easier
) dna (
	.CLK(clk_i),
	.DOUT(dna_dout),
	.READ(dna_read),
	.SHIFT(dna_shift),
	.DIN(1'd0)
);

assign la_trig[7:0] = { cnt_r[3:0], 2'd0, rst_pin_i, clk_pin_i };
assign la_data[31:0] = { dna_reg_r };
assign led_o[7:0] = { cnt_r[3:0], la_sync_out[3:0] };

endmodule
