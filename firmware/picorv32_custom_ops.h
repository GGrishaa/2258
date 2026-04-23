#ifndef PICORV32_CUSTOM_OPS_H
#define PICORV32_CUSTOM_OPS_H

/* Вспомогательный макрос: custom0 opcode = 0x0B */
#define __CUSTOM0(f7, rs2, rs1, f3, rd) \
    ( ((f7) << 25) | ((rs2) << 20) | ((rs1) << 15) | ((f3) << 12) | ((rd) << 7) | 0x0B )

/* getq rd, qs: q[qs] -> rd | funct7=0x00, qs в rs1 */
#define GETQ(rd, qs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x00, 0, (qs), 0, (rd))))

/* setq qd, rs: rs -> q[qd] | funct7=0x01, rs в rs1 */
#define SETQ(qd, rs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x01, 0, (rs), 0, (qd))))

/* retirq: возврат из прерывания (PC из q0) | funct7=0x02 */
#define RETIRQ() \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x02, 0, 0, 0, 0)))

/* maskirq rd, rs: rd=old_mask, new_mask=rs | funct7=0x03, rs в rs1 */
#define MASKIRQ(rd, rs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x03, 0, (rs), 0, (rd))))

/* waitirq rd: rd=pending_mask | funct7=0x04 */
#define WAITIRQ(rd) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x04, 0, 0, 0, (rd))))

/* timer rd, rs: rd=old_timer, new_timer=rs | funct7=0x05, rs в rs1 */
#define TIMER(rd, rs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x05, 0, (rs), 0, (rd))))

#endif /* PICORV32_CUSTOM_OPS_H */