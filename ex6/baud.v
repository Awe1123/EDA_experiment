//BAUD.v
module baud(sys_clk,sys_rst_l,baud_clk,baud_rate_div);  
	`include "uart_inc.h"
	input sys_clk;
	input sys_rst_l;  
	output baud_clk;  
	input [15:0]baud_rate_div;  
	reg   [15:0] clk_div;  
 
	always@ (posedge sys_clk or negedge sys_rst_l)    
		if (~sys_rst_l) begin 
			clk_div <=0; 
		end
else if (clk_div ==(baud_rate_div+baud_rate_div)-1) begin      
			clk_div  <=0;      
		end    
		else       
			clk_div  <=clk_div+ 1;      
	assign baud_clk=(clk_div == ((baud_rate_div + baud_rate_div) - 1));
endmodule
