//taken from 271 lab
//Establishes appropriate inputs and outputs for a pair of d-flipflops to combat metastability issues
module metaEleven (clk, d1, q2, reset);
	input logic clk, reset;
	input logic [10:0] d1;
	output logic [10:0] q2;
	logic [10:0] q1;	

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
