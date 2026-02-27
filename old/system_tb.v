`timescale 1 ns / 1 ps

module system_tb;
	reg clk = 1;
	always #5 clk = ~clk;

	reg resetn = 0;
	initial begin
		
		repeat (100) @(posedge clk);
		resetn <= 1;
	end
	
	initial begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end


    wire [7:0] led;



	system uut (
		.clk        (clk        ),
		.resetn(resetn),
		.led(led)
	);
	
	initial #2_000_000 $finish;

endmodule
