// this module takes the inputs of the microwave controller
// power = 0 for HALF and 1 for FULL
// timer is the heat time
// door_status = 0 for OPEN and 1 for closed
// start_button = 0 initially and 1 when pressed
// cancel_button = 0 initially and 1 when pressed
module controller ( input clk,
                    input power,
                    input [6:0] timer,
                    input door_status,
                    input start_button,
                    input cancel_button,
                    output reg [6:0] state_display1, //I or P or d
                    output reg [6:0] state_display2, //d or r or O
                    output reg [6:0] state_display3, //L or O or n
                    output reg [6:0] state_display4, //E or C or E
                    output reg [6:0] time_display);
    // fill out code
    // TODO :
    // 1. Implement a countdown counter for the timer
    // 2. Monitor door_status and cancel_button ( analogous to reset in Lab4 )
    // 3. Monitor start_button ( analogous to enable in Lab4 )
    // 4. state_display consists of 4 - alphabets based on the state of the controller . Use 7 - segment display representation to display the state .
    wire [6:0] timercount; 
    wire valid_power;
    wire [4:0] state;
    wire decrEnable;
    wire reset;
    wire writeEnable;
    wire [6:0] regTimer;

    inputController inputController(.clk(clk),
                                    .state(state),
                                    .door_status(door_status),
                                    .decrEnable(decrEnable),
                                    .writeEnable(writeEnable),
                                    .reset(reset));
  
    //state machine does not need power as input?
    statemachine statemachine(.clk(clk),
                              .power(power),
                              .stateTimer(timer),
                              .stateTimerCount(timercount),
                              .door_status(door_status),
                              .start_button(start_button),
                              .cancel_button(cancel_button),
                              .regTimer(regTimer),
                              .state(state));
    
 


                                
    timercounter timercounter(  .clk(clk), 
                                .timer(regTimer), 
                                .writeEnable(writeEnable), 
                                .decrEnable(decrEnable), 
                                .reset(reset),
                                .timercount(timercount));

    stateDisplay stateDisplay(  .state(state), 
                                .state_display1(state_display1),
                                .state_display2(state_display2), 
                                .state_display3(state_display3), 
                                .state_display4(state_display4));

    assign time_display = timercount;
endmodule

module stateDisplay(input [4:0] state,
                    output reg [6:0] state_display1, 
                    output reg [6:0] state_display2, 
                    output reg [6:0] state_display3, 
                    output reg [6:0] state_display4);

    integer I = 7'b0110000; //30
    integer P = 7'b1100111; //67
    integer d = 7'b0111101; //3d
    integer r = 7'b0000101; //5
    integer O = 7'b1111110; //7e
    integer L = 7'b0001110; //e
    integer n = 7'b0010101; //15
    integer E = 7'b1001111; //4f
    integer C = 7'b1001110; //4e

    always @(state) begin
        if (state == 0 || state == 1) begin //IdLE
            state_display1 = I; //30
            state_display2 = d; //3d
            state_display3 = L; //e
            state_display4 = E; //4f
        end
        else if (state == 2 || state == 3 || state == 4 || state == 6) begin //PrOC
            state_display1 = P; //67
            state_display2 = r; //5
            state_display3 = O; //7e
            state_display4 = C; //4e
        end
        else if (state == 5) begin //dOnE
            state_display1 = d; //3d
            state_display2 = O; //7e
            state_display3 = n; //15
            state_display4 = E; //4f
        end 
    end
endmodule

module statemachine(input clk,
                    input power,
                    input [6:0] stateTimer,
                    input [6:0] stateTimerCount,
                    input door_status,
                    input start_button,
                    input cancel_button,
                    output reg[6:0] regTimer, 
                    output reg[4:0] state);
    
    initial state = 4'b0;
    reg regPower = 0;
    initial regTimer = 60;

    always @(posedge clk or cancel_button or door_status or start_button) begin
        if(cancel_button == 1) begin
            state = 0; //reset timer and return to S0
        end 
        else if(door_status == 0) begin
            if(state == 2 || state == 6)begin
                state = 3; //stopped processing state (no programming allowed)
            end
            else if(state == 5)begin
                state = 0;
            end
        end
        else if(door_status == 1)begin
            if((state == 0 || state == 3))begin
                regPower = power;
                regTimer = stateTimer;
            end
            if(start_button == 1 && state == 0 && regPower == 1) begin
                state = 6; //microwaving/processing state on HIGH POWER    
            end
            else if(start_button == 1 && state == 0 ) begin
                state = 2; //microwaving/processing state on HALF POWER
            end
            else if(start_button == 1 && state == 3 && regPower == 1)begin
                state = 6;//microwaving/processing state on HIGH POWER
            end
            else if(start_button == 1 && state == 3)begin
                state = 2;//microwaving/processing state on LOW POWER 
            end
            else if(stateTimerCount == 0 && (state == 2 || state == 6))begin //timer counter == 0 
                state = 5;//Done state
            end
        end
    end


endmodule

module inputController( input clk,
                        input [4:0] state,
                        input door_status,
                        output reg decrEnable,
                        output reg writeEnable,
                        output reg reset);

 
    initial decrEnable = 0;
    initial writeEnable = 0;
    initial reset = 1;
    always @(posedge clk or state or door_status)begin
        if((state == 0 && door_status ==1) || state == 4) begin
            decrEnable = 0;
            writeEnable = 1;
            reset = 0;
        end
        else if(state == 0 && door_status == 0)begin
            //default values
          
            decrEnable = 0;
            writeEnable = 0;
            reset = 1;
        end
        else if(state == 6 || state == 2)begin
            decrEnable = 1;
            writeEnable = 0;
            reset = 0;
        end
        else if(state == 3)begin
            decrEnable = 0;
            writeEnable = 0;
            reset = 0;
        end
        else if(state == 5) begin
            decrEnable = 0;
            writeEnable = 0;
            reset = 1;
        end
    end

endmodule

module timercounter(input clk, 
                    input [6:0] timer, 
                    input writeEnable, 
                    input decrEnable, 
                    input reset,
                    output reg [6:0] timercount);

  
    initial timercount = 60;
    always @(timer)begin
        timercount = timer;
    end
    always @(posedge clk or decrEnable or reset) begin
        /*if(writeEnable) begin
            timercount = timer;
        end
        */
        if(reset) begin
            timercount = 60;
        end
        else if(decrEnable) begin 
            if (timercount != 0) begin
                timercount = timercount - 1'b1;
            end
        end
    end
endmodule
