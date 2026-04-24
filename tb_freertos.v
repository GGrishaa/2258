`timescale 1 ns / 1 ps

module tb_freertos;
    reg clk;
    reg resetn;
    wire [31:0] gpio_out;

    always #5 clk = ~clk;

    picosoc #(
        .MEM_WORDS(16384)
    ) uut (
        .clk      (clk),
        .resetn   (resetn),
        .iomem_valid (),
        .iomem_ready (1'b0),
        .iomem_wstrb (),
        .iomem_addr  (),
        .iomem_wdata (),
        .iomem_rdata (32'h0),
        .irq_5    (1'b0),
        .irq_6    (1'b0),
        .irq_7    (1'b0),
        .ser_tx   (),
        .ser_rx   (1'b1),
        .flash_csb(),
        .flash_clk(),
        .flash_io0_oe(),
        .flash_io1_oe(),
        .flash_io2_oe(),
        .flash_io3_oe(),
        .flash_io0_do(),
        .flash_io1_do(),
        .flash_io2_do(),
        .flash_io3_do(),
        .flash_io0_di(1'b0),
        .flash_io1_di(1'b0),
        .flash_io2_di(1'b0),
        .flash_io3_di(1'b0),
        .gpio_out(gpio_out)
    );

    initial begin
        $dumpfile("freertos.vcd");
        $dumpvars(0, tb_freertos);
        clk = 0;
        resetn = 0;
        #100 resetn = 1;

        #30000000 $finish;
    end
endmodule