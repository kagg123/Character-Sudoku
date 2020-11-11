//Overall function: Character Sudoku System that connects the game logic with VGA display, Audio, and Keyboard input
//Module ports: Inputs: Switches (SW) to control reset, clocks (timing), audio driver inputs, keyborad driver inouts
//					 Outputs: HEX and LEDR for display, VGA driver outputs
//Connections: Connects all modules related to the game system together.
module DE1_SoC_sod (CLOCK_50, CLOCK2_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, GPIO_0, KEY, LEDR, SW,
VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, PS2_DAT, PS2_CLK, FPGA_I2C_SCLK, 
FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    output logic [35:0] GPIO_0;
	output logic AUD_DACDAT;
	output logic FPGA_I2C_SCLK;
	output logic AUD_XCK;
	inout logic FPGA_I2C_SDAT;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
    input logic CLOCK_50, CLOCK2_50;
    input logic [3:0] KEY;
    input logic [9:0] SW;
    output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	inout PS2_DAT, PS2_CLK;	
	
	logic reset;
	logic [10:0] xSet, ySet, xDraw, yDraw, xDrawmeta, yDrawmeta, x, y;
	logic [2:0] outcolor, outcolormeta;
	logic [1:0] locationX, locationY, xWrong, yWrong;
   	logic [1:0] cardArray [3:0][3:0];
	logic [1:0] userInputArray [3:0][3:0];
	logic drawBoard, drawChar, drawCharRepeat, drawTracker, drawTrackerRepeat, drawWrong, drawWin, singlenewGame;
	logic done, wrong, incorrectMatch;

	//keyboard logic
	logic [7:0] outcode;
    logic makeBreak;
    logic valid; 
    logic G, spaceBar, R, upA, downA, leftA, rightA, zeroK, oneK, twoK, threeK;
	logic newGame, checkResponse, resume, zero, one, two, three, up , down, left, right, char;
	logic zerometa, onemeta, twometa, threemeta, upmeta, leftmeta, rightmeta, downmeta;

	//audio logic
	logic read_ready, write_ready, read, write;
	logic signed [23:0] readdata_left, readdata_right;
	logic signed [23:0] writedata_left, writedata_right;

	//clock divider set up
	logic [31:0] divided_clocks;
	logic divided_clock_obj, divided_clock_Square;
    clock_divider cdiv (.clk(CLOCK_50), .reset(1'b0), .divided_clocks);

	//Modelsim Clocks
	assign divided_clock_obj = divided_clocks[8];
	assign divided_clock_Square = divided_clocks[4];    
	 
    //Quartus Clocks
	// assign divided_clock_obj = divided_clocks[18];
    // assign divided_clock_Square = divided_clocks[7];

	//metastability for reset
	meta resetMt (.clk(CLOCK_50), .d1(SW[9]), .q2(reset), .reset(SW[5]));	

    /**************************************************************/
    /*                         KEYBOARD                           */
    /**************************************************************/    

    keyboard_press_driver board(.CLOCK_50(CLOCK_50), .valid(valid), .makeBreak(makeBreak), .outCode(outcode),
	.PS2_DAT(PS2_DAT), .PS2_CLK(PS2_CLK), .reset(1'b0));   
    
	//Keyboard driver output logic 
    assign G = (makeBreak && (outcode == 8'h34));	
    assign upA = (makeBreak && (outcode == 8'h75));
    assign downA = (makeBreak && (outcode == 8'h72));
    assign leftA = (makeBreak && (outcode == 8'h6B));
    assign rightA = (makeBreak && (outcode == 8'h74));
    assign zeroK = (makeBreak && (outcode == 8'h45));
    assign oneK = (makeBreak && (outcode == 8'h16));
    assign twoK = (makeBreak && (outcode == 8'h1E));
    assign threeK = (makeBreak && (outcode == 8'h26)); 
	assign spaceBar  = (makeBreak && (outcode == 8'h29));
    assign R = (makeBreak && (outcode == 8'h2D));

	//Metastability for keyboard
	meta mT1(.clk(CLOCK_50), .d1(G), .q2(newGame), .reset); //G
	meta mT2(.clk(CLOCK_50), .d1(upA), .q2(upmeta), .reset); //UpA
	meta mT3(.clk(CLOCK_50), .d1(downA), .q2(downmeta), .reset); //DownA
	meta mT4(.clk(CLOCK_50), .d1(leftA), .q2(leftmeta), .reset); //LeftA
	meta mT5(.clk(CLOCK_50), .d1(rightA), .q2(rightmeta), .reset); //RightA
	meta mT6(.clk(CLOCK_50), .d1(zeroK), .q2(zerometa), .reset); //Key 0
	meta mT7(.clk(CLOCK_50), .d1(oneK), .q2(onemeta), .reset); //Key 1
	meta mT8(.clk(CLOCK_50), .d1(twoK), .q2(twometa), .reset); //Key 2
	meta mT9(.clk(CLOCK_50), .d1(threeK), .q2(threemeta), .reset); //Key 3
	meta mT10(.clk(CLOCK_50), .d1(spaceBar), .q2(checkResponse), .reset); //spaceBar
	meta mT11(.clk(CLOCK_50), .d1(R), .q2(resume), .reset); //R	

	//single press for keyboard
	singlePress sp1 (.press(singlenewGame), .clk(CLOCK_50), .keyVal(newGame));
	singlePress sp2 (.press(up), .clk(CLOCK_50), .keyVal(upmeta));
	singlePress sp3 (.press(down), .clk(CLOCK_50), .keyVal(downmeta));
	singlePress sp4 (.press(left), .clk(CLOCK_50), .keyVal(leftmeta));
	singlePress sp5 (.press(right), .clk(CLOCK_50), .keyVal(rightmeta));
	singlePress sp6 (.press(zero), .clk(CLOCK_50), .keyVal(zerometa));
	singlePress sp7 (.press(one), .clk(CLOCK_50), .keyVal(onemeta));
	singlePress sp8 (.press(two), .clk(CLOCK_50), .keyVal(twometa));
	singlePress sp9 (.press(three), .clk(CLOCK_50), .keyVal(threemeta));
    

    draw_obj_sod dObj (.clk(CLOCK_50), .reset, .xWrong, .yWrong, .locationX, .locationY, .divided_clock_obj, .divided_clock_Square,  
    .drawTracker, .drawTrackerRepeat, .drawBoard, .drawChar, .drawCharRepeat, .drawWrong, .drawWin,  .userInputArray, .char, .up, .left, .right, .down,
    .xDraw, .yDraw, .outputColor);

	metaEleven mT1(.clk(CLOCK_50), .d1(xDrawmeta), .q2(xDraw), .reset);
	metaEleven mT2(.clk(CLOCK_50), .d1(yDrawmeta), .q2(yDraw), .reset);

	drawSignal_sod dS (.drawBoard, .drawChar, .drawCharRepeat, .drawTracker, .drawTrackerRepeat, .drawWrong, .drawWin,
	.clk(CLOCK_50), .reset, .newGame, .checkResponse, .up, .left, .right, .down, .wrong, .zero, .one, .two, .three, .done);
    
    gamelogic_sod gl (.clk(CLOCK_50), .reset, .newGame, .singlenewGame,  .resume, .incorrectMatch, .checkResponse, .cardArray, .done, .wrong, .char);
	gameCompare_sod compare (.incorrectMatch, .xWrong, .yWrong, .zero, .one, .two, .three, .clk(CLOCK_50), 
	.reset, .newGame, .cardArray, .locationX, .locationY, .userInputArray);
	
	cardTracker cTrack (.up, .down, .left, .right, .reset, .clk(CLOCK_50), .locationX, .locationY);
	
	//LEDR light display when game is done
	always_ff @(posedge divided_clocks[20]) begin
		if (~done || (ledLights == 0)) begin
			ledLights  <= 10'b10_0000_0000;
		end 
		else begin
			ledLights <= ledLights >>  1;
		end
		
	end //end always_ff
	assign LEDR[9:0] = ledLights;

	//HEX lights display
	always_comb begin
		if(done) begin
			HEX5 = 7'b0010001; //Y
			HEX4 = 7'b0001000; //A
			HEX3 = 7'b0010001; //Y
		end else begin
			HEX5 = 7'b1111111; 
			HEX4 = 7'b1111111; 
			HEX3 = 7'b1111111; 
		end
		HEX2 = 7'b1111111; 
		HEX1 = 7'b1111111; 
		HEX0 = 7'b1111111; 
	end //end always_comb

	//manages drawing coordinates
	always_comb begin
		if (reset) begin
			x = 0;
			y = 0; 
		end
		else begin
			x  = xDraw;
			y = yDraw;
		end
	end //end always_comb

	/**************************************************************/
    /*                         VGA                                */
    /**************************************************************/

	VGA_framebuffer fb (
		.clk50			(CLOCK_50), 
		.reset			(1'b0), 
		.x, 
		.y,
		.pixel_color	(outcolor), //sets color to white when reset is off and the next color state in animation is white
		.pixel_write	(1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N), 
		.VGA_SYNC_n		(VGA_SYNC_N));

	metaColor mT3(.clk(CLOCK_50), .d1(outcolormeta), .q2(outcolor), .reset);    

    /**************************************************************/
    /*                         AUDIO                              */
    /**************************************************************/	
	
	clock_generator my_clock_gen(
		CLOCK2_50,
		reset,
		AUD_XCK
	);

	audio_and_video_config cfg(
		CLOCK_50,
		reset,
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		CLOCK_50,
		reset,
		read,	
		write,
		writedata_left, 
		writedata_right,
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);    

	assign writedata_left = readdata_left; 
	assign writedata_right = readdata_right; 
	assign read = read_ready && done;		
	assign write = write_ready && done;	
   
endmodule //end DE1_soc module

module DE1_SoC_testbench ();
 logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
 logic [9:0] LEDR;
 logic [35:0] GPIO_0;
 logic CLOCK_50;
 logic [3:0] KEY;
 logic [9:0] SW;
 logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;

	//set up clock
 parameter CLOCK_PERIOD=100;
 initial begin
     CLOCK_50 <= 0;
     forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
 end

 integer i;
 DE1_SoC_sod dut (.*);
 initial begin 
     SW[9] <= 1; SW[8] = 0;SW[7] = 0; KEY[0] <= 1;KEY[1] <= 1;KEY[2] <= 1;KEY[3] <= 1;
	 SW[0] = 0; SW[1] = 0; SW[2] = 0; SW[3] = 0;
	  @(posedge CLOCK_50); @(posedge CLOCK_50);
     
     SW[9] <= 0;    //test reset (board, init and drawChar)
     for (i = 0; i < 60000; i++) begin
         @(posedge CLOCK_50);
     end

	 KEY[0] <= 0; //test tracker
	 for (i = 0; i < 10000; i++) begin
         @(posedge CLOCK_50);
     end KEY[0] <= 1;

	KEY[1] <= 0; //test tracker repeat
	 for (i = 0; i < 10000; i++) begin
         @(posedge CLOCK_50);
     end KEY[1] <= 1;

	 SW[0] <= 1;    //drawChar
     for (i = 0; i < 10000; i++) begin
         @(posedge CLOCK_50);
     end SW[0] <= 0;

	 SW[7] <= 1; //test hide
	 for (i = 0; i < 10000; i++) begin
         @(posedge CLOCK_50);
     end SW[9] <= 0;
                                                     @(posedge CLOCK_50);
                                                     @(posedge CLOCK_50);
                                                     @(posedge CLOCK_50);
                                                     @(posedge CLOCK_50);
                                                     @(posedge CLOCK_50);
                                                     @(posedge CLOCK_50);


     $stop;
 end
endmodule