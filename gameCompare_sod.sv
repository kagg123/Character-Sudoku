//checks if the users input is the same as the answer key, initalizes answer key input to initalizes squares
//instantiated in De1_Soc
//INPUT SIGNALS
//clk- 50 Mhz clock
//reset,newGame, zero, one, two, three- user input
//card array- recieves input answer key
//OUTPUT SIGNALS
//userinputArray- outputs user an array of the user input variables
// incorrectMatch- indicates there is an incorrect match on the board
// xWrong, yWrong- x and y coordinate of an incorrect match
module gameCompare_sod (incorrectMatch, xWrong, yWrong, zero, one, two, three, clk, reset, newGame, cardArray, locationX, locationY, userInputArray);
    output logic incorrectMatch;
    output logic [1:0] xWrong, yWrong;
    input logic zero, one, two, three, clk, reset, newGame;
    input logic [1:0] locationX, locationY;
    input logic [1:0] cardArray[3:0][3:0];

    output logic [1:0] userInputArray [3:0][3:0];

    //instantiates user Input Array with 0s when reset
    //instantiates diagonal values to the answer key when reset
    // if user hits zero, one, two, or three, the userInputArray at the location the user is in is updated to that value
    always_ff @(posedge clk) begin
        if (reset || newGame) begin
            userInputArray[0][0] <= cardArray[0][0];
            userInputArray[0][1] <= 2'b00;
            userInputArray[0][2] <= 2'b00;
            userInputArray[0][3] <= 2'b00;

            userInputArray[1][0] <= 2'b00;
            userInputArray[1][1] <= cardArray[1][1];
            userInputArray[1][2] <= 2'b00;
            userInputArray[1][3] <= 2'b00;

            userInputArray[2][0] <= 2'b00;
            userInputArray[2][1] <= 2'b00;
            userInputArray[2][2] <= cardArray[2][2];
            userInputArray[2][3] <= 2'b00;

            userInputArray[3][0] <= 2'b00;
            userInputArray[3][1] <= 2'b00;
            userInputArray[3][2] <= 2'b00;
            userInputArray[3][3] <= cardArray[3][3];
        end else begin //if (reset || newGame)
            if (zero) userInputArray[locationY][locationX] <= 2'b00;
            else if (one) userInputArray[locationY][locationX] <= 2'b01;
            else if (two) userInputArray[locationY][locationX] <= 2'b10;
            else if (three) userInputArray[locationY][locationX] <= 2'b11;
        end //else
    end //always_ff
    //sets x and y coordinate of incorrect character and incorrect match
    always_ff @(posedge clk) begin
        if (reset || newGame) begin
            yWrong<= 2'b00;
            xWrong<= 2'b00;
            incorrectMatch <= 0;
        end else if (userInputArray[0][0] != cardArray[0][0]) begin
            yWrong<= 2'b00;
            xWrong<= 2'b00;
            incorrectMatch <= 1;
        end else if (userInputArray[0][1] != cardArray[0][1]) begin
            yWrong<= 2'b00;
            xWrong<= 2'b01;
            incorrectMatch <= 1;
        end else if (userInputArray[0][2] != cardArray[0][2]) begin
            yWrong<= 2'b00;
            xWrong<= 2'b10;
            incorrectMatch <= 1;
        end else if (userInputArray[0][3] != cardArray[0][3]) begin
            yWrong<= 2'b00;
            xWrong<= 2'b11;
            incorrectMatch <= 1;
        end else if (userInputArray[1][0] != cardArray[1][0]) begin
            yWrong<= 2'b01;
            xWrong<= 2'b00;
            incorrectMatch <= 1;
        end else if (userInputArray[1][1] != cardArray[1][1]) begin
            yWrong<= 2'b01;
            xWrong<= 2'b01;
            incorrectMatch <= 1;
        end else if (userInputArray[1][2] != cardArray[1][2]) begin
            yWrong<= 2'b01;
            xWrong<= 2'b10;
            incorrectMatch <= 1;
        end else if (userInputArray[1][3] != cardArray[1][3]) begin
            yWrong<= 2'b01;
            xWrong<= 2'b11;
            incorrectMatch <= 1;
        end else if (userInputArray[2][0] != cardArray[2][0]) begin
            yWrong<= 2'b10;
            xWrong<= 2'b00;
            incorrectMatch <= 1;
        end else if (userInputArray[2][1] != cardArray[2][1]) begin
            yWrong<= 2'b10;
            xWrong<= 2'b01;
            incorrectMatch <= 1;
        end else if (userInputArray[2][2] != cardArray[2][2]) begin
            yWrong<= 2'b10;
            xWrong<= 2'b10;
            incorrectMatch <= 1;
        end else if (userInputArray[2][3] != cardArray[2][3]) begin
            yWrong<= 2'b10;
            xWrong<= 2'b11;
            incorrectMatch <= 1;
        end else if (userInputArray[3][0] != cardArray[3][0]) begin
            yWrong<= 2'b11;
            xWrong<= 2'b00;
            incorrectMatch <= 1;
        end else if (userInputArray[3][1] != cardArray[3][1]) begin
            yWrong<= 2'b11;
            xWrong<= 2'b01;
            incorrectMatch <= 1;
        end else if (userInputArray[3][2] != cardArray[3][2]) begin
            yWrong<= 2'b11;
            xWrong<= 2'b10;
            incorrectMatch <= 1;
        end else if (userInputArray[3][3] != cardArray[3][3]) begin
            yWrong<= 2'b11;
            xWrong<= 2'b11;
            incorrectMatch <= 1; 
        end else begin
			incorrectMatch <= 0; 
		end
    end //always_ff


endmodule //gameCompare_sod

module gameCompare_sod_testbench();
     logic incorrectMatch;
     logic [1:0] xWrong, yWrong;
     logic [1:0] userInputArray [3:0][3:0];
     logic zero, one, two, three, clk, reset, newGame;
     logic [1:0] locationX, locationY;
     logic [1:0] cardArray[3:0][3:0];

    parameter CLOCK_PERIOD = 100;	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
    
    logic char;
    gameSelSod gS (.newGame, .reset, .cardArray, .clk, .char);
    gameCompare_sod gc (.*);

    initial begin
        zero = 0; one = 0; two = 0; three = 0; newGame = 0; reset = 1; locationY = 0;  locationX = 0; @(posedge clk);
       @(posedge clk);@(posedge clk); reset = 0; @(posedge clk);
        
        locationY = 0;  locationX = 1;  three = 1; @(posedge clk); three = 0;
        locationY = 0;  locationX = 2;  two = 1; @(posedge clk); two = 0;
        locationY = 0;  locationX = 3;  one = 1; @(posedge clk); one = 0;

        locationY = 1;  locationX = 0;  two = 1; @(posedge clk); two = 0;
        locationY = 1;  locationX = 2;  zero = 1; @(posedge clk); zero = 0;
        locationY = 1;  locationX = 3;  three = 1; @(posedge clk); three = 0;

        locationY = 2;  locationX = 0;  one = 1; @(posedge clk); one = 0;
        locationY = 2;  locationX = 1;  two = 1; @(posedge clk); two = 0;
        locationY = 2;  locationX = 3;  zero = 1; @(posedge clk); zero = 0;

        locationY = 3;  locationX = 0;  three = 1; @(posedge clk); three = 0;
        locationY = 3;  locationX = 1;  zero = 1; @(posedge clk); zero = 0;
        locationY = 3;  locationX = 2;  one = 1; @(posedge clk); one = 0;
        @(posedge clk); @(posedge clk); @(posedge clk); @(posedge clk); 
        $stop;

    end

endmodule;
