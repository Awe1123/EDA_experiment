//MP_INT.v
//微处理器接口模块
module mp_int(          
	//系统信号              
	sys_rst_l, uart_clk, mp_clk, 
	//微处理器接口                                     
	mp_cs_l, mp_addx, mp_data_to_uart, mp_data_from_uart,    mp_rd_l, mp_wr_l, mp_int_l,
	//波特率变换模块接口
   	baud_rate_div,          
	//UART发送模块接口                                
	start_pulseH, xmit_doneH, reg_xmit_dat, xmit_busyH,  
	// UART接收模块接口                                        	
	rec_dataH, rec_readyH, xmit_busy_rstH, stat_xmit_emptyH, 
   stat_rec_dataH,  
	// 调试接口      
	wr_done_pulseH, sel_xmit_datH      );
`include "uart_inc.h"  
input    sys_rst_l;  
input    mp_clk;  
input    uart_clk;  
input    mp_cs_l;  
input    [2:0]mp_addx;  
input    mp_rd_l;  
input    mp_wr_l;  
input    [7:0]mp_data_to_uart;  
output   [7:0]mp_data_from_uart;  
output   [15:0]baud_rate_div;  
output   start_pulseH;  
input    xmit_doneH;  
output   xmit_busyH;  
output   [7:0]reg_xmit_dat;  
 input    [7:0]rec_dataH;  
input    rec_readyH;  
output   mp_int_l;                 
output   xmit_busy_rstH;  
output   stat_xmit_emptyH;  
output   stat_rec_dataH;  
output   wr_done_pulseH;  
output   sel_xmit_datH;
reg      [7:0]reg_baud_rate_div_lo_in;  
reg      [7:0]reg_baud_rate_div_hi;  
reg      [7:0]reg_baud_rate_div_lo;  
reg      [7:0]reg_xmit_dat;  
reg      [7:0]reg_int_ena;
reg      xmit_busyH;  
reg      [7:0]mp_data_out;  
reg      stat_rec_dataH;  
reg      stat_xmit_emptyH;  
reg      rec_new_dataH;  
wire     [7:0]mp_data;  
wire     sel_baud_regLoH;  
wire     sel_baud_regHiH;  
wire     sel_xmit_datH;  
wire     sel_int_maskH;  
wire     wr_done_pulseH;
wire     xmit_busyH_sync;  
wire     start_pulseH;  
wire     xmit_doneH_sync;  
wire     [15:0]baud_rate_div;  
wire     xmit_busy_rstL;  
wire     rec_readyH_sync;  
wire     rec_ready_pulseH;  
wire     sel_int_stat_regH;
assign mp_data           = mp_data_to_uart;
assign mp_data_from_uart = mp_data_out;
assign baud_rate_div     = 			//波特率输出
			{reg_baud_rate_div_hi,reg_baud_rate_div_lo};
assign sel_baud_regLoH   = ~ mp_cs_l &  //波特率低位
			(mp_addx==SEL_BAUD_REG_LO);
assign sel_baud_regHiH   = ~ mp_cs_l &  //波特率高位
			(mp_addx==SEL_BAUD_REG_HI);
assign sel_xmit_datH     = ~ mp_cs_l &  // 发送数据
			(mp_addx==SEL_XMIT_DAT);
assign sel_int_maskH     = ~ mp_cs_l &  //中断使能
			(mp_addx==SEL_INT_ENA_REG);
assign sel_int_stat_regH = ~ mp_cs_l &  // 中断状态
			(mp_addx==SEL_INT_STAT_REG);
//写寄存器
always@ (posedge mp_clk or negedge sys_rst_l)  
	if (~sys_rst_l) begin    
		reg_baud_rate_div_lo    <= 0;    
		reg_baud_rate_div_hi    <= 0;    
		reg_xmit_dat            <= 0;    
		reg_int_ena             <= 0;  
	end else begin  
		if (~mp_wr_l) begin    
			if (sel_baud_regLoH) 
				reg_baud_rate_div_lo_in <= mp_data;    
			if (sel_baud_regHiH) begin            
				reg_baud_rate_div_hi <= mp_data;            
				reg_baud_rate_div_lo <= reg_baud_rate_div_lo_in;    
			end    
			if (sel_xmit_datH) 
				reg_xmit_dat <= mp_data;    
			if (sel_int_maskH) 
				reg_int_ena <= mp_data;  
		end
	end
	//读寄存器
	always@ (mp_addx or rec_dataH or reg_baud_rate_div_lo or reg_baud_rate_div_hi or stat_rec_dataH or stat_xmit_emptyH or reg_int_ena)
	begin  
		case (mp_addx)    
			SEL_REC_DAT:              
				mp_data_out=rec_dataH;    
			SEL_BAUD_REG_LO:          
				mp_data_out=reg_baud_rate_div_lo;    
			SEL_BAUD_REG_HI:          
				mp_data_out=reg_baud_rate_div_hi;    
			SEL_STAT_REG:             
				mp_data_out={rec_new_dataH,xmit_busyH};    
			SEL_INT_STAT_REG:         
				mp_data_out={stat_rec_dataH,stat_xmit_emptyH};    
			SEL_INT_ENA_REG:          
				mp_data_out=reg_int_ena;    
			default:                  
				mp_data_out=8'hxx;  
		endcase
	end
// 产生中断
assign mp_int_l=~((stat_xmit_emptyH & reg_int_ena[0]) |(stat_rec_dataH  & reg_int_ena[1]));
// 接受数据有效，对应STAT_REG[1]
always@ (posedge mp_clk or negedge sys_rst_l)  
begin
	if (~sys_rst_l) 
		rec_new_dataH <= 0;  
	else if (rec_ready_pulseH) 	//接受到一个字节数据
		rec_new_dataH <= 1'b1;  
	else if (sel_xmit_datH & mp_rd_l)  //读取了接受到的数据
		rec_new_dataH <= 1'b0;
	else
		rec_new_dataH <= rec_new_dataH;
//接受完成及发送空闲,对应INT_STAT_REG[1:0]
end
always@ (posedge mp_clk or negedge sys_rst_l)
	if (~sys_rst_l)   begin    //********************************************不同结构分开写
	
		stat_rec_dataH    <= 1'b0;    
		stat_xmit_emptyH  <= 1'b1;       
	end
	else begin    
			if (sel_int_stat_regH & ~ mp_wr_l) // 通过写清除
				stat_xmit_emptyH <=mp_data[0];        
			else if (xmit_busy_rstH) 				//完成一个字节发送
				stat_xmit_emptyH <= 1'b1;        
			else if (sel_xmit_datH & ~ mp_wr_l) //写入待发送数据
				stat_xmit_emptyH <= 0;    

			if (sel_int_stat_regH & ~ mp_wr_l) // 通过写清除
				stat_rec_dataH <= mp_data[1];    
			else if (rec_ready_pulseH) //接受到一个字节数据，产生中断
				stat_rec_dataH <= 1'b1;  
	end

assign xmit_busy_rstL=~ xmit_busy_rstH; //发送结束
one_shot OS_WR (
		.clk_in(mp_clk),                               
		.sys_rst_l(sys_rst_l),                                
		.d(mp_wr_l),                
		.q(wr_done_pulseH) );

wire rst= sys_rst_l & xmit_busy_rstL; 

     //向发送模块启动发送,对应STAT_REG[0]
always@ (posedge mp_clk or negedge xmit_busy_rstL) 
	if (~ xmit_busy_rstL) 
		xmit_busyH <= 0;    
	else if (~ mp_wr_l & sel_xmit_datH)      
		xmit_busyH <= 1;
	else 
         xmit_busyH <= xmit_busyH;

sync SYNC_WR (.
	clk_in(uart_clk),                 // 2级同步            
	.sys_rst_l(xmit_busy_rstL),              
	.d(xmit_busyH),              
	.q(xmit_busyH_sync) );

one_shot OS_WR2 (.				//检测上升沿
	clk_in(uart_clk),                             
	.sys_rst_l(sys_rst_l),                 
	.d(xmit_busyH_sync),                 
	.q(start_pulseH) );
// 接受发送结束信号
sync SYNC_WR2 (
	.clk_in(mp_clk),    				 // 2级同步                            
	.sys_rst_l(sys_rst_l),               
	.d(xmit_doneH),               
	.q(xmit_doneH_sync) );

one_shot OS_WR3 (.				//检测上升沿
	clk_in(mp_clk),                               
	.sys_rst_l(sys_rst_l),                 
	.d(xmit_doneH_sync),                 
	.q(xmit_busy_rstH) );
//接受到接受数据信号
sync SYNC_RECDAT(
	.clk_in(mp_clk),						 // 2级同步              
	.sys_rst_l(sys_rst_l),                 
	.d(rec_readyH),                 
	.q(rec_readyH_sync) );

one_shot OS_RECDAT(				//检测上升沿
	.clk_in(mp_clk),              			                 
	.sys_rst_l(sys_rst_l),                   
	.d(rec_readyH_sync),                   
	.q(rec_ready_pulseH) );

endmodule
