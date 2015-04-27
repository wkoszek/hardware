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

	reg [RULER_WIDTH - 1:0]	ruler;

	initial begin
		ruler <= 0;
	end

	always @(posedge clk_i) begin
		if (rst_i) begin
			ruler <= 1;
		end else begin
			if (stb_i) begin
				// 7 6 5 4 3 2 1 0
				if (dir_i == `DIR_RIGHT) begin
					if (ruler == `RCORNER) begin
						ruler <= `LCORNER;
					end else begin
						ruler <= { 1'b0, ruler[7:1] };
					end
				end else begin
					if (ruler == `LCORNER) begin
						ruler <= `RCORNER;
					end else begin
						ruler <= { ruler[6:0], 1'b0 };
					end
				end
			end
		end
	end

	assign ruler_o = ruler;
endmodule
