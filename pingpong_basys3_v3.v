
module main_controller(
    input wire clock_100Mhz, // 100 Mhz clock source on Basys 3 FPGA
    input wire reset, // reset switch
	input wire player1button,
	input wire player2button,
	output led0,
	output led1,
	output led2,
	output led3,
	output led4,
	output led5,
	output led6,
	output led7,
	output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out, // cathode patterns of the 7-segment LED display
	output reg dp // decimal point for 7-segment LED display
	);

	integer roundtimer;
	integer roundtimeratlastevent;
	integer cyclesperround;
	integer cyclesperrounddecrement;
	integer pauseduration;
	integer nextstate;
	integer state;
	integer i;
	integer lastwinningplayer;
	
	reg int_led0;
	reg int_led1;
	reg int_led2;
	reg int_led3;
	reg int_led4;
	reg int_led5;
	reg int_led6;
	reg int_led7;
	reg [3:0] bcd_player1score; // BCD
	reg [3:0] bcd_player2score; // BCD
	reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter; 
	
	always@ (negedge clock_100Mhz or negedge reset) begin // this part is always done
	
		if(reset == 1) begin
			int_led0 = 0;
			int_led1 = 0;
			int_led2 = 0;
			int_led3 = 0;
			int_led4 = 0;
			int_led5 = 0;
			int_led6 = 0;
			int_led7 = 0;
			bcd_player1score = 4'b0000;
			bcd_player2score = 4'b0000;
			roundtimer = 0;
			roundtimeratlastevent = 0;
			cyclesperround = 100000000;
			cyclesperrounddecrement = 1000000;
			pauseduration = 25000000;
			nextstate = 0;
			state = 0;
			i = 0;
			lastwinningplayer = 0;
			
		end else begin
			case (state) 
				0: begin
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					cyclesperround = 100000000;
					cyclesperrounddecrement = 1000000;
					if(lastwinningplayer == 1) begin
						bcd_player1score = bcd_player1score + 1;
						lastwinningplayer = 0;
					end else if(lastwinningplayer == 2) begin
						bcd_player2score = bcd_player2score + 1;
						lastwinningplayer = 0;
					end
							
					if(roundtimer > (roundtimeratlastevent + pauseduration)) begin
						if(player1button) begin 
							// player 1 starts game so ball will head toward player 2
							nextstate = 9;
							roundtimer = 0;
							roundtimeratlastevent = 0;
						end else if(player2button) begin 
							// player 2 starts game so ball will head toward player 1
							nextstate = 2;
							roundtimer = 0;
							roundtimeratlastevent = 0;
						end else if(!player1button && !player2button) begin
							if(i>cyclesperround) begin
								if(nextstate != state) begin
									i = 0;
									roundtimeratlastevent = roundtimer;
									state = nextstate;
								end
							end
						end
					end
					
				end
				1: begin 
					// ball is at player 2
					int_led0 = 1;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 hit the ball
						nextstate = 2;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin 
							// player 2 failed to hit the ball so player 1 wins round
							if(nextstate == state) begin
								lastwinningplayer = 1;
								nextstate = 0;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end 
				2: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 1;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 3;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end 
				3: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 1;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 4;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				4: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 1;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 5;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				5: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 1;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 6;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				6: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 1;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 7;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				7: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 1;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 8;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				8: begin 
					// ball is at player 1;
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 1;
					if(player1button) begin 
						// player 1 hit the ball
						nextstate = 9;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin 
							// player 1 failed to hit the ball so player 2 wins round
							if(nextstate == state) begin
								lastwinningplayer = 2;
								nextstate = 0;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				9: begin 
					// ball is moving toward player 2
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 1;
					int_led7 = 0;
					if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 10;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				10: begin 
					// ball is moving toward player 2
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 1;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 11;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				11: begin 
					// ball is moving toward player 2
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 1;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 12;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				12: begin 
					// ball is moving toward player 2
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 1;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 13;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				13: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 1;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 14;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				14: begin 
					// ball is moving toward player 1
					int_led0 = 0;
					int_led1 = 1;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					if(player1button) begin 
						// player 1 violated rule so player 2 wins round
						lastwinningplayer = 2;
						roundtimer = 0;
						nextstate = 0;
					end else if(player2button) begin 
						// player 2 violated rule so player 1 wins round
						lastwinningplayer = 1;
						roundtimer = 0;
						nextstate = 0;
					end else if(!player1button && !player2button) begin
						if(i>cyclesperround) begin
							if(nextstate == state) begin
								nextstate = 1;
							end
							i = 0;
							cyclesperround = cyclesperround - cyclesperrounddecrement;
							roundtimeratlastevent = roundtimer;
							state = nextstate;
						end
					end
				end
				default: begin 
					// reset variables and send game to an idle state 
					// to wait for a player to start a new round 
					// by pressing their button
					int_led0 = 0;
					int_led1 = 0;
					int_led2 = 0;
					int_led3 = 0;
					int_led4 = 0;
					int_led5 = 0;
					int_led6 = 0;
					int_led7 = 0;
					bcd_player1score = 4'b0000;
					bcd_player2score = 4'b0000;
					roundtimer = 0;
					roundtimeratlastevent = 0;
					cyclesperround = 100000000;
					cyclesperrounddecrement = 1000000;
					pauseduration = 25000000;
					i = 0;
					lastwinningplayer = 0;
					nextstate = 0;
					state = 0;
				end
			endcase 

			if(bcd_player1score > 4'b1001) begin 
				// player 1 wins entire game if score > 9
				bcd_player1score = 4'b0000;
				bcd_player2score = 4'b0000;
				nextstate = 0;
				i = 0;
				roundtimeratlastevent = 0;
				roundtimer = 0;
				lastwinningplayer = 0;
				state = nextstate;
			end else if(bcd_player2score > 4'b1001) begin 
				// player 2 wins entire game if score > 9
				bcd_player1score = 4'b0000;
				bcd_player2score = 4'b0000;
				nextstate = 0;
				i = 0;
				roundtimeratlastevent = 0;
				roundtimer = 0;
				lastwinningplayer = 0;
				state = nextstate;
			end else begin
				roundtimer = roundtimer + 1;
				i = i + 1;
			end
			
		end
	end
	
	
	always @(posedge clock_100Mhz or posedge reset) begin 
        if(reset == 1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
	
	assign LED_activating_counter = refresh_counter[19:18];
	
	// anode activating signals for 4 LEDs, digit period of 2.6ms
	// decoder to generate anode signals 
	always @(*) begin
		if(reset == 1) begin
			Anode_Activate = 4'b1011; 
			LED_BCD = 4'b1111;
		end else begin
			case(LED_activating_counter)
			2'b00: begin
				Anode_Activate = 4'b0111;
				LED_BCD = bcd_player1score;
				end
			2'b01: begin
				Anode_Activate = 4'b1011; 
				LED_BCD = 4'b1111;
				end
			2'b10: begin
				Anode_Activate = 4'b1101; 
				LED_BCD = 4'b1111;
				end
			2'b11: begin
				Anode_Activate = 4'b1110; 
				LED_BCD = bcd_player2score; 
				end
			default: begin
				Anode_Activate = 4'b1011; 
				LED_BCD = 4'b1111;
				end
			endcase
		end
	end
	
	always @(*) begin
		if(reset == 1) begin
			LED_out = 7'b1111111; // " "
			dp = 1'b1; // output blank decimal point
		end else begin
			case(LED_BCD)
				4'b0000: LED_out = 7'b0000001; // "0"     
				4'b0001: LED_out = 7'b1001111; // "1" 
				4'b0010: LED_out = 7'b0010010; // "2" 
				4'b0011: LED_out = 7'b0000110; // "3" 
				4'b0100: LED_out = 7'b1001100; // "4" 
				4'b0101: LED_out = 7'b0100100; // "5" 
				4'b0110: LED_out = 7'b0100000; // "6" 
				4'b0111: LED_out = 7'b0001111; // "7" 
				4'b1000: LED_out = 7'b0000000; // "8"     
				4'b1001: LED_out = 7'b0000100; // "9" 
				4'b1111: LED_out = 7'b1111111; // " " 
				default: LED_out = 7'b1111111; // " "
			endcase
			dp = 1'b1; // output blank decimal point
		end
	end
	
	assign led0 = int_led0;
    assign led1 = int_led1;
    assign led2 = int_led2;
    assign led3 = int_led3;
    assign led4 = int_led4;
    assign led5 = int_led5;
    assign led6 = int_led6;
    assign led7 = int_led7;
	
endmodule