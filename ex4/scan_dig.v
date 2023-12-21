module scan_dig(clk, rstn, enable, d, dig, seg);		//7段数码管动态扫描模块
	input clk, rstn, enable;				//时钟、复位、使能
	input[7:0] d;							//待显示数值
	output[7:0]	dig;						//7段数码管显示译码信号（高电平有效）
	output[7:0] seg;						//7段数码管选择信号（高电平有效）

	reg[7:0] seg_r;							
	reg[7:0] dig_r;							
	reg[3:0] disp_dat;						
	reg count;							

	assign dig = dig_r;						
	assign seg = seg_r;							

	//数码管点亮选择计数器
	always @(posedge clk or negedge rstn)   			
	begin
		if (!rstn)
			count <= 1'b0;
		else if (enable)
			count <= count + 1'b1;
	end

	//根据数码管点亮选择计数器确定待显示的数值及数码管选择信号
	always @(count or d)   						
	begin
		case(count)							
			1'b0: begin
				disp_dat = d[7:4];		//显示十位
				dig_r = 8'b10111111;
			end
			1'b1: begin
				disp_dat = d[3:0];		//显示个位
				dig_r = 8'b01111111;
			end
			default: begin
				disp_dat = 4'hx;
				dig_r = 8'hxx;
			end
		endcase
	end

	// 七段数码管译码
	always @(disp_dat)
	begin
		case(disp_dat)					
			4'h0:seg_r = ~(8'hc0);				//0
			4'h1:seg_r = ~(8'hf9);				//1
			4'h2:seg_r = ~(8'ha4);				//2
			4'h3:seg_r = ~(8'hb0);				//3
			4'h4:seg_r = ~(8'h99);				//4
			4'h5:seg_r = ~(8'h92);				//5
			4'h6:seg_r = ~(8'h82);				//6
			4'h7:seg_r = ~(8'hf8);				//7
			4'h8:seg_r = ~(8'h80);				//8
			4'h9:seg_r = ~(8'h90);				//9
			4'ha:seg_r = ~(8'h88);				//a
			4'hb:seg_r = ~(8'h83);				//b
			4'hc:seg_r = ~(8'hc6);				//c
			4'hd:seg_r = ~(8'ha1);				//d
			4'he:seg_r = ~(8'h86);				//e
			4'hf:seg_r = ~(8'h8e);				//f
			default: seg_r = 8'hxx;
		endcase
	end
endmodule