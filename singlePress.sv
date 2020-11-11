module singlePress(press, clk, keyVal);

	input logic clk, keyVal;
	output logic press;
	logic flop1, flop2, flop3;
	
	always_ff @(posedge clk) begin
		flop1 <= keyVal;
		flop2 <= flop1;
		flop3 <= flop2;
	end 
	
	assign press = ~flop3 & flop2;
	
	
endmodule
