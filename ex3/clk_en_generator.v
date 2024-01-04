// 时钟使能生成模块定义
module clk_en_generator(clk, rstn, enable);
    // 输入输出定义
    input clk, rstn;        // 输入：clk（时钟信号），rstn（复位信号）
    output enable;          // 输出：enable（使能信号）

    // 参数定义
    parameter N = 50000;    // 定义周期N，表示使能信号变为高的周期
    parameter W = 16;       // 定义计数器宽度W，足以覆盖N的范围

    // 内部寄存器定义
    reg [W-1:0] cnt_reg;    // W位计数器寄存器

    // 时钟事件或复位事件触发的始终块
    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            cnt_reg <= 0;   // 当复位信号被激活时，清零计数器
        else if (cnt_reg == N-1)
            cnt_reg <= 0;   // 当计数器达到N-1时，重置计数器
        else
            cnt_reg <= cnt_reg + 1'b1; // 否则，计数器加1
    end

    // 生成使能信号
    assign enable = (cnt_reg == N-1) ? 1'b1 : 1'b0; // 当计数器达到N-1时，使能信号置高

endmodule
