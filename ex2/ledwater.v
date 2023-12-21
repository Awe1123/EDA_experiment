module ledwater(clk, rstn, enable, led);	
	input		clk, rstn, enable;		
	output[7:0]	led;		
	
	reg[7:0]	led_r;		

	assign led = led_r;	

	always @(posedge clk or negedge rstn)		
	begin
		if (!rstn)
			led_r <= 8'b00000000;
		else if (enable) begin
			if(led_r == 8'b11111111)		
				led_r <= 8'b00000000;		
			else
				led_r <= {led_r[6:0], 1'b1};
		end
	end
endmodule
