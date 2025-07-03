section .data
    text db "HELLO, WORLD!", 10      ; The string to reverse, ending with newline
    textlen equ $ - text             ; Length of the string

section .bss
    reversed resb textlen            ; Reserve space for the reversed string

section .text
    global _start

_start:
    mov ecx, textlen                 ; Loop counter = string length
    mov esi, text                    ; Source pointer (start of original)
    lea edi, [reversed + textlen - 1]; Destination pointer (end of reversed buffer)

reverse_copy_loop:
    mov al, [esi]                    ; Load byte from source
    mov [edi], al                    ; Store byte to destination
    inc esi                          ; Move to next source byte
    dec edi                          ; Move destination backward
    loop reverse_copy_loop           ; Repeat for all bytes

    mov eax, 4                       ; sys_write syscall number
    mov ebx, 1                       ; File descriptor: stdout
    mov ecx, reversed                ; Buffer to print
    mov edx, textlen                 ; Number of bytes to print
    int 80h                          ; Make syscall

    mov eax, 1                       ; sys_exit syscall number
    xor ebx, ebx                     ; Exit code 0
    int 80h                          ; Make syscall
