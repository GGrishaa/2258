`timescale 1 ns / 1 ps

module system_tb;
	integer fd;

	reg clk = 1;
	reg f_clk = 1;
	always #5 clk = ~clk;
	always #2.5 f_clk = ~f_clk;

	reg resetn = 1;
	initial begin
		
		repeat (10) @(posedge clk);
		resetn <= 0;
	end
	
	initial begin
			//fd = $fopen("stfft.txt", "w");
			
			$dumpfile("system.vcd");
			//$dumpvars(0, system_tb.uut.gpio);
			$dumpvars(0, system_tb); //full_test
		end


    wire [31:0] gpio,gpio1;



	Pico_SoC uut (
		.clk	(clk),
		.f_clk	(f_clk),
		.rst	(resetn),
		.gpio	(gpio),
		.gpio1	(gpio1)
	);
	
	
	//file in write
	/*
	parameter IP_CORE_ADDR = 32'h1003_0000;
	always@(posedge clk)
	begin
		if(system_tb.uut.fft.ack_o==1)
		begin
			if((system_tb.uut.fft.adr_i >= (IP_CORE_ADDR+32'h1000)) && (system_tb.uut.fft.adr_i < (IP_CORE_ADDR+32'h2000))) 
		    		$fdisplay(fd,"%d %d",system_tb.uut.fft.adr_i[11:0]>>2,system_tb.uut.fft.fft_out_buf_r[system_tb.uut.fft.adr_i[11:0]>>2]);
		    	else if((system_tb.uut.fft.adr_i >= (IP_CORE_ADDR+32'h2000)) && (system_tb.uut.fft.adr_i < (IP_CORE_ADDR+32'h3000))) 
		    		$fdisplay(fd,"%d %d",system_tb.uut.fft.adr_i[11:0]>>2,system_tb.uut.fft.fft_out_buf_i[system_tb.uut.fft.adr_i[11:0]>>2]);
		end
	end
	*/
	

	initial 
	begin
	#1_000_000 
	//#5_000_000_000//full_test
	//$fclose(fd);
	$finish;
	end

endmodule
