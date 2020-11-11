//Overall function: Tracks which card the player is on
//Module ports: Inputs: Signals to indicate direction player would like to move in (up, down, left, right). 
//                      Clk and reset for timing and reset.
//				Outputs: Location of card that the player is on
//Connections: Connects to gamelogic module. Outputs values (locationX, locationY) are inputs for gamelogic.
module cardTracker (up, down, left, right, reset, clk, locationX, locationY);
    input logic up, down, left, right, reset, clk;
    output logic [1:0] locationX, locationY;

    //logic map [3:0][3:0];

    always_ff @(posedge clk) begin
        if (reset) begin
            locationX <= 0;
            locationY <= 0;
        end else begin
            if (up)
            locationY <= locationY - 1'b1;
            else if (down)
            locationY <= locationY + 1'b1;
            else if (left)
            locationX <= locationX - 1'b1;
            else if (right)
            locationX <= locationX + 1'b1;
        end 
    end //end cardTracker


endmodule //end cardTracker

//Instantiates the cardTracker module for testing
//Tests different input combinations and ordering with the positive edge of the clock as a delay
module cardTracker_testbench();
    logic up, down, left, right, reset, clk;
    logic [1:0] locationX, locationY;
    
    //set up clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    cardTracker dut(.*);

    integer i;
    // Set up the inputs to the design. Each line is a clock cycle.
    initial begin
        reset <= 1; left <= 0; right <= 0; up <= 0; down <= 0;      @(posedge clk); @(posedge clk);
        reset <= 0;                                                 @(posedge clk);

        //test up
        for(i = 0; i < 5; i++) begin
            up <= 1;                                                @(posedge clk);
        end
        up <= 0;                                                    @(posedge clk);

        //test down
        for(i = 0; i < 6; i++) begin
            down <= 1;                                              @(posedge clk);
        end
        down <= 0;                                                  @(posedge clk);

        //up and right
        for(i = 0; i < 6; i++) begin
            up <= 1; right <= 1;                                    @(posedge clk);
        end
        up <= 0; right <= 0;                                        @(posedge clk);

        //test right
        for(i = 0; i < 5; i++) begin
            right <= 1;                                             @(posedge clk);
        end
        right <= 0;                                                 @(posedge clk);

        //test left
        for(i = 0; i < 8; i++) begin
            left <= 1; right <= 1;                                  @(posedge clk);
        end
        left <= 0; right <= 0;                                      @(posedge clk);

        $stop; //end simulation
    end
    
endmodule //end cardTracker_testbench()

