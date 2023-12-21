module mp_fake(mp_clk, sys_rst_l, mp_cs_l, mp_addx, mp_data_to_uart, mp_data_from_uart, mp_rd_l, mp_wr_l, mp_int_l);
	input 			mp_clk;
	input 			sys_rst_l;
	output 			mp_cs_l;
	output [2:0] 	mp_addx;
	output [7:0] 	mp_data_to_uart;
	input [7:0] 	mp_data_from_uart;
	output 			mp_rd_l;
	output 			mp_wr_l;
	input 			mp_int_l;
	
	`include "uart_inc.h"
	
	parameter 	IDLE = 3'h0, 
					W_BAUD_LO = 3'h1, 
					W_BAUD_HI = 3'h2, 
					W_INT_ENA = 3'h3, 
					WAIT = 3'h4, 
					R_DAT = 3'h5,
					W_DAT = 3'h6,
					CLR_INT = 3'h7;
	parameter		B_DIV = 16'h0145;
	reg [2:0] 		c_state_reg, n_state;
	reg				mp_cs_l, mp_rd_l, mp_wr_l;
	reg [2:0] 		mp_addx;
	reg [7:0]		mp_data_to_uart;
	reg				save_data;
	reg [7:0]		data_reg;
	
	always@(posedge mp_clk or negedge sys_rst_l)
	begin
		if (!sys_rst_l)
			c_state_reg <= IDLE;
		else
			c_state_reg <= n_state;
	end
	
	always@(c_state_reg or mp_data_from_uart or data_reg)
	begin
		case(c_state_reg)
			IDLE : begin
				n_state = W_BAUD_LO;
				mp_cs_l = 1'b1;
				mp_rd_l = 1'b1;
				mp_wr_l = 1'b1;
				mp_addx = 3'h0;
				mp_data_to_uart = 8'h00;
				save_data = 1'b0;
			end
			W_BAUD_LO : begin
				n_state = W_BAUD_HI;
				mp_cs_l = 1'b0;
				mp_rd_l = 1'b1;
				mp_wr_l = 1'b0;
				mp_addx = SEL_BAUD_REG_LO;
				mp_data_to_uart = B_DIV[7:0];
				save_data = 1'b0;
			end
			W_BAUD_HI : begin
				n_state = W_INT_ENA;
				mp_cs_l = 1'b0;
				mp_rd_l = 1'b1;
				mp_wr_l = 1'b0;
				mp_addx = SEL_BAUD_REG_HI;
				mp_data_to_uart = B_DIV[15:8];
				save_data = 1'b0;
			end
			W_INT_ENA : begin
				n_state = WAIT;
				mp_cs_l = 1'b0;
				mp_rd_l = 1'b1;
				mp_wr_l = 1'b0;
				mp_addx = SEL_INT_ENA_REG;
				mp_data_to_uart = 8'h03;
				save_data = 1'b0;
			end
			WAIT : begin
				if (mp_data_from_uart[1:0] == 2'b11)
					n_state = R_DAT;
				else
					n_state = WAIT;
				mp_cs_l = 1'b0;
				mp_rd_l = 1'b0;
				mp_wr_l = 1'b1;
				mp_addx = SEL_INT_STAT_REG;
				mp_data_to_uart = 8'h00;
				save_data = 1'b0;
			end
			R_DAT : begin
				n_state = W_DAT;
				mp_cs_l = 1'b0;
				mp_rd_l = 1'b0;
				mp_wr_l = 1'b1;
				mp_addx = SEL_REC_DAT;
				mp_data_to_uart = 8'h00;
				save_data = 1'b1;
			end
			W_DAT : begin
				n_state = CLR_INT;
				mp_cs_l = 1'b0;
				mp_rd_l = 1'b1;
				mp_wr_l = 1'b0;
				mp_addx = SEL_XMIT_DAT;
				mp_data_to_uart = data_reg;
				save_data = 1'b0;
			end
			CLR_INT : begin
				n_state = WAIT;
				mp_cs_l = 1'b0;
				mp_rd_l = 1'b1;
				mp_wr_l = 1'b0;
				mp_addx = SEL_INT_STAT_REG;
				mp_data_to_uart = 8'h00;
				save_data = 1'b0;
			end
			default : begin
				n_state = WAIT;
				mp_cs_l = 1'b1;
				mp_rd_l = 1'b1;
				mp_wr_l = 1'b1;
				mp_addx = 8'h00;
				mp_data_to_uart = 8'h00;
				save_data = 1'b0;
			end
		endcase
	end
		
	always@(posedge mp_clk or negedge sys_rst_l)
	begin
		if (!sys_rst_l)
			data_reg <= 8'h00;
		else if (save_data)
			data_reg <= mp_data_from_uart;
	end
	
endmodule