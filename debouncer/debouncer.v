/*
 * Simple debouncer module.
 *
 * FSM is used to check, whether the instance is in one of the three states:
 *
 * - initial state, where output is being zerod
 *
 * - counting state: it's where we decide how long button needs to be
 *   pressed to generate a state change on the output
 *
 * - do state, where actual change happens
 *
 */
`define	S_INIT	0
`define	S_COUNT	1
`define	S_DO	2

module debouncer(clk_i, d_i, d_o);
	parameter	DEBOUNCER_DELAY = 50*1000*1000/16;

	input wire	clk_i;
	input wire	d_i;
	output wire	d_o;

	reg [30:0]	cnt;
	reg		o;
	reg [1:0]	state;

	initial begin
		cnt <= 0;
		state <= `S_INIT;
		o <= 0;
	end

	always @(posedge clk_i) begin
		case (state)
		`S_INIT:
			begin
				if (d_i == 1'b1) begin
					cnt <= 0;
					o <= 0;
					state <= `S_COUNT;
				end
			end
		`S_COUNT:
			begin
				if (d_i == 1'b1) begin
					if (cnt == DEBOUNCER_DELAY) begin
						state <= `S_DO;
					end else begin
						cnt <= cnt + 1;
					end
				end else begin
					state <= `S_INIT;
				end
			end
		`S_DO:
			begin
				state <= `S_INIT;
				o <= 1;
			end
		endcase
	end
	assign d_o = o;
endmodule

