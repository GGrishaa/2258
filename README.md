# Учебный проект: Полное портирование операционной системы реального времени FreeRTOS на процессорное ядро PicoRV32 с обработкой прерываний через Q-регистры и custom-инструкции.
Данный репозиторий содержит полное портирование FreeRTOS на размерно-оптимизированное процессорное ядро PicoRV32 архитектуры RISC-V. Особенностью PicoRV32 является то, что оно не использует стандартные CSR-регистры RISC-V. Вместо этого для обработки прерываний применяются custom-инструкции (getq, setq, retirq), работающие через аппаратные Q-регистры.

### Что работает:
- Вытесняющая многозадачность
- Полное сохранение/восстановление контекста (32 регистра + PC)
- Аппаратный таймер системного тика (1 кГц)
- Переключение задач через vTaskSwitchContext()
- Критические секции через portENTER_CRITICAL()
- Механизм Q-регистров для IRQ
- Симуляция в Icarus Verilog

### Требования:
Для macOS riscv-tools, icarus-verilog, surfer/gtkwave, make

### Сборка и запуск симуляции:
git clone https://github.com/GGrishaa/2258.git
cd 2258
git checkout freertos-port
cd firmware
make rebuild
cd ..
./sim.sh | grep GPIO

### Ожидаемый вывод:
GPIO_WRITE at 0: data=cccccccc  # Задача 3: паттерн C
GPIO_WRITE at 0: data=aaaaaaaa  # Задача 1: паттерн A  
GPIO_WRITE at 0: data=22222222  # Задача 2: паттерн 2
... циклическое переключение задач

### Структура проекта:
picorv32-freertos/
├── README.md                         # Этот файл
├── firmware/
│   ├── FreeRTOS/                     # Ядро FreeRTOS (подмодуль)
│   │   ├── Source/
│   │   │   ├── include/              # Заголовки FreeRTOS
│   │   │   ├── portable/
│   │   │   │   └── GCC/RISC-V/
│   │   │   ├── tasks.c, queue.c, list.c
│   ├── FreeRTOSConfig.h              # Конфигурация RTOS для проекта
│   ├── port.c                        # Инициализация стека, таймера, запуск планировщика
│   ├── portmacro.h                   # Определения типов, макросы критических секций
│   ├── start.S                       # Вектор IRQ, сохранение/восстановление контекста (КЛЮЧЕВОЙ ФАЙЛ)
│   ├── main.c                        # Демонстрация: 3 задачи-мигалки через GPIO
│   ├── picorv32_custom_ops.h         # Макросы для custom0-инструкций
│   ├── linker.ld                     # Карта памяти для симуляции
│   └── Makefile                      # Правила сборки для riscv-none-elf-gcc
├── picosoc/
│   ├── picosoc.v                     # Обёртка SoC с таймером и GPIO
│   ├── simpleuart.v                  # Опциональный UART для будущего расширения
│   └── sections.lds                  # Скрипт линковки для выполнения из SPI flash
├── picorv32.v                        # Ядро PicoRV32 (ENABLE_IRQ=1, ENABLE_IRQ_QREGS=1)
├── tb_freertos.v                     # Тестбенч: тактирование, сброс, дамп VCD
├── sim.sh                            # Скрипт симуляции (iverilog + vvp)
└── freertos.vcd                      # Сгенерированный файл осциллограмм

### Ссылки:
- Исходный код PicoRV32: https://github.com/YosysHQ/picorv32.git
- Исходный код FreeRTOS: https://github.com/FreeRTOS/FreeRTOS-Kernel.git
