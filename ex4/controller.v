module controller (CLK, S, RESET, enable, HG, HY, HR, FG, FY, FR, TimerH, TimerL);
	input CLK, S, RESET, enable;  //if S=1, indicates that there is car on the country road
	output reg HG, HY, HR, FG, FY, FR; //declared output signals are registers
	output reg [3:0] TimerH, TimerL;

	//Internal state variables
	wire Tl, Ts, Ty; //timer output signals
	reg St;           //state translate signal
	reg [1:0] CurrentState, NextState;//FSM state register
	parameter S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;
	
	always @(posedge CLK or negedge RESET )
	begin:counter
		if (~RESET)  
			{TimerH, TimerL} = 8'b0; 
		else if(enable)
		begin
			if (St) 
				{TimerH, TimerL} = 8'b0; 
			else if ((TimerH == 5) & (TimerL == 9))
				{TimerH, TimerL} = {TimerH, TimerL}; 
			else if (TimerL == 9) begin
				TimerH = TimerH + 1;  
				TimerL = 0; 
			end
			else begin 
				TimerH = TimerH; 
				TimerL = TimerL + 1; 
			end
		end
	end  // BCD counter
		
	assign  Ty = (TimerH==0)&(TimerL==4);
	assign  Ts = (TimerH==2)&(TimerL==9);
	assign  Tl = (TimerH==5)&(TimerL==9);

	/* Descrition of the signal controller block*/
	always @(posedge CLK or negedge RESET )
	begin:statereg
		if (~RESET) 	
			CurrentState <= S0;
		else if(enable)
			CurrentState <= NextState;
	end //statereg

	// FSM combinational block
	always @(S or CurrentState or Tl or Ts or Ty )
	begin: fsm
	 	case(CurrentState)
		S0: begin      //S0在引用时要加右撇号
				NextState = (Tl && S) ? S1 :S0;
				St = (Tl && S) ? 1:0;
		end
	  	S1: begin
				NextState = (Ty) ? S2 :S1;
				St = (Ty) ? 1:0;
		end
	  	S2: begin
				NextState = (Ts || ~S) ? S3 :S2;
				St = (Ts || ~S) ? 1:0;
		end
	  	S3: begin
				NextState = (Ty) ? S0 :S3;
				St = (Ty) ? 1:0;
		end
		default: begin
				NextState = S0;
				St = 0;
		end
	 	endcase	
	end  //fsm

	/*===== Descrition of the decoder block =====*/
	always @(CurrentState)
	begin
		case (CurrentState)
	  		S0: begin
				{HG, HY, HR} = 3'b100; 
				{FG, FY, FR} = 3'b001; 
			end
			S1: begin
				{HG, HY, HR} = 3'b010; 
				{FG, FY, FR} = 3'b001; 
			end
			S2: begin
				{HG, HY, HR} = 3'b001; 
				{FG, FY, FR} = 3'b100; 
			end
		  S3: begin
				{HG, HY, HR} = 3'b001; 
				{FG, FY, FR} = 3'b010; 
			end
			default: begin
				{HG, HY, HR} = 3'b100; 
				{FG, FY, FR} = 3'b001;
			end 
		endcase
     end
endmodule
