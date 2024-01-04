// LED流水灯模块定义
module ledwater(clk, rstn, enable, led);  
    // 输入输出定义
    input clk, rstn, enable;       // 输入：clk（时钟信号），rstn（复位信号），enable（使能信号）
    output [7:0] led;              // 输出：8位LED灯控制

    // 内部寄存器定义
    reg [7:0] led_r;               // 8位寄存器，用于存储LED灯的当前状态

    // 将内部寄存器状态分配给输出
    assign led = led_r;            

    // 时钟事件或复位事件触发的始终块
    always @(posedge clk or negedge rstn)      
    begin
        if (!rstn)
            led_r <= 8'b00000000;     // 当复位信号被激活时，清零所有LED灯
        else if (enable) begin        // 当使能信号为高时，进行LED灯控制
            if (led_r == 8'b11111111)    
                led_r <= 8'b00000000; // 如果所有LED灯均为点亮状态，则重置为全灭
            else
                led_r <= {led_r[6:0], 1'b1}; // 否则，将LED灯向左移动一位并在最右边加一个亮灯
        end
    end
endmodule
