module controller_tb () ;
// declare variables
parameter CLK = 10;
reg clk = 0;
reg power , door_status , start_button , cancel_button ;
reg [6:0] timer ;
wire [6:0] state_display1 ; // I or P or d
wire [6:0] state_display2 ; // d or r or O
wire [6:0] state_display3 ; // L or O or n
wire [6:0] state_display4 ; // E or C or E
wire [6:0] time_display ;

initial begin
    forever begin
        clk <= ~clk ;
        #5;
    end
end

controller ctl (.clk(clk),
                .power(power),
                .timer(timer),
                .door_status(door_status),
                .start_button(start_button),
                .cancel_button(cancel_button),
                .state_display1(state_display1),
                .state_display2(state_display2),
                .state_display3(state_display3),
                .state_display4(state_display4),
                .time_display(time_display)
                );

initial begin
    $dumpfile("dump .vcd");
    $dumpvars;

    
    // default settings
    power <= 0; // power is HALF
    timer <= 7'b111100 ; // timer is 60s
    door_status <= 0; // Door is open
    start_button <= 0; // start button not pressed
    cancel_button <= 0; // cancel button not pressed
    
    //Possible scenario 2
    door_status = 0; //open door, place food
    door_status = 1; //close door
    power <= 0; //set power (HALF)
    timer <= 7'b1100100; //set timer (100s)
    start_button <= 1; 
    #5 start_button <= 0;
    #(40*CLK) //wait for 40 seconds
    door_status <= 0; //open door, remove food, place food back
    door_status = 1; //close door
    start_button <= 1; //press start button
    #5 start_button <= 0;
    #(60*CLK+5) //wait for cooking to finish
    door_status <= 0; //open door

    #CLK timer <= 7'b111100; // timer is reset to 60s
    door_status = 1; // 1 clock cycle to remove food and door is closed
    
    // write test bench for possible scenarios 2 , 3 and 4
    // end simulation
    $finish;

    end
endmodule
