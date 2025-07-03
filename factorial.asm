section .bss
    num resb 4        ; allocate enough space for 2 digits, newline, and null terminator
    fact resb 2
    
section .text
    global _start
    
%macro display 2
    mov eax, 4
    mov ebx, 1
    lea ecx, %1
    mov edx, %2
    int 80h
%endmacro
%macro input 2
    mov eax, 3
    mov ebx, 0
    lea ecx, %1
    mov edx, %2
    int 80h
%endmacro

_start:
    input num,2
    display num,2
    
    mov al, [num]
    sub al, '0'
    mov bl, al
    mov ax, 1          ; initialize result in ax = 1

factorial:
    mul bl             ; ax = ax * bl
    dec bl
    cmp bl, 1
    jge factorial

exit: 
    ; Convert result in AX to ASCII (supports up to 2 digits)
    mov bx, ax              ; copy result to bx
    mov ax, bx
    mov cx, 10
    xor dx, dx
    div cx                  ; AX / 10, AL = quotient (tens), AH = remainder (units)
    add al, '0'             ; convert tens digit to ASCII
    mov [num], al
    add dl, '0'             ; DL contains remainder after division (units)
    mov [num+1], dl
    mov byte [num+2], 0xA   ; newline for better output
    mov byte [num+3], 0     ; null terminator (optional)
    display num,3
    mov eax,1
    xor ebx,ebx
    int 80h