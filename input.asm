.ORIG x4000

ST R7, SAVE_R7
ST R1, SAVE_R1
ST R2, SAVE_R2

; Read first digit
GETC
OUT
LD R1, NEG_ASCII
ADD R0, R0, R1

; Multiply first digit by 10
ADD R1, R0, R0
ADD R2, R1, R1
ADD R2, R2, R2
ADD R2, R2, R1

; Read second digit
GETC
OUT
LD R1, NEG_ASCII
ADD R0, R0, R1

; Calculate final decimal value
ADD R0, R2, R0

; Restore registers
LD R1, SAVE_R1
LD R2, SAVE_R2
LD R7, SAVE_R7

RET

NEG_ASCII .FILL #-48
SAVE_R7   .BLKW #1
SAVE_R1   .BLKW #1
SAVE_R2   .BLKW #1

.END
