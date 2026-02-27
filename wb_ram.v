`timescale 1 ns / 1 ps

module wb_ram 
#(
	parameter depth = 256,
	parameter memfile = "firmware.mem",
	parameter VERBOSE = 0
) 
(
	input wb_clk_i,
	input wb_rst_i,

	input [31:0] wb_adr_i,
	input [31:0] wb_dat_i,
	input [3:0] wb_sel_i,
	input wb_we_i,
	input wb_cyc_i,
	input wb_stb_i,

	output reg wb_ack_o,
	output reg [31:0] wb_dat_o,

	input mem_instr,
	output reg tests_passed
);

	initial tests_passed = 0;

	reg [31:0] adr_r;
	wire valid = wb_cyc_i & wb_stb_i;

	always @(posedge wb_clk_i) begin
		//adr_r <= wb_adr_i;
		// Ack generation
		wb_ack_o <= valid & !wb_ack_o;
		if (wb_rst_i)
		begin
			adr_r <= {32{1'b0}};
			wb_ack_o <= 1'b0;
		end
	end

	wire ram_we = wb_we_i & valid & wb_ack_o & ((wb_adr_i >> 2) < depth);

	wire [31:0] waddr;
	assign waddr = wb_adr_i >> 2;
	wire [31:0] raddr;
	assign raddr = wb_adr_i >> 2;
	wire [3:0] we = {4{ram_we}} & wb_sel_i;


	reg [31:0] mem [0:depth-1] /* verilator public */;


	always @(posedge wb_clk_i) begin
		if ((waddr) < depth) begin
			if (we[0])
				mem[waddr][7:0] <= wb_dat_i[7:0];

			if (we[1])
				mem[waddr][15:8] <= wb_dat_i[15:8];

			if (we[2])
				mem[waddr][23:16] <= wb_dat_i[23:16];

			if (we[3])
				mem[waddr][31:24] <= wb_dat_i[31:24];

		end

		if ((raddr) < depth) wb_dat_o <= mem[raddr];
	end

	initial 
	begin
		//if (memfile != "")
			$readmemh(memfile, mem);
	end
endmodule
