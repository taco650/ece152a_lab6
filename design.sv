// this module takes the inputs of the microwave controller
// power = 0 for HALF and 1 for FULL
// timer is the heat time
// door_status = 0 for OPEN and 1 for closed
// start_button = 0 initially and 1 when pressed
// cancel_button = 0 initially and 1 when pressed
module controller ( input clk ,
                    input power ,
                    input [6:0] timer ,
                    input door_status ,
                    input start_button ,
                    input cancel_button ,
                    output reg [6:0] state_display1 ,
                    output reg [6:0] state_display2 ,
                    output reg [6:0] state_display3 ,
                    output reg [6:0] state_display4 ,
                    output reg [6:0] time_display ) ;
    // fill out code
    // TODO :
    // 1. Implement a countdown counter for the timer
    // 2. Monitor door_status and cancel_button ( analogous to reset in Lab4 )
    // 3. Monitor start_button ( analogous to enable in Lab4 )
    // 4. state_display consists of 4 - alphabets based on the state of the controller . Use 7 - segment display representation to display the state .
endmodule
