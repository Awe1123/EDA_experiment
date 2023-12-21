module clk_en_generator(clk, rstn, enable);
	input clk, rstn;
	output enable;
	
	parameter N = 50000000;
	parameter W = 26;
	
	reg [W-1 :0] cnt_reg;
	
	always@(posedge clk or negedge rstn)
	begin
		if (!rstn)
			cnt_reg <= 0;
		else if (cnt_reg == N-1)
			cnt_reg <= 0;
		else
			cnt_reg <= cnt_reg + 1'b1;
	end
	
	assign enable = (cnt_reg == N-1)? 1'b1 : 1'b0;

endmodule
