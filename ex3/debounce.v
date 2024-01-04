// 去抖动模块定义
module debounce
#(parameter CNT_MAX = 20'd999_999)  // 参数化定义，设置计数器的最大值
(
    input wire clk,                  // 输入：clk（时钟信号）
    input wire sys_rst_n,            // 输入：sys_rst_n（系统复位信号）
    input wire key_in,               // 输入：key_in（原始按键输入信号）
    output reg key                   // 输出：key（去抖动后的按键信号）
);

    // 20位计数器用于实现去抖动的延时
    reg [19:0] cnt_20ms;

    // 时钟事件或复位事件触发的始终块，用于控制计数器
    always @(posedge clk or negedge sys_rst_n)
    begin
        if (sys_rst_n == 1'b0)
            cnt_20ms <= 20'd0;          // 如果复位，则计数器清零
        else if (key_in == 1'b1)
            cnt_20ms <= 20'd0;          // 如果按键被按下，计数器清零
        else if (cnt_20ms == CNT_MAX)
            cnt_20ms <= CNT_MAX;        // 如果计数器达到最大值，保持不变
        else
            cnt_20ms <= cnt_20ms + 20'd1;  // 否则，计数器增加
    end

    // 另一个始终块，用于更新去抖动后的按键输出
    always @(posedge clk or negedge sys_rst_n)
    begin
        if (sys_rst_n == 1'b0)
            key <= 1'd0;                // 如果复位，则输出信号清零
        else if (cnt_20ms == (CNT_MAX - 20'd1))
            key <= 1'd1;                // 如果计数器达到最大值前一值，则输出信号置1
        else
            key <= 1'd0;                // 否则，输出信号清零
    end
endmodule
