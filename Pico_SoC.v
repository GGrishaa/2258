`timescale 1 ns / 1 ps

module Pico_SoC (
	input clk,f_clk,
	input rst,
	output [31:0] gpio, gpio1
);

	reg [31:0] irq = 0;

	reg [15:0] count_cycle = 0;
	always @(posedge clk) count_cycle <= !rst ? count_cycle + 1 : 0;


	wire [31:0] 	wb_adr_pico,	wb_adr_ram,	wb_adr_gpio;
	wire [31:0] 	wb_dat_o_pico,	wb_dat_o_ram,	wb_dat_o_gpio;
	wire [3:0] 	wb_sel_pico,	wb_sel_ram,	wb_sel_gpio;
	wire 		wb_we_pico,	wb_we_ram,	wb_we_gpio;
	wire 		wb_cyc_pico,	wb_cyc_ram,	wb_cyc_gpio;
	wire 		wb_stb_pico,	wb_stb_ram,	wb_stb_gpio;
	wire [31:0] 	wb_dat_i_pico,	wb_dat_i_ram,	wb_dat_i_gpio;
	wire 		wb_ack_pico,	wb_ack_ram,	wb_ack_gpio;
	
	wb_ram #(.depth (2*4096),.memfile("firmware.mem")) 
	ram ( // Wishbone interface
		.wb_clk_i(clk),
		.wb_rst_i(rst),

		.wb_adr_i(wb_adr_ram),
		.wb_dat_i(wb_dat_i_ram),
		.wb_stb_i(wb_stb_ram),
		.wb_cyc_i(wb_cyc_ram),
		.wb_dat_o(wb_dat_o_ram),
		.wb_ack_o(wb_ack_ram),
		.wb_sel_i(wb_sel_ram),
		.wb_we_i(wb_we_ram),

		.mem_instr(),
		.tests_passed()
	);
	
	wb_gpio #(.GPIO_ADDR(32'h1001_0000)) wb_gpio
	(
		.clk_i(clk),         // clock
  		.rst_i(rst),         // reset (asynchronous active low)
  		.cyc_i(wb_cyc_gpio),         // cycle
  		.stb_i(wb_stb_gpio),         // strobe
  		.adr_i(wb_adr_gpio),         // address adr_i[1]
  		.we_i(wb_we_gpio),          // write enable
  		.data_i(wb_dat_i_gpio),         // data output
  		.data_o(wb_dat_o_gpio),         // data input
  		.ack_o(wb_ack_gpio),        // normal bus termination
		.gpio(gpio),
		.gpio1(gpio1)
  	);

  	
	
	picorv32_wb #(
		.ENABLE_MUL(1),
		.ENABLE_DIV(1),
		.ENABLE_IRQ(1),
		.ENABLE_TRACE(1)
	) uut (
		//.trap (trap),
		.irq (irq),
		.trace_valid (trace_valid),
		.trace_data (trace_data),
		.mem_instr(mem_instr),

		.wb_clk_i(clk),
		.wb_rst_i(rst),

		.wbm_adr_o(wb_adr_pico),
		.wbm_dat_i(wb_dat_i_pico),
		.wbm_stb_o(wb_stb_pico),
		.wbm_ack_i(wb_ack_pico),
		.wbm_cyc_o(wb_cyc_pico),
		.wbm_dat_o(wb_dat_o_pico),
		.wbm_we_o(wb_we_pico),
		.wbm_sel_o(wb_sel_pico)
	);
	
	//test
	wire [31:0] tr_maddr;
	assign tr_maddr = wb_adr_pico >> 2;
	
	//wishbone interconnect crossbar
	wbxbar
	#(	.NM(1),.NS(2),.AW(32),.DW(32),
		.SLAVE_ADDR({32'h0000_0000, 32'h1001_0000}),
		.SLAVE_MASK({32'hFFFF_0000, 32'hFFFF_F000}) 
	)
	crossbar
	(
		//
		.i_clk(clk), 
		.i_reset(rst),
		//
		// Here are the bus inputs from each of the WB bus masters
		.i_mcyc(wb_cyc_pico), 
		.i_mstb(wb_stb_pico),
		.i_mwe(wb_we_pico),
		.i_maddr(wb_adr_pico),
		.i_mdata(wb_dat_o_pico),//rev
		.i_msel(wb_sel_pico),
		// .... and their return data
		//.o_mstall(),
		.o_mack(wb_ack_pico),
		.o_mdata(wb_dat_i_pico),//rev
		//.o_merr(),
		//
		//-----------------------------------
		//
		// Here are the output ports, used to control each of the
		// various slave ports that we are connected to
		.o_scyc({	wb_cyc_ram,	wb_cyc_gpio }), 
		.o_sstb({	wb_stb_ram,	wb_stb_gpio }), 
		.o_swe({	wb_we_ram,	wb_we_gpio }),
		.o_saddr({	wb_adr_ram,	wb_adr_gpio }),
		.o_sdata({	wb_dat_i_ram,	wb_dat_i_gpio }),//rev
		.o_ssel({	wb_sel_ram,	wb_sel_gpio }),
		// ... and their return data back to us.
		//.i_sstall({}), 
		.i_sack({	wb_ack_ram,	wb_ack_gpio }),
		.i_sdata({	wb_dat_o_ram,	wb_dat_o_gpio })//rev
		//.i_serr({})
		// 
	);
		
endmodule
