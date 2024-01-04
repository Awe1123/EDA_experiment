// BCD计数器模块定义
module bcdcounter8(clk, rstn, bcd);
    // 输入输出定义
    input clk, rstn;          // 输入：clk（时钟信号），rstn（复位信号）
    output [7:0] bcd;         // 输出：8位BCD码

    // 内部寄存器定义
    reg [7:0] bcd;            // 8位寄存器，用于存储BCD码

    // 时钟事件或复位事件触发的始终块
    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            bcd <= 8'h00;     // 当复位信号被激活时，清零BCD计数器
        else begin
            if (bcd == 8'h99) 
                bcd <= 8'h00; // 当计数器达到99时，重置为00
            else if (bcd[3:0] == 4'h9) begin
                bcd[7:4] <= bcd[7:4] + 1'b1; // 当个位为9时，十位加1
                bcd[3:0] <= 4'h0;            // 并将个位重置为0
            end
            else begin
                bcd[7:4] <= bcd[7:4];        // 否则，十位保持不变
                bcd[3:0] <= bcd[3:0] + 1'b1; // 个位加1
            end
        end
    end
endmodule

// 此BCD计数器模块通过时钟信号实现计数。
// 当计数器达到99（即BCD表示的99）时，它会重置为00，实现循环计数。
// 计数器的个位和十位是独立处理的：个位每个时钟周期加1，十位在个位从9回绕到0时加1。
// 当复位信号激活时，计数器会立即清零。这种类型的计数器在数字电路和微控制器系统中常用于时间和数值显示。