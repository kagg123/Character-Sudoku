/* Given two x coordinates and a y coordinate on the screen, this module draws a horizontal line between
 * those two points by coloring necessary pixels
 *
 * Instantiated in makeSquare
 * 
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *	 x0 	- x coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y	 	- y coordinate of the line
 *   color_line- color of the line
 *
 * Outputs:
 *   x 		- x coordinate of the pixel
 *   y 		- y coordinate of the pixel 
 *  color_out - color of the pixel
 *
 */
module horizontal_line_drawer(clk, x0, x1, y, xDraw, yDraw, color_line, color_out);

	input logic clk;
	input logic [10:0]	x0, x1, y;
	input logic [2:0] color_line;
	output logic [2:0] color_out;
	output logic [10:0]	xDraw, yDraw; 

	enum {S1, S2} ps, ns;
	logic init, incr;;  
	logic [10:0] curr_x1;    
	
	//state logic
	//when line drawer finishes drawing a line, it initializes x0, x1, and y again to draw a new line 
	//when the output xDraw is less than the current x1, it increments xDraw
	//default case is initialize variables
	always_comb begin
		init = 0; incr = 0;
		case (ps)
			S1: begin 
				init = 1; ns = S2;
			end
			S2: begin
				if (xDraw < curr_x1) begin 
					incr = 1; ns = S2; 
				end else ns = S1;
			end
			default: ns = S1;
		endcase
	end //end always_comb

	//updates states
	//when initializes sets outputs to input and curr_x1 to input x1
	//when incremented, increments 
	always_ff @(posedge clk) begin	
		ps <= ns;
		if (init) begin
			xDraw <= x0;
            curr_x1<= x1;
            yDraw <= y;
			color_out <= color_line;
		end
		if (incr) begin
			xDraw <= xDraw + 1'b1;
		end
	end //end always_ff
   
endmodule

module horizontal_line_drawer_testbench();
	logic clk;
	logic [10:0] x0, x1, y;
	logic [2:0] color_line;
	logic [2:0] color_out;
	logic [10:0]	xDraw, yDraw; 

	horizontal_line_drawer dut (.*);
	
	//set up clock
	parameter CLOCK_PERIOD = 100;	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
		
	end
	
	integer i;
	initial begin
		@(posedge clk);
		x0 <= 0; x1 <= 10; y <= 10; color_line <= 3'b000;
		for(i = 0; i < 2**5; i++) begin
			@(posedge clk);
		end
		x0 <= 50; x1 <= 60; y <= 50; color_line <= 3'b111;
		for(i = 0; i < 2**5; i++) begin
			@(posedge clk);
		end
	
		$stop; // End the simulation.
	end
endmodule
