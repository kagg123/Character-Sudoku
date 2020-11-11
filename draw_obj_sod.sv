/* Given a starting coordinate and a draw signal, this module draws the specified object at the starting coordinate
 *
 * Instantiated in DE1_SoC
 * 
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset    - connected to reset
 *   divided_clock_Square- connected to a slower clock to draw square
 *   divided_clock_obj- connected to a clock slower than divided_clock_Square to draw object
 *	 locationX 	- x coordinate of the tracker
 *   locationY 	- y coordinate of the tracker
  *	 xWrong 	- x coordinate of an incorrect response
 *   yWrong 	- y coordinate of an incorrect response
 *   userInputArray	 	- array of the users input into the sodoku
 *   char	 	- specifies whether to draw characters from the first board or the second board
 *  drawTracker, drawTrackerRepeat, drawBoard, drawChar, drawCharRepeat, drawWrong, drawWin,	- signals that specify what to draw/which state to begin drawing in 
 *   up, left, right, down	 	- connected to user input buttons



 *
 * Outputs:
 *   xDraw 		- x coordinate of the pixel
 *   yDraw 		- y coordinate of the pixel 
 *  outputColor - color of the pixel
 *
 */
module draw_obj_sod (clk, reset, xWrong, yWrong, locationX, locationY, divided_clock_obj, divided_clock_Square,  
    drawTracker, drawTrackerRepeat, drawBoard, drawChar, drawCharRepeat, drawWrong, drawWin,  userInputArray, char,
    up, left, right, down,
    xDraw, yDraw, outputColor);
	input logic clk, reset;
    input logic [1:0] locationX, locationY;
    input logic [1:0] xWrong, yWrong;
    input logic divided_clock_obj;
    input logic divided_clock_Square;
    input logic drawTracker, drawTrackerRepeat, drawBoard, drawChar, drawCharRepeat, drawWrong, drawWin, char;   
    input logic [1:0] userInputArray [3:0][3:0];  
    input logic up, left, right, down;
    output logic [10:0] xDraw, yDraw;
    output logic [2:0] outputColor;   
    
    logic [10:0] curr_x0, curr_x1, curr_y0,curr_y1;
    logic dToadette, dPig, dBee, dEvilMinion;
    logic dToad, dMinion, dSpongebob, dPatrick;
    logic dToadInit, dMinionInit, dSpongebobInit, dPatrickInit;
    logic dToadetteInit, dEvilMinionInit, dBeeInit, dPigInit;

    logic [1:0] j, k;
    logic [1:0] m;
    logic [10:0] xLeft, yLeft;
    logic initSod;

    logic [10:0] xSet, ySet, xSetPrev, ySetPrev, xSetWrong, ySetWrong;

    //define x set and y set based on the grid location
    //update previous x set when location is changed so tracker can erase the old tracker before drawing a new one
	always_ff @(posedge clk) begin
		if (up || left || right || down) begin
			xSetPrev <= xSet;
			ySetPrev <= ySet;
		end
	end
	assign xSet = 10 + locationX*40;
	assign ySet = 10 + locationY*40;
	assign xSetWrong = 10 + xWrong*40;
	assign ySetWrong = 10 + yWrong*40;
       always_comb begin
        if (initSod) begin
            xLeft = 10 + 40*m;
            yLeft = 10 + 40*m;
        end else begin
            xLeft = xSet;
            yLeft = ySet;
        
        end
    end

    //assign draw signals for which characters to draw when initializing the sodoku board
    assign dToadetteInit = initSod && (userInputArray[m][m] == 2'b00)&& char;
    assign dEvilMinionInit = initSod && (userInputArray[m][m] == 2'b01)&& char;
    assign dBeeInit = initSod && (userInputArray[m][m] == 2'b10)&& char;
    assign dPigInit = initSod && (userInputArray[m][m] == 2'b11)&& char;

    assign dToadInit = initSod && (userInputArray[m][m] == 2'b00) && ~char;
    assign dMinionInit = initSod && (userInputArray[m][m] == 2'b01) && ~char;
    assign dSpongebobInit = initSod && (userInputArray[m][m] == 2'b10)&& ~char;
    assign dPatrickInit = initSod && (userInputArray[m][m] == 2'b11)&& ~char;

    //assign draw signals for specific characters
    assign dToadette = ( (drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b00) && char) || dToadetteInit;
    assign dPig =( (drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b01) && char) || dPigInit;
    assign dBee = ( (drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b10) && char) || dBeeInit;
    assign dEvilMinion = ( (drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b11) && char) || dEvilMinionInit;

    assign dToad = ( (drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b00) && ~char) || dToadInit;
    assign dMinion = ( (drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b01) && ~char) || dMinionInit;
    assign dSpongebob = ((drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b10) && ~char) || dSpongebobInit;
    assign dPatrick = ( (drawChar || drawCharRepeat) && (userInputArray[locationY][locationX] == 2'b11) && ~char) || dPatrickInit;
	 

    logic [2:0] color;
    logic setjk, incrjk, setm, incrm, intitialize, setinit, zeroInit;
    enum {S_resetboard, S_board, S_boardincr, S_drawChar1, S_drawChar2, S_drawChar3, 
    S_drawChar4, S_drawChar5, S_drawChar6, S_drawChar7, S_drawChar7Repeat, S_boardDivide1, S_init1, S_init2, S_init3,
    S_boardDivide2, S_tracker, S_tracker2, S_trackerRepeat, S_trackerRepeat2, S_hide1, S_hide2, S_hide3, S_drawWin, S_drawWin2, S_drawWin3, S_drawWin4} ps, ns;
    
    
    //instantiate makesquare
    //input x0, y0, x1, y1, to make square as the currx-. xurrx1, curry0, curry1
    makeSquare ms (.x0(curr_x0), .y0(curr_y0), .x1(curr_x1), .y1(curr_y1), .clk, .xDraw, .yDraw, .color_in(color), .color_out(outputColor), .divided_clock_Square);
    
    //update state at the slowest clock to allow for square to finish before drawing a new one
    //initalize control variables
    always_ff @(posedge divided_clock_obj )begin
        if(reset) begin
			ps <= S_resetboard;
            initSod = 0;
        end 
        else begin
		  ps <= ns;
		end
        if (setm) begin m <= 2'b00; end
        else if (incrm) begin m <= m + 1; end
        if (setinit) begin initSod <= 1; end
        else if (zeroInit) begin initSod <= 0; end
         if (setjk) begin 
            j <= 1'b0;
            k <= 1'b0;
         end
         if (incrjk) begin
             j <= j + 1'b1;
             if (j == 2'b11) k <= k + 1'b1;
         end

    end
	 
    always_comb begin
        setjk = 0; incrjk = 0; setm = 0; incrm = 0; zeroInit = 0; setinit = 0; //default control variables
        
        case (ps) 
            //when drawing the voard first cover in black 
            S_resetboard:begin
				ns = S_board;
                color = 3'b000; //black
                curr_x0 = 0;
                curr_y0 = 0;
                curr_x1 = 160;
                curr_y1 = 160;
			end
            S_board:begin
				ns = S_boardDivide1;
                color = 3'b111; //white
                curr_x0 = 10;
                curr_y0 = 10;
                curr_x1 = 40;
                curr_y1 = 40;
                setjk = 1;
			end
            S_boardDivide1:begin
				ns = S_boardDivide2;
                color = 3'b101; //purple
                curr_x0 = 83;
                curr_x1 = 86 ;
                curr_y0 = 10;
                curr_y1 = 160;
			end
            S_boardDivide2:begin
				ns = S_boardincr;
                color = 3'b101; //purple
                curr_x0 = 10;
                curr_x1 = 160;
                curr_y0 = 83;
                curr_y1 = 86;

			end
            S_boardincr:begin
				color = 3'b111;
                curr_x0 = 10 + j*40;
                curr_y0 = 10 + k*40;
                curr_x1 = 40 + j*40;
                curr_y1 = 40 + k*40;
                incrjk = 1;
                if (j == 2'b11 && k == 2'b11) ns = S_init1;
                else ns = S_boardincr;
			end
            S_init1: begin
                color = 3'b000;
                curr_x0 = 0;
                curr_x1 = 1;
                curr_y0 = 0;
                curr_y1 = 1;
                setm = 1;
                setinit = 1;
                ns = S_drawChar1;
			end
            S_init2: begin
                color = 3'b000;
                curr_x0 = 0;
                curr_x1 = 1;
                curr_y0 = 0;
                curr_y1 = 1;
                incrm = 1;
                if (m == 2'b11) ns = S_init3;
                else ns = S_drawChar1;
			end
            S_init3: begin
                color = 3'b000;
                curr_x0 = 0;
                curr_x1 = 1;
                curr_y0 = 0;
                curr_y1 = 1;
                setm = 1;
				zeroInit = 1;
                if (drawTracker) ns = S_tracker;
                else if (drawChar || drawCharRepeat) ns = S_drawChar1;
				else if (drawWrong) ns = S_hide1;
                else if (drawWin) ns <= S_drawWin;
                else ns = S_init3;
            end
            S_drawChar1:begin
                ns = S_drawChar2;
                curr_x0 = xLeft;
                curr_x1 = xLeft+ 5'd30;
                curr_y0 = yLeft;
                curr_y1 = yLeft + 5'd30;
                if (dToad) color = 3'b100;//red helmet
                else if (dToadette || dPatrick || dPig) color = 3'b011;//pink helmet
                else if (dMinion || dBee || dSpongebob) color = 3'b110; //yellow sponge/cody
                else color = 3'b101; //purple if evil minion

            end
            S_drawChar2:begin
                ns = S_drawChar3;
                if (dPig) begin
                    curr_x0 = xLeft + 5'd15;
                    curr_x1 = xLeft+ 5'd25;
                    curr_y0 = yLeft + 5'd15;
                    curr_y1 = yLeft + 5'd25;
                end else if (dMinion || dEvilMinion) begin
                    curr_x0 = xLeft + 5'd10;
                    curr_x1 = xLeft+ 5'd20;
                    curr_y0 = yLeft + 5'd14;
                    curr_y1 = yLeft + 5'd30;
                end
                else begin
                    curr_x0 = xLeft;
                    curr_x1 = xLeft+ 5'd30;
                    if (dBee) begin  //first stripe
                        curr_y0 = yLeft+ 5'd10; 
                        curr_y1 = yLeft + 5'd14; 
                    end else begin 
                        curr_y0 = yLeft+ 5'd20;
                        curr_y1 = yLeft + 5'd30;
                    end
                end
                if (dToad || dToadette || dSpongebob) color = 3'b111; //white face fpr Toad/Toaddette white shirt for spongebob
                else if (dPatrick) color = 3'b010; //green pants for patrick
                else if (dEvilMinion || dBee) color = 3'b000; //black overalls for minion black stripe for bee
                else if (dPig) color = 3'b100; //red snout for pig
                else color = 3'b001; //blue overalls for minion
            end
            S_drawChar3:begin
                ns = S_drawChar4;
                if (dToad || dToadette) begin
                    color = 3'b111; //white helmet spot
                    curr_x0 = xLeft + 5'd2;
                    curr_y0 = yLeft + 5'd2;
                    curr_x1 = xLeft+ 5'd15;
                    curr_y1 = yLeft + 5'd15;
                end else if (dMinion || dEvilMinion) begin
                    color = 3'b000; //black goggles band
                    curr_x0 = xLeft;
                    curr_x1 = xLeft+ 5'd30;
                    curr_y0 = yLeft + 5'd4;
                    curr_y1 = yLeft + 5'd6;
                end
                else if (dPatrick) begin
                    color = 3'b101; //purple pant spot
                    curr_x0 = xLeft + 5'd2;
                    curr_x1 = xLeft + 5'd6;
                    curr_y0 = yLeft + 5'd20;
                    curr_y1 = yLeft+ 5'd26;
                end
                else if (dSpongebob || dBee) begin //bee bottom stripe
                    color = 3'b000; //black 
                    curr_x0 = xLeft;
                    curr_x1 = xLeft+ 5'd30;
                    curr_y0 = yLeft+ 5'd26;
                    curr_y1 = yLeft + 5'd30; 
                end else begin
                    color = 3'b000; //black pig snout
                    curr_x0 = xLeft + 5'd17;
                    curr_x1 = xLeft+ 5'd19;
                    curr_y0 = yLeft+ 5'd18;
                    curr_y1 = yLeft + 5'd23; 
                end

            end

            S_drawChar4:begin
                ns = S_drawChar5;
                if (dToad || dToadette) begin
                    color = 3'b111; //white helmet spot
                    curr_x0 = xLeft+ 5'd19;
                    curr_y0 = yLeft + 5'd10;
                    curr_x1 = xLeft+ 5'd28;
                    curr_y1 = yLeft + 5'd17;
                end else if (dMinion || dEvilMinion) begin
                    color = 3'b000; //black smile
                    curr_x0 = xLeft + 5'd11;
                    curr_x1 = xLeft+ 5'd19;
                    curr_y0 = yLeft + 5'd10;
                    curr_y1 = yLeft + 5'd11;
                end else if (dPatrick) begin
                    color = 3'b101; //purple pant spot
                    curr_x0 = xLeft + 5'd15;
                    curr_x1 = xLeft + 5'd25;
                    curr_y0 = yLeft + 5'd24;
                    curr_y1 = yLeft+ 5'd28;
                end else if (dSpongebob) begin
                    color = 3'b100; //red tie
                    curr_x0 = xLeft + 5'd14;
                    curr_x1 = xLeft + 5'd16;
                    curr_y0 = yLeft + 5'd20;
                    curr_y1 = yLeft+ 5'd28;
                end else if (dBee) begin 
                    color = 3'b000;  //black middle stripe
                    curr_x0 = xLeft; 
                    curr_x1 = xLeft+ 5'd30;
                    curr_y0 = yLeft+ 5'd18;
                    curr_y1 = yLeft + 5'd22; 
                end else begin
                    color = 3'b000; //black pig snout
                    curr_x0 = xLeft + 5'd21;
                    curr_x1 = xLeft+ 5'd23;
                    curr_y0 = yLeft+ 5'd18;
                    curr_y1 = yLeft + 5'd23; 
                end
            end
            S_drawChar5:begin
                ns = S_drawChar6;
                if (dMinion || dEvilMinion) begin //draw center white eye
                    curr_x0 = xLeft+ 5'd12;
                    curr_x1 = xLeft+ 5'd18;
                    curr_y0 = yLeft + 5'd2;
                    curr_y1 = yLeft + 5'd8;
                    color = 3'b111; //white pupil
                end else begin  //draw right eye
                    curr_x0 = xLeft+ 5'd18;
                    curr_x1 = xLeft+ 5'd22;
                    if (dToad || dToadette) begin
                        curr_y0 = yLeft + 5'd22;
                        curr_y1 = yLeft + 5'd28;
                    end else begin
                        curr_y0 = yLeft + 5'd5;
                        curr_y1 = yLeft + 5'd11;
                    end
                    color = 3'b000; //black eye
                end 
            end
            S_drawChar6:begin
                if (dMinion || dEvilMinion) begin //draw pupil
                    curr_x0 = xLeft+ 5'd14;
                    curr_x1 = xLeft+ 5'd16;
                    curr_y0 = yLeft + 5'd3;
                    curr_y1 = yLeft + 5'd7;
                end
                else begin  //draw right eye
                    curr_x0 = xLeft+ 5'd8;
                    curr_x1 = xLeft+ 5'd12;
                    if (dToad || dToadette) begin 
                        curr_y0 = yLeft + 5'd22;
                        curr_y1 = yLeft + 5'd28;
                    end else begin
                        curr_y0 = yLeft + 5'd5;
                        curr_y1 = yLeft + 5'd11;
                    end
                end
                color = 3'b000; //black eyes
                if (drawChar) ns = S_drawChar7;
                else ns = S_drawChar7Repeat;
            end
            S_drawChar7: begin
                color = 3'b000;
                curr_x0 = 0;
                curr_x1 = 1;
                curr_y0 = 0;
                curr_y1 = 1;
                if (initSod) ns = S_init2;
                else if (drawTracker) ns = S_tracker;
                else if (drawBoard) ns = S_resetboard;
                else if (drawWrong) ns = S_hide1;
                else if (drawCharRepeat) ns = S_drawChar1;
                else if (drawWin) ns <= S_drawWin;
                else ns = S_drawChar7;
            end
            S_drawChar7Repeat:begin
                color = 3'b000;
                curr_x0 = 0;
                curr_x1 = 1;
                curr_y0 = 0;
                curr_y1 = 1;
                if (initSod) ns = S_init2;
                else if (drawTracker) ns = S_tracker;
                else if (drawBoard) ns = S_resetboard;
                else if (drawWrong) ns = S_hide1;
                else if (drawChar) ns = S_drawChar1;
                else if (drawWin) ns <= S_drawWin;
                else ns = S_drawChar7Repeat;
            end

           S_hide1: begin
               color = 3'b111; //white erase previous card
               curr_x0 = xSetWrong;
               curr_x1 = xSetWrong + 5'd30;
               curr_y0 = ySetWrong;
               curr_y1 = ySetWrong + 5'd30;
               if (drawBoard) ns = S_resetboard;
               else if (drawChar || drawCharRepeat) ns = S_drawChar1;
               else if (drawTracker) ns = S_tracker;
               else if (drawWin) ns <= S_drawWin;
               else ns = S_hide1;
           end

            S_tracker: begin
                color = 3'b000; //black erase previous tracker
                curr_x0 = xSetPrev - 5'd3;
                curr_x1 = xSetPrev;
                curr_y0 = ySetPrev;
                curr_y1 = ySetPrev + 5'd30;
                if (drawTracker) ns = S_tracker2;
                else ns = S_trackerRepeat2;
            end
            S_tracker2: begin
                color = 3'b010; //green draw new tracker
                curr_x0 = xSet - 5'd3;
                curr_x1 = xSet;
                curr_y0 = ySet;
                curr_y1 = ySet + 5'd30;
                ns = S_tracker2;
                if (drawBoard) ns = S_resetboard;
                else if (drawChar || drawCharRepeat) ns = S_drawChar1;
				else if (drawWrong) ns = S_hide1;
                else if (drawTrackerRepeat) ns = S_tracker;
                else if (drawWin) ns <= S_drawWin;
                else ns = S_tracker2;
            end
            S_trackerRepeat2: begin
                color = 3'b010; //green draw new tracker
                curr_x0 = xSet - 5'd3;
                curr_x1 = xSet;
                curr_y0 = ySet;
                curr_y1 = ySet + 5'd30;
                ns = S_tracker2;
                if (drawBoard) ns = S_resetboard;
                else if (drawChar || drawCharRepeat) ns = S_drawChar1;
				else if (drawWrong) ns = S_hide1;
                else if (drawTracker) ns = S_tracker;
                else if (drawWin) ns <= S_drawWin;
                else ns = S_trackerRepeat2;
            end
            S_drawWin: begin
                color = 3'b101; //yellow draw new tracker
                curr_x0 = 0;
                curr_x1 = 160;
                curr_y0 = 0;
                curr_y1 = 160;
                ns = S_drawWin2;
            end
            S_drawWin2: begin
                color = 3'b000; //yellow draw new tracker
                curr_x0 = 55;
                curr_x1 = 65;
                curr_y0 = 20;
                curr_y1 = 60;
                ns = S_drawWin3;
            end
            S_drawWin3: begin
                color = 3'b000; //yellow draw new tracker
                curr_x0 = 95;
                curr_x1 = 105;
                curr_y0 = 20;
                curr_y1 = 60;
                ns = S_drawWin4;
            end
            S_drawWin4: begin
                color = 3'b000; //yellow draw new tracker
                curr_x0 = 40;
                curr_x1 = 120;
                curr_y0 = 110;
                curr_y1 = 120;
                if (drawBoard) ns = S_resetboard;
                else ns = S_drawWin4;
            end
			default: begin
				color = 3'b000;
                curr_x0 = 0;
                curr_y0 = 0;
                curr_x1 = 160;
                curr_y1 = 160;
                ns = S_resetboard;
			end
        endcase  //ends case statesments

    end //always_comb block

endmodule
module draw_obj_sod_testbench();
     logic clk, reset;
     logic [1:0] locationX, locationY;
     logic [1:0] xWrong, yWrong;
     logic divided_clock_obj;
     logic divided_clock_Square;
     logic drawTracker, drawTrackerRepeat, drawBoard, drawChar, drawCharRepeat, drawWrong, drawWin, char;   
     logic [1:0] userInputArray [3:0][3:0];  
     logic up, left, right, down;
     logic [10:0] xDraw, yDraw;
     logic [2:0] outputColor; 

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
    assign divided_clock_obj = divided_clocks[6];

    draw_obj_sod dut (.*);

    integer i;
    initial begin
        locationX <= 0; locationY <= 0; xWrong <= 2; yWrong <= 3;
        {drawTracker, drawTrackerRepeat, drawChar, drawCharRepeat, drawWrong, drawWin, char} = 7'b000_0000;
        userInputArray[0][0] <= 2'b00;
        userInputArray[0][1] <= 2'b11;
        userInputArray[0][2] <= 2'b00;
        userInputArray[0][3] <= 2'b00;

        userInputArray[1][0] <= 2'b00;
        userInputArray[1][1] <= 2'b11;
        userInputArray[1][2] <= 2'b00;
        userInputArray[1][3] <= 2'b00;

        userInputArray[2][0] <= 2'b00;
        userInputArray[2][1] <= 2'b00;
        userInputArray[2][2] <= 2'b11;
        userInputArray[2][3] <= 2'b00;

        userInputArray[3][0] <= 2'b00;
        userInputArray[3][1] <= 2'b00;
        userInputArray[3][2] <= 2'b00;
        userInputArray[3][3] <= 2'b11;
        {up, left, right, down} = 4'b0000;
        reset = 0;
        drawBoard = 1;
        for(i = 0; i < 15000; i++) begin
                @(posedge clk);
        end
                                                @(posedge clk);
        drawBoard = 0; drawTracker = 1; down = 1; @(posedge clk); 
        locationY = 1;down = 0;
        for(i = 0; i < 1000 ; i++) begin
                @(posedge clk);
        end
        $stop;
    end
    
endmodule