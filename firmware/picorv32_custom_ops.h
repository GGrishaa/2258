#ifndef PICORV32_CUSTOM_OPS_H
#define PICORV32_CUSTOM_OPS_H

#define __CUSTOM0(f7, rs2, rs1, f3, rd) \
    ( ((f7) << 25) | ((rs2) << 20) | ((rs1) << 15) | ((f3) << 12) | ((rd) << 7) | 0x0B )

#define GETQ(rd, qs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x00, 0, (qs), 0, (rd))))

#define SETQ(qd, rs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x01, 0, (rs), 0, (qd))))

#define RETIRQ() \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x02, 0, 0, 0, 0)))

#define MASKIRQ(rd, rs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x03, 0, (rs), 0, (rd))))

#define WAITIRQ(rd) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x04, 0, 0, 0, (rd))))

#define TIMER(rd, rs) \
    __asm__ volatile (".word %0" :: "i"(__CUSTOM0(0x05, 0, (rs), 0, (rd))))

#endif /* PICORV32_CUSTOM_OPS_H */