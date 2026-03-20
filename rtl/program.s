# -----------------------------------------------------------------------------
#  Continuously read 8 switches and update 8 LEDs
#  Device 1 (LEDs)   base address: 0x1000_0000
#  Device 2 (Switches) base address: 0x2000_0000
# -----------------------------------------------------------------------------

.text
.global _start

_start:
    li   t0, 0x10000000       # t0 = LED base address
    li   t1, 0x20000000       # t1 = Switch base address

loop:
    li   t2, 0                # t2 = index (0..7)

next_led:
    add  a0, t1, t2           # address of switch i
    lbu  a1, 0(a0)            # read switch value (0 or 1)
    add  a2, t0, t2           # address of LED i
    sb   a1, 0(a2)            # write to LED (0 = off, non‑zero = on)

    addi t2, t2, 1            # next index
    li   t3, 8                # total number of LEDs/switches
    blt  t2, t3, next_led     # loop for all 8

    j    loop                 # repeat forever