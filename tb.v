`timescale 1 ns / 1 ps

module system_tb;
    integer fd;

    // === Clocks ===
    reg clk = 1;
    reg f_clk = 1;
    always #5 clk = ~clk;
    always #2.5 f_clk = ~f_clk;

    // === Reset ===
    reg resetn = 1;
    initial begin
        repeat (10) @(posedge clk);
        resetn <= 0;
    end

    // === VCD Dump ===
    initial begin
        $dumpfile("system.vcd");
        $dumpvars(0, system_tb);
    end

    // === GPIO wires ===
    wire [31:0] gpio, gpio1;

	// === Простой и надёжный генератор IRQ ===
	reg [15:0] irq_counter;
	reg [31:0] irq;

	always @(posedge clk) begin
    	if (resetn) begin
        	irq_counter <= 16'd0;
        	irq <= 32'd0;
    	end else begin
        	irq_counter <= irq_counter + 1'd1;
        	if (irq_counter >= 16'd9000 && irq_counter < 16'd10000) begin
            	irq <= 32'd1;
        	end else begin
        		irq <= 32'd0;
        	end
    	end
	end
// =========================================

    // === Инстансация Pico_SoC ===
    Pico_SoC uut (
        .clk    (clk),
        .f_clk  (f_clk),
        .rst    (resetn),
        .irq    (irq),
        .gpio   (gpio),
        .gpio1  (gpio1)
    );

    // === Завершение симуляции ===
    initial begin
        #100_000_000;
        $finish;
    end

endmodule