//taken from ee271 lab 5
//creates 32 clock signals of varying periods
//takes input clock and reset
//outputs 32 bit array, each index has twice the period of the previous index  
//instantiated in taskFour module
module clock_divider (clk, reset, divided_clocks);
		 input logic reset, clk;
		 output logic [31:0] divided_clocks = 0;

		 //increments divided clocks by 1 every time the clock goes to 1
		 always_ff @(posedge clk) begin
			divided_clocks <= divided_clocks + 1;
		 end

endmodule //ends clock_divider module
