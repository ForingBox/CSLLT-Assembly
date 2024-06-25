.MODEL small
.STACK 1000h

.DATA
    msg1 db "Hi, what group would you like to join?", 13, 10
    msg1_len = $ - msg1
    msg2 db "The Founders", 13, 10
    msg2_len = $ - msg2
    msg3 db "The Vox Populi", 13, 10
    msg3_len = $ - msg3
    msg4 db "Blinkers", 13, 10
    msg4_len = $ - msg4

.CODE

main PROC
    mov ax, @data
    mov ds, ax              ; Don't forget to initialize DS!
    mov es, ax              ; Segment needed for Int 10h/AH=13h

    lea bp, msg1            ; ES:BP = Far pointer to string
    mov cx, msg1_len        ; CX = Length of string
    mov bl, 2               ; green (http://stackoverflow.com/q/12556973/3512216)
    call print

    lea bp, msg2            ; ES:BP = Far pointer to string
    mov cx, msg2_len        ; CX = Length of string
    mov bl, 3               ; blue (http://stackoverflow.com/q/12556973/3512216)
    call print

    lea bp, msg3            ; ES:BP = Far pointer to string
    mov cx, msg3_len        ; CX = Length of string
    mov bl, 4               ; red (http://stackoverflow.com/q/12556973/3512216)
    call print

    lea bp, msg4            ; ES:BP = Far pointer to string
    mov cx, msg4_len        ; CX = Length of string
    mov bl, 8Eh             ; blinking yellow (Bit7 set, works at least in DOSBox)
    call print

    mov ax, 4C00h           ; Return 0
    int 21h
main ENDP

print PROC                  ; Arguments:
                            ;   ES:BP   Pointer to string
                            ;   CX      Length of string
                            ;   BL      Attribute (color)

    ; http://www.ctyme.com/intr/rb-0088.htm
    push cx                 ; Save CX (needed for Int 10h/AH=13h below)
    mov ah, 03h             ; VIDEO - GET CURSOR POSITION AND SIZE
    xor bh, bh              ; Page 0
    int 10h                 ; Call Video-BIOS => DX is current cursor position
    pop cx                  ; Restore CX

    ; http://www.ctyme.com/intr/rb-0210.htm
    mov ah, 13h             ; VIDEO - WRITE STRING (AT and later,EGA)
    mov al, 1               ; Mode 1: move cursor
    xor bh, bh              ; Page 0
    int 10h                 ; Call Video-BIOS

    ret
print ENDP

END main