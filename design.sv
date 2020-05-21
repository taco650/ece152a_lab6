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
    


endmodule

module stateDisplay(input state,
                    output reg [6:0] state_display1, 
                    output reg [6:0] state_display2, 
                    output reg [6:0] state_display3, 
                    output reg [6:0] state_display4);

    integer I = 7'b0110000;
    integer P = 7'b1100111;
    integer d = 7'b0111101;
    integer r = 7'b0000101;
    integer O = 7'b1111110;
    integer L = 7'b0001110;
    integer n = 7'b0010101;
    integer E = 7'b1001111;
    integer C = 7'b1001110;

    if (state == 0 || state == 1) begin //IdLE
        state_display1 = I;
        state_display2 = d;
        state_display3 = L;
        state_display4 = E;
    end
    else if (state == 2 || state == 3 || state == 4 || state == 6) begin //PrOC
        state_display1 = P;
        state_display2 = r;
        state_display3 = O;
        state_display4 = C;
    end
    else if (state == 5) begin //dOnE
        state_display1 = d;
        state_display2 = O;
        state_display3 = n;
        state_display4 = E;
    end
endmodule

module statemachine(input clk,
                    input power,
                    input [6:0] timer,
                    input door_status,
                    input start_button,
                    input cancel_button
                    output state);
    
    reg[4:0] state; //alllows for 2^5 different states

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
            
            else if(start_button == 1 && state == 1) begin
                state = 2; //microwaving/processing state    
            end
            
            else if(door_status == 0 && (state == 2 || state == 4) )begin
                state = 3; //stopped processing state (no programming allowed)
            end

            else if(door_status == 1 && state == 3)begin
                state = 4; //reprogram processing state (allowed reprogramming)
            end

            else if(start_button == 1 && state == 4)begin
                state = 2;//microwaving/processing state
            end
            
            else if(timer == 0 && state == 2)begin //timer counter == 0 
                state = 5;//Done state
            end
            
            else if(door_status == 0 && state == 5)begin
                state = 0;
            end
            
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
