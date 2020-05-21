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

    // Possible scenario 1
    // default settings
    power <= 0; // power is HALF
    timer <= 7’b111100 ; // timer is 60s
    door_status <= 0; // Door is open
    start_button <= 0; // start button not pressed
    cancel_button <= 0; // cancel button not pressed

    #CLK //1 clock cycle to place food
    door_status <=1; // Door is closed
    power <= 1; // Power is set to FULL
    timer <= 7’b1100100; // timer is set to 100s
    start_button <= 1; // start button pressed
    #5 start_button <= 0; // start button reset at negedge
    #(100*CLK+5) door_status <= 0; // Door opened after 101 s - 1s extra to display dOnE

    #CLK timer <= 7’b111100; // timer is reset to 60s
    door_status = 1; // 1 clock cycle to remove food and door is closed
    
    // write test bench for possible scenarios 2 , 3 and 4
    // end simulation
    $finish;

    end
endmodule
