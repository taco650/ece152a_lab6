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
                    output reg [6:0] state_display1,
                    output reg [6:0] state_display2,
                    output reg [6:0] state_display3,
                    output reg [6:0] state_display4,
                    output reg [6:0] time_display);
    // fill out code
    // TODO :
    // 1. Implement a countdown counter for the timer
    // 2. Monitor door_status and cancel_button ( analogous to reset in Lab4 )
    // 3. Monitor start_button ( analogous to enable in Lab4 )
    // 4. state_display consists of 4 - alphabets based on the state of the controller . Use 7 - segment display representation to display the state .
    
    //state machine does not need power as input?
    statemachine statemachine(.clk(clk),
                              .power(valid_power),
                              .timer(timerCount),
                              .door_status(door_status),
                              .start_button(start_button),
                              .cancel_button(cancel_button),
                              .state(state));
    
    inputController inputController(.state(state),
                                    .power(power),
                                    .timerInput(timer),
                                    .validPower(valid_power),
                                    .validTimer(valid_timer));
                                
    timercounter timercounter(  .clk(clk), 
                                .timer(timer), 
                                .writeEnable(), 
                                .decrEnable(), 
                                .reset(),
                                .timercount(timerCount));


endmodule

module statemachine(input clk,
                    input power,
                    input [6:0] timer,
                    input door_status,
                    input start_button,
                    input cancel_button, 
                    output reg[4:0] state);
    
    always @(posedge clk or cancel_button or door_status) begin
        if(cancel_button == 1) begin
            state = 0; //reset timer and return to S0
        end 
        else begin 
            if(door_status == 1 && state == 0) begin 
                state = 1; //reprogram idle state
            end
            
            else if(door_status == 0 && state == 1)begin
                state = 0;
            end
            
            else if(start_button == 1 && state == 1 && power == 1) begin
                state = 6; //microwaving/processing state on HIGH POWER    
            end

            else if(start_button == 1 && state == 1) begin
                state = 2; //microwaving/processing state on HALF POWER
            end
            
            else if(door_status == 0 && (state == 2 || state == 4 || state == 6) )begin
                state = 3; //stopped processing state (no programming allowed)
            end

            else if(door_status == 1 && state == 3)begin
                state = 4; //reprogram processing state (allowed reprogramming)
            end

            else if(start_button == 1 && state == 4 && power == 1)begin
                state = 6;//microwaving/processing state on HIGH POWER
            end

            else if(start_button == 1 && state == 4)begin
                state = 2;//microwaving/processing state on LOW POWER 
            end
            
            else if(timer == 0 && (state == 2 || state == 6))begin //timer counter == 0 
                state = 5;//Done state
            end
            
            else if(door_status == 0 && state == 5)begin
                state = 0;
            end
            
        end
    end


endmodule

module inputController( input [4:0] state,
                        input power,
                        output reg validPower,
                        output decrEnable,
                        output writeEnable,
                        output reset);
    always @(*)begin
        if(state == 1 || state == 4) begin
            validPower = power;
            decrEnable = 0;
            writeEnable = 1;
            reset = 0;
        end
        else if(state == 0)begin
            //default values
            validPower = 0;
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
    end

endmodule

module timercounter(input clk, 
                    input [6:0] timer, 
                    input writeEnable, 
                    input decrEnable, 
                    input reset,
                    output reg [6:0] timercount);

    reg [6:0] timervalue;
     
    always @(posedge clk or posedge writeEnable ) begin
        if(writeEnable) begin
            timervalue = timer;
        end
        if(reset) begin
            timervalue = 60;
        end
        else if(decrEnable) begin 
            if (timercount != 0) begin
                timercount = timervalue - 1'b1;
            end
        end
    end
endmodule
