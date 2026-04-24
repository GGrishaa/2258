`ifndef PICORV32_REGS
`ifdef PICORV32_V
`error "picosoc.v must be read before picorv32.v!"
`endif

`define PICORV32_REGS picosoc_regs
`endif

`ifndef PICOSOC_MEM
`define PICOSOC_MEM picosoc_mem
`endif

// this macro can be used to check if the verilog files in your
// design are read in the correct order.
`define PICOSOC_V

module picosoc (
	input clk,
	input resetn,

	output        iomem_valid,
	input         iomem_ready,
	output [ 3:0] iomem_wstrb,
	output [31:0] iomem_addr,
	output [31:0] iomem_wdata,
	input  [31:0] iomem_rdata,

	input  irq_5,
	input  irq_6,
	input  irq_7,

	output ser_tx,
	input  ser_rx,

	output flash_csb,
	output flash_clk,

	output flash_io0_oe,
	output flash_io1_oe,
	output flash_io2_oe,
	output flash_io3_oe,

	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,
	output flash_io3_do,

	input  flash_io0_di,
	input  flash_io1_di,
	input  flash_io2_di,
	input  flash_io3_di,
	output [31:0] gpio_out
);
	parameter [0:0] BARREL_SHIFTER = 1;
	parameter [0:0] ENABLE_MUL = 1;
	parameter [0:0] ENABLE_DIV = 1;
	parameter [0:0] ENABLE_FAST_MUL = 0;
	parameter [0:0] ENABLE_COMPRESSED = 1;
	parameter [0:0] ENABLE_COUNTERS = 1;
	parameter [0:0] ENABLE_IRQ_QREGS = 0;

	parameter integer MEM_WORDS = 16384;
	parameter [31:0] STACKADDR = (4*MEM_WORDS);       // end of memory
	parameter [31:0] PROGADDR_RESET = 32'h 0000_0000; // 1 MB into flash
	parameter [31:0] PROGADDR_IRQ = 32'h 0000_0000;

	reg [31:0] irq;
	wire irq_stall = 0;
	wire irq_uart = 0;

	always @* begin
		irq = 0;
		irq[3] = irq_stall;
		irq[4] = irq_uart;
		irq[5] = irq_5;
		irq[6] = irq_6;
		irq[7] = irq_7;
	end

	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

	wire spimem_ready;
	wire [31:0] spimem_rdata;

	reg ram_ready;
	wire [31:0] ram_rdata;

	assign iomem_valid = mem_valid && (mem_addr[31:24] > 8'h 01);
	assign iomem_wstrb = mem_wstrb;
	assign iomem_addr = mem_addr;
	assign iomem_wdata = mem_wdata;

	wire spimemio_cfgreg_sel = mem_valid && (mem_addr == 32'h 0200_0000);
	wire [31:0] spimemio_cfgreg_do;

	wire        simpleuart_reg_div_sel = mem_valid && (mem_addr == 32'h 0200_0004);
	wire [31:0] simpleuart_reg_div_do;

	wire        simpleuart_reg_dat_sel = mem_valid && (mem_addr == 32'h 0200_0008);
	wire [31:0] simpleuart_reg_dat_do;
	wire        simpleuart_reg_dat_wait;

	assign mem_ready = (iomem_valid && iomem_ready) || spimem_ready || ram_ready || spimemio_cfgreg_sel ||
			simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait) || gpio_sel || timer_access;

	assign mem_rdata = (iomem_valid && iomem_ready) ? iomem_rdata :
                   spimem_ready                ? spimem_rdata :
                   ram_ready                   ? ram_rdata :
                   spimemio_cfgreg_sel         ? spimemio_cfgreg_do :
                   simpleuart_reg_div_sel      ? simpleuart_reg_div_do :
                   simpleuart_reg_dat_sel      ? simpleuart_reg_dat_do :
                   timer_access                ? timer_rdata :
                   gpio_sel                    ? gpio_out :
                   32'h0000_0000;

	picorv32 #(
		.STACKADDR(STACKADDR),
		.PROGADDR_RESET(PROGADDR_RESET),
		.PROGADDR_IRQ(PROGADDR_IRQ),
		.BARREL_SHIFTER(BARREL_SHIFTER),
		.COMPRESSED_ISA(ENABLE_COMPRESSED),
		.ENABLE_COUNTERS(ENABLE_COUNTERS),
		.ENABLE_MUL(ENABLE_MUL),
		.ENABLE_DIV(ENABLE_DIV),
		.ENABLE_FAST_MUL(ENABLE_FAST_MUL),
		.ENABLE_IRQ(1),
		.PROGADDR_IRQ(32'h00000010),
		.ENABLE_IRQ_QREGS(1),
		.ENABLE_IRQ_TIMER(1)
	) cpu (
		.clk         (clk        ),
		.resetn      (resetn     ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.irq         (irq        )
	);

	spimemio spimemio (
		.clk    (clk),
		.resetn (resetn),
		.valid  (mem_valid && mem_addr >= 4*MEM_WORDS && mem_addr < 32'h 0200_0000),
		.ready  (spimem_ready),
		.addr   (mem_addr[23:0]),
		.rdata  (spimem_rdata),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.cfgreg_we(spimemio_cfgreg_sel ? mem_wstrb : 4'b 0000),
		.cfgreg_di(mem_wdata),
		.cfgreg_do(spimemio_cfgreg_do)
	);

	simpleuart simpleuart (
		.clk         (clk         ),
		.resetn      (resetn      ),

		.ser_tx      (ser_tx      ),
		.ser_rx      (ser_rx      ),

		.reg_div_we  (simpleuart_reg_div_sel ? mem_wstrb : 4'b 0000),
		.reg_div_di  (mem_wdata),
		.reg_div_do  (simpleuart_reg_div_do),

		.reg_dat_we  (simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b 0),
		.reg_dat_re  (simpleuart_reg_dat_sel && !mem_wstrb),
		.reg_dat_di  (mem_wdata),
		.reg_dat_do  (simpleuart_reg_dat_do),
		.reg_dat_wait(simpleuart_reg_dat_wait)
	);

	wire        gpio_sel = mem_valid && (mem_addr == 32'h 0300_0010);
    reg  [31:0] gpio_out_reg;
	assign gpio_out = gpio_out_reg;
    wire [31:0] gpio_in = 32'h0;

    always @(posedge clk) begin
        if (!resetn)
            gpio_out_reg <= 0;
        else if (gpio_sel && mem_wstrb)
            gpio_out_reg <= mem_wdata;
    end

	always @(posedge clk) if (gpio_sel && mem_wstrb) $display("GPIO_WRITE at %t: data=%h", $time, mem_wdata);

	always @(posedge clk) begin
    	if (mem_valid && |mem_wstrb) begin
        	$display("[%0t] MEM_WRITE addr=%h data=%h wstrb=%b", $time, mem_addr, mem_wdata, mem_wstrb);
    	end
	end

	always @(posedge clk) begin
    	if (cpu.trap) begin
        	$display("[%0t] >>> TRAP!", $time);
    	end
	end

	always @(posedge clk) begin
    	if (mem_valid && mem_instr && !mem_ready) begin
        	$display("[%0t] FETCH waiting addr=%h", $time, mem_addr);
    	end
	end

    always @(posedge clk) begin
        if (mem_valid) begin
            if (mem_instr)
                $display("[%0t] FETCH addr=%h ready=%b", $time, mem_addr, mem_ready);
            else if (|mem_wstrb)
                $display("[%0t] WRITE addr=%h data=%h wstrb=%b ready=%b", $time, mem_addr, mem_wdata, mem_wstrb, mem_ready);
            else
                $display("[%0t] READ  addr=%h ready=%b", $time, mem_addr, mem_ready);
        end
    end

	localparam MTIME_ADDR    = 32'h 0300_0000;
	localparam MTIMECMP_ADDR = 32'h 0300_0008;

	wire timer_sel     = mem_valid && (mem_addr == MTIME_ADDR);
	wire timercmp_sel  = mem_valid && (mem_addr == MTIMECMP_ADDR);
	wire timer_access  = timer_sel || timercmp_sel;

	reg  [63:0] mtime;
	reg  [63:0] mtimecmp;
	wire        timer_irq = (mtime >= mtimecmp);

	initial begin
    	mtime <= 0;
    	mtimecmp <= 64'hFFFFFFFFFFFFFFFF;
	end

	always @(posedge clk) begin
    	if (!resetn)
        	mtime <= 0;
    	else
        	mtime <= mtime + 1;
	end

	always @(posedge clk) begin
    	if (!resetn) begin
        	mtimecmp <= 64'hFFFFFFFFFFFFFFFF;
    	end else if (timercmp_sel && mem_wstrb) begin
        	if (mem_wstrb[0]) mtimecmp[7:0]   <= mem_wdata[7:0];
        	if (mem_wstrb[1]) mtimecmp[15:8]  <= mem_wdata[15:8];
        	if (mem_wstrb[2]) mtimecmp[23:16] <= mem_wdata[23:16];
        	if (mem_wstrb[3]) mtimecmp[31:24] <= mem_wdata[31:24];
        	// Старшие 32 бита пока не реализованы (для простоты)
        	// При необходимости можно добавить второй регистр по адресу 0x0300000C
    	end
	end

	wire [31:0] timer_rdata;
	assign timer_rdata = timer_sel   ? mtime[31:0]     :
                     timercmp_sel ? mtimecmp[31:0] :
                     32'h0;

	always @(posedge clk) begin
    	irq = 0;
    	irq[0] = timer_irq;
    	irq[1] = 1'b0;
    	irq[3] = irq_stall;
    	irq[4] = irq_uart;
    	irq[5] = irq_5;
    	irq[6] = irq_6;
    	irq[7] = irq_7;
	end

	always @(posedge clk)
		ram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS;

	`PICOSOC_MEM #(
		.WORDS(MEM_WORDS)
	) memory (
		.clk(clk),
		.wen((mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS) ? mem_wstrb : 4'b0),
		.addr(mem_addr[23:2]),
		.wdata(mem_wdata),
		.rdata(ram_rdata)
	);
endmodule

// Implementation note:
// Replace the following two modules with wrappers for your SRAM cells.

module picosoc_regs (
	input clk, wen,
	input [5:0] waddr,
	input [5:0] raddr1,
	input [5:0] raddr2,
	input [31:0] wdata,
	output [31:0] rdata1,
	output [31:0] rdata2
);
	reg [31:0] regs [0:31];

	always @(posedge clk)
		if (wen) regs[waddr[4:0]] <= wdata;

	assign rdata1 = regs[raddr1[4:0]];
	assign rdata2 = regs[raddr2[4:0]];
endmodule

module picosoc_mem #(
	parameter integer WORDS = 16384
) (
	input clk,
	input [3:0] wen,
	input [21:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata
);
	reg [31:0] mem [0:WORDS-1];

	initial begin
        $readmemh("firmware/firmware.hex", mem);
		$display("MEM[0]=%h, MEM[1]=%h, MEM[2]=%h, MEM[3]=%h", mem[0], mem[1], mem[2], mem[3]);
    end

	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
	end
endmodule