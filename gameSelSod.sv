//initializes sodoku answer key, updates answer key when new game is selected
//instantiated in gamelogic_sod
//INPUT SIGNALS
//clk- 50Mhz
//user input reset
//newgame receives singlenewgame from singlepress to ensure its only true for one clock cycle when the user clicks 
//OUTPUT 
//cardArray- outputs current sodoku answer key
//char- outputs whether we'll be using character from board 1 (toad, minion, spongebob, patrick) or chacters from board2 (evilminion, toadette, bee, pig)
module gameSelSod(newGame, reset, cardArray, clk, char);
    input logic newGame, reset, clk;    
    output logic [1:0] cardArray [3:0][3:0];
    output logic char;

    logic [1:0] gameCount;

    //
    always_comb begin
        case(gameCount)
            2'b00: begin
                //row 1
                cardArray[0][0] <= 2'd0;
                cardArray[0][1] <= 2'd3;
                cardArray[0][2] <= 2'd2;
                cardArray[0][3] <= 2'd1;
                //row 2
                cardArray[1][0] <= 2'd2;
                cardArray[1][1] <= 2'd1;
                cardArray[1][2] <= 2'd0;
                cardArray[1][3] <= 2'd3;
                //row 3
                cardArray[2][0] <= 2'd1;
                cardArray[2][1] <= 2'd2;
                cardArray[2][2] <= 2'd3;
                cardArray[2][3] <= 2'd0;
                //row 4
                cardArray[3][0] <= 2'd3;
                cardArray[3][1] <= 2'd0;
                cardArray[3][2] <= 2'd1;
                cardArray[3][3] <= 2'd2;
                char <= 0;
            end
            2'b01: begin
                //row 1
                cardArray[0][0] <= 2'd1;
                cardArray[0][1] <= 2'd3;
                cardArray[0][2] <= 2'd0;
                cardArray[0][3] <= 2'd2;
                //row 2
                cardArray[1][0] <= 2'd0;
                cardArray[1][1] <= 2'd2;
                cardArray[1][2] <= 2'd1;
                cardArray[1][3] <= 2'd3;
                //row 3
                cardArray[2][0] <= 2'd2;
                cardArray[2][1] <= 2'd0;
                cardArray[2][2] <= 2'd3;
                cardArray[2][3] <= 2'd1;
                //row 4
                cardArray[3][0] <= 2'd3;
                cardArray[3][1] <= 2'd1;
                cardArray[3][2] <= 2'd2;
                cardArray[3][3] <= 2'd0;

                char <= 1;
            end
            2'b10: begin
                //row 1
                cardArray[0][0] <= 2'd2;
                cardArray[0][1] <= 2'd1;
                cardArray[0][2] <= 2'd3;
                cardArray[0][3] <= 2'd0;
                //row 2
                cardArray[1][0] <= 2'd3;
                cardArray[1][1] <= 2'd0;
                cardArray[1][2] <= 2'd2;
                cardArray[1][3] <= 2'd1;
                //row 3
                cardArray[2][0] <= 2'd1;
                cardArray[2][1] <= 2'd3;
                cardArray[2][2] <= 2'd0;
                cardArray[2][3] <= 2'd2;
                //row 4
                cardArray[3][0] <= 2'd0;
                cardArray[3][1] <= 2'd2;
                cardArray[3][2] <= 2'd1;
                cardArray[3][3] <= 2'd3;

                char <= 0;
            end
            2'b11: begin
                //row 1
                cardArray[0][0] <= 2'd0;
                cardArray[0][1] <= 2'd2;
                cardArray[0][2] <= 2'd3;
                cardArray[0][3] <= 2'd1;
                //row 2
                cardArray[1][0] <= 2'd3;
                cardArray[1][1] <= 2'd1;
                cardArray[1][2] <= 2'd0;
                cardArray[1][3] <= 2'd2;
                //row 3
                cardArray[2][0] <= 2'd2;
                cardArray[2][1] <= 2'd0;
                cardArray[2][2] <= 2'd1;
                cardArray[2][3] <= 2'd3;
                //row 4
                cardArray[3][0] <= 2'd1;
                cardArray[3][1] <= 2'd3;
                cardArray[3][2] <= 2'd2;
                cardArray[3][3] <= 2'd0;

                char <= 1;
            end
        endcase  //ends case statement

    end//ends always comf

    //updates game count
    always_ff @(posedge clk) begin
        if (reset) gameCount <= 2'b00;
        else if (newGame) gameCount <= gameCount + 1'b1;

    end


endmodule //ends gameSelSod module

module gameSelSod_testbench();
    logic newGame, reset, clk;    
    logic [1:0] cardArray [3:0][3:0];
    logic char;

    //set up clock
	parameter CLOCK_PERIOD = 100;	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
		
	end
    gameSelSod dut (.*);

    initial begin
        reset = 1; newGame = 0; @(posedge clk); @(posedge clk);
        reset = 0; newGame = 1; @(posedge clk); @(posedge clk);@(posedge clk);
        $stop;
    end
//
endmodule
