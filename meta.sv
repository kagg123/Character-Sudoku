//taken from 271 lab
//Establishes appropriate inputs and outputs for a pair of d-flipflops to combat metastability issues
module meta (clk, d1, q2, reset);
	input logic clk, d1, reset;
	output logic q2;
	logic q1;	

	always_ff @(posedge clk) begin
		if (reset) begin
            q1 <= 0;
            q2 <= 0;
		end
		else begin
            q1 <= d1;
            q2 <= q1;
		end
	end

endmodule //end meta

//Instantiates the meta module with appropriate inputs and outputs
//Tests different input combinations and ordering with the positive edge
//of the clock as a delay 
module meta_testbench();
	logic clk, d1, reset;
	logic q2;
	logic q1;
	
	meta dut (clk, d1, q2, reset);
	
	// Set up the clock
	parameter CLOCK_PERIOD = 100;
	initial clk = 0;
	always begin	
		#(CLOCK_PERIOD/2);
		clk = ~clk;	
	end	

    // Set up the inputs to the design. Each line is a clock cycle.
	initial begin

    reset <= 1;	                                        @(posedge clk);
                                                        @(posedge clk);
                                                        @(posedge clk);
	reset <= 0; d1 <= 1;                                @(posedge clk);
                                                        @(posedge clk);
                                                        @(posedge clk);
				d1 <= 0;								@(posedge clk);
                                                        @(posedge clk);
                                                        @(posedge clk);
				d1 <= 1;								@(posedge clk);
                                                        @(posedge clk);
                                                        @(posedge clk);
				d1 <= 0;								@(posedge clk);
                                                        @(posedge clk);	
                                                        
	$stop; // End the simulation.
	end	

endmodule //end meta_testbench