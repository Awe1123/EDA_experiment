
module debounce
#(parameter CNT_MAX=20'd999_999)
(
	input wire clk,
	input wire sys_rst_n,
	input wire key_in,
	output reg key
    );
	
	reg [19:0]cnt_20ms;
	always@(posedge clk or negedge sys_rst_n)
		begin
			if(sys_rst_n==1'b0)
				cnt_20ms<=20'd0;
			else if(key_in==1'b1)
				cnt_20ms<=20'd0;
			else if(cnt_20ms==CNT_MAX)
				cnt_20ms<=CNT_MAX;
			else
				cnt_20ms<=cnt_20ms+20'd1;
		end
	always@(posedge clk or negedge sys_rst_n)
		begin
			if(sys_rst_n==1'b0)
				key<=1'd0;
			else if(cnt_20ms==(CNT_MAX-20'd1))
				key<=1'd1;
			else
				key<=1'd0;
		end
endmodule