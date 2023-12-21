module bcdcounter8(clk, rstn, enable, key_pulse, bcd);	
	input clk, rstn, enable, key_pulse;				
	output [7:0] bcd;

	reg [7:0] bcd;
	
	always@(posedge clk or negedge rstn)
	begin
		if (!rstn)
			bcd <= 8'h00;
		else if (enable & key_pulse) begin
			if (bcd == 8'h99)
				bcd <= 8'h00;
			else if (bcd[3:0] == 4'h9) begin
				bcd[7:4] <= bcd[7:4] + 1'b1;
				bcd[3:0] <= 4'h0;
			end
			else begin
				bcd[7:4] <= bcd[7:4];
				bcd[3:0] <= bcd[3:0] + 1'b1;
			end
		end
	end
endmodule