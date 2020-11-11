/* Given two x coordinates and a y coordinate on the screen, this module draws a square between
 * those two points in the color provided by drawing horizontal lines from x0 to x1 between y0 and y1
 *
 * Instantiated in draw_obj_sod
 * 
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   divided_clock_Square- connected to a slower clock
 *	 x0 	- x coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y0	 	- y coordinate of the first end point
 *   y1	 	- y coordinate of the second end point
 *  color_in- color of the square
 *
 * Outputs:
 *   x 		- x coordinate of the pixel
 *   y 		- y coordinate of the pixel 
 *  color_out - color of the pixel
 *
 */
module makeSquare(x0, y0, x1, y1, clk, xDraw, yDraw, color_in, color_out, divided_clock_Square);
    input logic clk;
    input logic [2:0] color_in;
    input logic [10:0] x0, x1;
	input logic [10:0] y0, y1;
    input logic divided_clock_Square;
	 
    output logic [10:0] xDraw;
	output logic [10:0] yDraw;
    output logic [2:0] color_out;
    
    enum {S1, S2} ps, ns;
    logic incr, init;

    logic [10:0] curr_x0, curr_x1, yLine, curr_y1;
    logic [2:0] color_line;

    //instantiates line drawer module
    horizontal_line_drawer ld (.clk, .x0(curr_x0), .x1(curr_x1), .y(yLine), .xDraw, .yDraw, .color_line, .color_out);
    //state logic
	//when make square finishes drawing a square, it initializes the inputs again to draw a new square 
	//when the output y input to line drawer is less than the current y1, it increments yLine
	//default case is initialize variables
    always_comb begin
        init = 0; incr = 0;
        case (ps)
            S1: begin
                init = 1;
                ns = S2;
            end
            S2: begin
                if (yLine < curr_y1) begin
                    incr = 1;
                    ns = S2;
                end else begin 
                ns = S1;
                end
                
            end
            default: begin
                ns = S1;
            end
        endcase//ends case statement
    end//ends always_comb

    //updates states
    //runs off of slower clock so a line can finish drawing before a new y value is input
	//when initializes sets outputs to inputs and curr_x1 to input x1
	//when incr, yLine increments 
	always_ff @(posedge divided_clock_Square) begin
        ps <= ns;
        if (init) begin
            yLine <= y0;
            curr_y1 <= y1;
            curr_x0 <= x0;
            curr_x1 <= x1;
            color_line <= color_in;
        end
        if (incr) begin
            yLine <= yLine + 1'b1;
        end

    end//ends always_ff

endmodule //ends module


module makeSquare_testbench();
    logic clk;
    logic [2:0] color_in;
    logic [10:0] x0, x1, y0, y1;
    logic divided_clock_Square;
	 
    logic [10:0] xDraw, yDraw;
    logic [2:0] color_out;

    //set up clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end
    //sets up divided clock input 
    logic [31:0] divided_clocks;
    clock_divider cdiv (.clk, .reset(1'b0), .divided_clocks);
    assign divided_clock_Square = divided_clocks[4];

    makeSquare dut (.*);

    integer i;
    initial begin
        x0 <= 0; y0 <= 0; x1 <= 10; y1 <= 10; color_in <= 3'b000; @(posedge clk);
        for(i = 0; i < 250; i++) begin
                @(posedge clk);
        end
                                                @(posedge clk);
        x0 <= 20; y0 <= 20; x1 <= 40; y1 <= 40;  color_in <= 3'b111; @(posedge clk);
        for(i = 0; i < 400 ; i++) begin
                @(posedge clk);
        end
        $stop;
    end
    
endmodule