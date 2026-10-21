.MODEL SMALL
.STACK 100H

.DATA
    msg1 DB 'Please input a Hex number (0-FF):',13,10,'$'
    msg2 DB 'The Dec number:',13,10,'$'
    msg3 DB 'Please input a Dec number (0-255):',13,10,'$'
    msg4 DB 'The Hex number:',13,10,'$'
    msgErr DB 'Invalid input!',13,10,'$'
    crlf DB 13,10,'$'

    buffer DB 8,0,8 DUP(0)

.CODE
START:
    MOV AX,@DATA
    MOV DS,AX

    ; Hexadecimal input
    LEA DX,msg1
    MOV AH,09H
    INT 21H

    CALL READ_LINE

    XOR CX,CX
    MOV CL,buffer[1]

    CMP CX,1
    JAE HEX_MIN_OK
    JMP BAD_INPUT

HEX_MIN_OK:
    CMP CX,2
    JBE HEX_LENGTH_OK
    JMP BAD_INPUT

HEX_LENGTH_OK:
    LEA SI,buffer[2]
    XOR BX,BX

HEX_LOOP:
    MOV AL,[SI]
    CALL HEX_DIGIT
    JNC HEX_CHAR_OK
    JMP BAD_INPUT

HEX_CHAR_OK:
    XOR AH,AH
    SHL BX,1
    SHL BX,1
    SHL BX,1
    SHL BX,1
    ADD BX,AX

    INC SI
    LOOP HEX_LOOP

    LEA DX,msg2
    MOV AH,09H
    INT 21H

    MOV AX,BX
    MOV BX,10
    CALL PRINT_NUMBER
    CALL NEWLINE

    ; Decimal input
    LEA DX,msg3
    MOV AH,09H
    INT 21H

    CALL READ_LINE

    XOR CX,CX
    MOV CL,buffer[1]

    CMP CX,1
    JAE DEC_MIN_OK
    JMP BAD_INPUT

DEC_MIN_OK:
    CMP CX,3
    JBE DEC_LENGTH_OK
    JMP BAD_INPUT

DEC_LENGTH_OK:
    LEA SI,buffer[2]
    XOR BX,BX

DEC_LOOP:
    MOV AL,[SI]

    CMP AL,'0'
    JAE DEC_LOWER_OK
    JMP BAD_INPUT

DEC_LOWER_OK:
    CMP AL,'9'
    JBE DEC_CHAR_OK
    JMP BAD_INPUT

DEC_CHAR_OK:
    SUB AL,'0'
    XOR AH,AH
    MOV DI,AX

    MOV AX,BX
    MOV DX,10
    MUL DX
    ADD AX,DI

    CMP AX,255
    JBE DEC_VALUE_OK
    JMP BAD_INPUT

DEC_VALUE_OK:
    MOV BX,AX
    INC SI
    LOOP DEC_LOOP

    LEA DX,msg4
    MOV AH,09H
    INT 21H

    MOV AX,BX
    MOV BX,16
    CALL PRINT_NUMBER
    CALL NEWLINE

    MOV AX,4C00H
    INT 21H

BAD_INPUT:
    LEA DX,msgErr
    MOV AH,09H
    INT 21H

    MOV AX,4C01H
    INT 21H

; Read a line using DOS function 0AH
READ_LINE PROC NEAR
    MOV buffer[1],0
    LEA DX,buffer
    MOV AH,0AH
    INT 21H
    CALL NEWLINE
    RET
READ_LINE ENDP

; Input: AL = hexadecimal character
; Output: AL = 0..15, CF = 0
; Invalid character: CF = 1
HEX_DIGIT PROC NEAR
    CMP AL,'0'
    JB HEX_BAD
    CMP AL,'9'
    JBE HEX_NUM

    CMP AL,'A'
    JB HEX_BAD
    CMP AL,'F'
    JBE HEX_UPPER

    CMP AL,'a'
    JB HEX_BAD
    CMP AL,'f'
    JA HEX_BAD

    SUB AL,'a'
    ADD AL,10
    CLC
    RET

HEX_UPPER:
    SUB AL,'A'
    ADD AL,10
    CLC
    RET

HEX_NUM:
    SUB AL,'0'
    CLC
    RET

HEX_BAD:
    STC
    RET
HEX_DIGIT ENDP

; Input: AX = unsigned number, BX = base (10 or 16)
PRINT_NUMBER PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX,CX

DIVIDE_LOOP:
    XOR DX,DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX,0
    JNE DIVIDE_LOOP

OUTPUT_LOOP:
    POP DX
    CMP DL,9
    JBE NUMBER_DIGIT
    ADD DL,7

NUMBER_DIGIT:
    ADD DL,'0'
    MOV AH,02H
    INT 21H
    LOOP OUTPUT_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

NEWLINE PROC NEAR
    PUSH AX
    PUSH DX

    LEA DX,crlf
    MOV AH,09H
    INT 21H

    POP DX
    POP AX
    RET
NEWLINE ENDP

END START