.section .init
.global main

/* set stack pointer */
lui sp, %hi(16368) //16*1024
addi sp, sp, %lo(16368) 

/* call main */
jal ra, main

/* break */
ebreak
