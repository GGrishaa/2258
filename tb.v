`timescale 1 ns / 1 ps

module system_tb;
    integer fd;

    // === Clocks ===
    reg clk = 1;
    reg f_clk = 1;
    always #5 clk = ~clk;       // 100 MHz

    // === Reset (ACTIVE-HIGH!) ===
    reg rst = 0;  // ← Начинаем с rst=0 (CPU работает!)
    initial begin
        repeat (10) @(posedge clk);
        rst <= 1;            // Активируем сброс (rst=1)
        repeat (10) @(posedge clk);
        rst <= 0;            // ← ОТПУСКАЕМ сброс (rst=0) — CPU запускается!
    end

    // === VCD Dump ===
    initial begin
        $dumpfile("system.vcd");
        $dumpvars(0, system_tb);
    end

    // === GPIO wires ===
    wire [31:0] gpio, gpio1;

    // =========================================
    // === Генератор IRQ (исправленный) ===
    // =========================================
    reg [31:0] irq_counter;  // ← 32 бита!
    wire irq;
    
    // Импульс каждые 10 000 тактов (для быстрой отладки)
    // Для 100 Гц при 100 МГц нужно 1_000_000, но начнём с малого
    assign irq = (irq_counter == 32'd9999); 

    always @(posedge clk) begin
        if (rst) begin
            // При сбросе — обнуляем счётчик
            irq_counter <= 32'd0;
        end else begin
            // В нормальном режиме — считаем
            if (irq_counter >= 32'd9999) begin
                irq_counter <= 32'd0;  // Перезагрузка
            end else begin
                irq_counter <= irq_counter + 1'd1;
            end
        end
    end
    // =========================================

    // === Инстансация Pico_SoC ===
    // Порт .rst подключается к нашему rst (active-high)
    Pico_SoC uut (
        .clk    (clk),
        .f_clk  (f_clk),
        .rst    (rst),     // ← Active-high reset!
        .irq    (irq),     // ← Наш генератор прерываний
        .gpio   (gpio),
        .gpio1  (gpio1)
    );

    // === Завершение симуляции ===
    initial begin
        #50_000_000;  // 50 млн тактов = 0.5 сек при 100 МГц
        $finish;
    end

endmodule                                                                                                                                                                  
