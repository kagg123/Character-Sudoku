//dictates sodoku game logic, initializes new game with new board, determines if user is finished playing,
//sets done to true when user is finished and sets wrong to true is user has mistakes on the board
//instantiated in DE1-SoC
//INPUT SIGNALS 
//check response, resume, reset, newgame, comes from user input 
//clk- set to 50 Mhz
//singlenewGame input from singlePress (when newgame is true singleNewGame is only true for 1 clock cycle)
//incorrectmatch input from gameCompare tells whether there is an incorrect match on the board
//OUTPUT SIGNALS
//cardArray outputs the sodoku answer key for a game
//done output signals user is in S_end state
//wrong output signals when user checked answer it was incorrect
module gamelogic_sod(clk, reset, newGame, singlenewGame, resume, incorrectMatch, checkResponse, cardArray, done, wrong, char);
    input logic clk, reset, newGame, singlenewGame, resume, incorrectMatch, checkResponse;
    output logic [1:0] cardArray [3:0][3:0];
    output logic done;
    output logic wrong;
    output logic char;

    //controller port definitions
    logic invWrong, setWrong;

    //datapath port definitions

    
    //CONTROLLER
    /**********************************************/
    //define state name/variables
    enum {S_idle, S_inputVals, S_compare, S_end} ps, ns;
    //next state logic and controller output assignments
    always_comb begin
        done = 0; setWrong = 0; invWrong = 0;
        case(ps)
            
            S_idle: begin
                invWrong = 1;
                ns = S_inputVals;

            end
            S_inputVals: begin
                if (resume) begin
                    invWrong = 1;
                end 
                
                if (checkResponse) begin
                    ns = S_compare;
                end else begin
                    ns = S_inputVals;
                end
            end

            S_compare:begin
                if (incorrectMatch) begin
                    setWrong = 1;
                    ns = S_inputVals;
                end 
                else begin
                    ns = S_end;
                end
            end
            S_end: begin
                done = 1;
                ns = (reset | newGame) ? S_idle : S_end;
            end
            default: begin
                ns = S_idle;

            end
        endcase

    end //always comb

    //Manages state updates at the positive edge of the clock
    always_ff @(posedge clk) begin
        if(reset | newGame) ps <= S_idle;
        else ps <= ns;
    end //always_ff

    //DATAPATH
    /**********************************************/
    //datapath logic
    gameSelSod gS (.newGame(singlenewGame), .reset, .cardArray, .clk, .char);
    always_ff @(posedge clk) begin
        if (setWrong) wrong <= 1;
        else if (invWrong) wrong <= 0;
        else wrong <= wrong;
    end

endmodule //end gamelogic

module gamelogic_sod_testbench();
    logic clk, reset, newGame, singlenewGame, resume, incorrectMatch, checkResponse;
    logic [1:0] cardArray [3:0][3:0];
    logic done;
    logic wrong;
    logic char;

    //set up clock
	parameter CLOCK_PERIOD = 100;	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
		
	end
    gamelogic_sod dut (.*);

    initial begin
        reset = 1; newGame = 0; singlenewGame = 0; resume = 0; incorrectMatch = 0; checkResponse = 0; 
        @(posedge clk);
        reset = 0; newGame = 1; singlenewGame = 1; @(posedge clk);
        singlenewGame = 0;@(posedge clk);@(posedge clk);
        newGame = 0;@(posedge clk);@(posedge clk);
        incorrectMatch = 1; checkResponse = 1; @(posedge clk);@(posedge clk)
        incorrectMatch = 0; checkResponse = 0; @(posedge clk);@(posedge clk)
        resume = 1; @(posedge clk);
        resume = 0; @(posedge clk);
        incorrectMatch = 0; checkResponse = 1;@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
        newGame = 1; @(posedge clk);@(posedge clk);
        $stop;
    end
//
endmodule
