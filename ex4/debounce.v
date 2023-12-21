module debounce(clk, key_in, key);		//按键去抖
	input clk;								
	input key_in;				
	output key;				
	
	reg dout1,dout2,dout3;		

	assign key = (key_in | dout1 | dout2 | dout3);	

	always @(posedge clk)
	begin
			dout1 <= key_in;
			dout2 <= dout1;
			dout3 <= dout2;	
	end
endmodule