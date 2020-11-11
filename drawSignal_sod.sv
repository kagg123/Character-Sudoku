//decides what to draw at the moments and outputs draw signals to draw_obj
//instantiated in de1_soc
//INPUT SIGNALS
//takes in reset, newGame, checkResponse, up, left, right, down, zero, one, two, three from user input
//takes in clk 50Mhz
//takes in done and wrong signals from game logic
//OUTPUT SIGNALS- inputs to draw_obj
//drawBoard- indicates draw a board
//drawChar- indicates draw a character next
//drawCharRepeat- indicates draw a character right after a character was drawn (input zero then one, zero then two, etc.)
//drawTracker- indicates draw your tracker
//drawTrackerRepeat- indicates draw tracker after tracker was just drawn (up then down, up then up, etc. )
//drawWrong- indicates draw over an incorrect response
//drawWin- indicates draw the board in win state


module drawSignal_sod(drawBoard, drawChar, drawCharRepeat, drawTracker, drawTrackerRepeat, drawWrong, drawWin,
clk, reset, newGame, checkResponse, up, left, right, down, wrong, zero, one, two, three, done);
    output logic drawBoard, drawChar, drawCharRepeat, drawTracker, drawTrackerRepeat, drawWrong, drawWin;
    input logic clk, reset, newGame, checkResponse, up, left, right, down, wrong, zero, one, two, three, done;

    always_ff @(posedge clk) begin
        if (newGame || reset) begin 
            drawBoard <= 1; drawWrong <= 0; drawCharRepeat <= 0; drawChar <= 0; drawTrackerRepeat <= 0; drawTracker <= 0; drawWin <= 0; 
        end else if (checkResponse & wrong) begin 
            drawBoard <= 0; drawWrong <= 1; drawCharRepeat <= 0; drawChar <= 0; drawTrackerRepeat <= 0; drawTracker <= 0; drawWin <= 0; 
        end else if (drawChar & (zero | one | two | three)) begin 
            drawBoard <= 0; drawWrong <= 0; drawCharRepeat <= 1; drawChar <= 0; drawTrackerRepeat <= 0; drawTracker <= 0; drawWin <= 0; 
        end else if (zero || one || two || three) begin 
            drawBoard <= 0; drawWrong <= 0; drawCharRepeat <= 0; drawChar <= 1; drawTrackerRepeat <= 0; drawTracker <= 0; drawWin <= 0; 
        end else if (drawTracker & (up || left || right || down)) begin
            drawBoard <= 0; drawWrong <= 0; drawCharRepeat <= 0; drawChar <= 0; drawTrackerRepeat <= 1; drawTracker <= 0; drawWin <= 0; 
	    end else if (up || left || right || down) begin 
            drawBoard <= 0; drawWrong <= 0; drawCharRepeat <= 0; drawChar <= 0; drawTrackerRepeat <= 0; drawTracker <= 1; drawWin <= 0; 
        end else if (done) begin
            drawBoard <= 0; drawWrong <= 0; drawCharRepeat <= 0; drawChar <= 0; drawTrackerRepeat <= 0; drawTracker <= 0; drawWin <= 1; 
        end
    end

endmodule 
module drawSignal_sod_testbench ();
    logic drawBoard, drawChar, drawCharRepeat, drawTracker, drawTrackerRepeat, drawWrong, drawWin;
    logic clk, reset, newGame, checkResponse, up, left, right, down, wrong, zero, one, two, three, done;
    
    parameter CLOCK_PERIOD = 100;	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
		
	end
    drawSignal_sod dut (.*);

    integer i;
    initial begin
        reset = 1; newGame = 0; checkResponse = 0; up= 0; left=0; right=0; down=0; wrong=0; zero=0; one=0; two=0; three=0; done=0; 
        @(posedge clk);  reset = 0; 
        //check drawWrong
        checkResponse = 1; wrong = 0; @(posedge clk); 
        wrong = 1; @(posedge clk); checkResponse = 0; wrong = 0;

        //check drawwin
        done = 1; @(posedge clk); done = 0;

        //check drawChar and drawCharRepeat
        zero = 1; @(posedge clk); zero = 0;
        one = 1; @(posedge clk); one = 0;
        two = 1; @(posedge clk); two = 0;
        three = 1; @(posedge clk); three = 0;

        //check drawTracker and drawTrackerRepeat
        up = 1; @(posedge clk); up = 0;
        down = 1; @(posedge clk); down = 0;
        left = 1; @(posedge clk); left = 0;
        right = 1; @(posedge clk); right = 0;

        $stop;
    end
endmodule


