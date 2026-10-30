.MODEL SMALL
.STACK 100H
.DATA
    HEADER DB 'The 9mul9 table:', 0DH, 0AH, '$'
    CRLF   DB 0DH, 0AH, '$'         ; 回车换行

.CODE
MAIN PROC
    ; 初始化数据段
    MOV AX, @DATA
    MOV DS, AX

    ; 打印表头
    LEA DX, HEADER
    MOV AH, 09H
    INT 21H

    ; 外层循环控制行数
    MOV CX, 9          ; CX 作为外层循环计数器，初始为 9

OUTER_LOOP:
    PUSH CX            ; 保存外层循环的 CX 值

    MOV SI, 1          ; SI 作为内层循环的计数器，从 1 开始

INNER_LOOP:
    ; 准备 CALL 的参数：通过寄存器传递
    ; 当前行数在 CX 中，当前列数在 SI 中
    MOV AX, CX         ; 被乘数
    MOV BX, SI         ; 乘数
    CALL PRINT_EQUATION; 

    ; 打印完一个算式后，打印一个空格（或者制表符，这里用空格模拟截图效果）
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    INT 21H

    INC SI             ; 列数 + 1
    CMP SI, CX         ; 比较 当前列数(SI) 和 当前行数(CX)
    JLE INNER_LOOP 


    ; 内层循环结束，换行
    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    POP CX             ; 【恢复现场】恢复外层循环的 CX 值
    LOOP OUTER_LOOP    ; 外层循环继续 (CX 减 1，若不为 0 则跳转)

    ; 程序结束，返回 DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP

PRINT_EQUATION PROC
    ; 保护现场
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; 先把乘积算出来，存到 CX 里，防止被打印中断破坏
    MOV CX, AX         ; 被乘数
    MOV DX, BX         ; 乘数
    MUL DX             ; AX = AX * BX (真正的乘积)
    MOV DX, AX         ; 把乘积暂存到 DX (不会影响 CX 和 BX 了)

    ; 打印被乘数 (原来在 CX)
    MOV AX, CX
    ADD AL, 30H
    MOV AH, 02H
    ; 此时 AL 里是字符，但我们需要用 DL 打印，而 DX 里存着乘积！
    ; 所以这里必须用 PUSH 保护 DX
    PUSH DX
    MOV DL, AL
    INT 21H
    POP DX

    ; 打印 '*'
    PUSH DX
    MOV DL, '*'
    MOV AH, 02H
    INT 21H
    POP DX

    ; 打印乘数 (原来在 BX)
    MOV AX, BX
    ADD AL, 30H
    PUSH DX
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    POP DX

    ; 打印 '='
    PUSH DX
    MOV DL, '='
    MOV AH, 02H
    INT 21H
    POP DX

    ; 此时 DX 中存的是真正的乘积
    MOV AX, DX
    CMP AL, 9
    JLE SINGLE_DIGIT

    ; 处理两位数
    XOR AH, AH
    MOV DL, 10
    DIV DL             ; AL = 十位, AH = 个位
    PUSH AX
    ADD AL, 30H
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    POP AX
    MOV DL, AH
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    JMP PRINT_END

SINGLE_DIGIT:
    ADD AL, 30H
    MOV DL, AL
    MOV AH, 02H
    INT 21H

PRINT_END:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_EQUATION ENDP

END MAIN