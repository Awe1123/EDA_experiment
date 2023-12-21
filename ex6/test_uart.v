module test_uart(clk, rstn, TXD, RXD, led0, led1);
	input	clk;
	input	rstn;
	output TXD;
	input	 RXD;
	output	led0;
	output 	led1;
	
	wire		mp_cs_l, mp_rd_l, mp_wr_l, mp_int_l;
	wire [2:0]	mp_addx;
	wire [7:0]	mp_data_from_uart, mp_data_to_uart, stat_rec_dataH, stat_xmit_emptyH;

	uart uart1(
	   .sys_rst_l(rstn),
		.sys_clk(clk),
		.uart_clk(),
		.mp_clk(clk),
		.mp_cs_l(mp_cs_l),
		.mp_addx(mp_addx),
		.mp_data_to_uart(mp_data_to_uart),
		.mp_data_from_uart(mp_data_from_uart),
		.mp_rd_l(mp_rd_l),
		.mp_wr_l(mp_wr_l),
		.mp_int_l(mp_int_l),
		.uart_XMIT_dataH(TXD),
		.uart_REC_dataH(RXD),
		.stat_rec_dataH(stat_rec_dataH),
		.stat_xmit_emptyH(stat_xmit_emptyH)
	);

	assign led0 = ~stat_rec_dataH;
	assign led1 = ~stat_xmit_emptyH;
	
	mp_fake	mp_fake(
		.mp_clk(clk), 
		.sys_rst_l(rstn), 
		.mp_cs_l(mp_cs_l), 
		.mp_addx(mp_addx), 
		.mp_data_to_uart(mp_data_to_uart), 
		.mp_data_from_uart(mp_data_from_uart), 
		.mp_rd_l(mp_rd_l), 
		.mp_wr_l(mp_wr_l), 
		.mp_int_l(mp_int_l)
	);
	
endmodule