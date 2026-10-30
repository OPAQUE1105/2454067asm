.MODEL SMALL
.STACK 100H

MODE EQU 0                    ; 0：寄存器，1：数据段，2：栈
INPUT_N EQU 1                 ; 0：固定100，1：用户输入

.DATA
    prompt DB 'Please input n (1-100):',13,10,'$'
    errmsg DB 'Invalid input!',13,10,'$'
    crlf   DB 13,10,'$'
    buffer DB 8,0,8 DUP(0)     ; 容量、实际长度、字符区
    total  DW 0

.CODE
START:
    MOV AX,@DATA
    MOV DS,AX

IF INPUT_N EQ 1
    LEA DX,prompt
    MOV AH,09H
    INT 21H

    ; 读取一行输入
    LEA DX,buffer
    MOV AH,0AH
    INT 21H

    LEA DX,crlf
    MOV AH,09H
    INT 21H

    XOR CX,CX
    MOV CL,buffer[1]

    ; 检查输入长度为1～3
    CMP CX,1
    JAE MIN_LENGTH_OK
    JMP BAD_INPUT

MIN_LENGTH_OK:
    CMP CX,3
    JBE LENGTH_OK
    JMP BAD_INPUT

LENGTH_OK:
    LEA SI,buffer[2]
    XOR BX,BX

READ_LOOP:
    MOV AL,[SI]

    ; 检查当前字符是否为数字
    CMP AL,'0'
    JAE MIN_DIGIT_OK
    JMP BAD_INPUT

MIN_DIGIT_OK:
    CMP AL,'9'
    JBE DIGIT_OK
    JMP BAD_INPUT

DIGIT_OK:
    SUB AL,'0'
    XOR AH,AH
    MOV DI,AX

    ; 累计值 = 原值×10 + 当前位
    MOV AX,BX
    MOV DX,10
    MUL DX
    ADD AX,DI

    CMP AX,100
    JBE VALUE_OK
    JMP BAD_INPUT

VALUE_OK:
    MOV BX,AX
    INC SI
    LOOP READ_LOOP

    CMP BX,1
    JAE NUMBER_OK
    JMP BAD_INPUT

NUMBER_OK:
    MOV CX,BX
ELSE
    MOV CX,100
ENDIF

IF MODE EQ 0
    ; 在AX中累计n+(n-1)+...+1
    XOR AX,AX
REG_LOOP:
    ADD AX,CX
    LOOP REG_LOOP
ENDIF

IF MODE EQ 1
    ; 在数据段变量total中累计
    MOV total,0
MEM_LOOP:
    ADD total,CX
    LOOP MEM_LOOP
    MOV AX,total
ENDIF

IF MODE EQ 2
    ; 累计值保存在栈顶，每轮取出、更新并压回
    XOR AX,AX
    PUSH AX
STACK_LOOP:
    POP AX
    ADD AX,CX
    PUSH AX
    LOOP STACK_LOOP
    POP AX
ENDIF

    CALL PRINT_DEC

    LEA DX,crlf
    MOV AH,09H
    INT 21H

    MOV AX,4C00H
    INT 21H

BAD_INPUT:
    LEA DX,errmsg
    MOV AH,09H
    INT 21H
    MOV AX,4C01H
    INT 21H

; 将AX中的无符号整数转换为十进制输出
PRINT_DEC PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX,10
    XOR CX,CX

DIV_LOOP:
    XOR DX,DX
    DIV BX                    ; AX存商，DX存余数
    PUSH DX                   ; 余数压栈，实现逆序输出
    INC CX
    CMP AX,0
    JNE DIV_LOOP

PRINT_LOOP:
    POP DX
    ADD DL,'0'                ; 数值转换为ASCII字符
    MOV AH,02H
    INT 21H
    LOOP PRINT_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DEC ENDP

END START