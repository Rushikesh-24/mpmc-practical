section .bss
    num resb 2
    result resb 8      ; buffer for result string

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

    mov al, [num]
    sub al, '0'
    mov ah, [num+1]
    cmp ah, 10         ; check for newline (ASCII 10)
    jne convert_second_digit
    jmp single_digit

convert_second_digit:
    sub ah, '0'
    mov ah, 10
    mul ah           ; al = al * 10, result in ax
    add al, ah

single_digit:
    movzx eax, al      ; eax = x

    ; Calculate x^2
    mov ebx, eax
    imul ebx, eax      ; ebx = x^2

    ; Calculate x^3
    mov ecx, eax
    imul ecx, ebx      ; ecx = x^3

    ; f(x) = x^3 + x^2 + 12
    add ecx, ebx       ; ecx = x^3 + x^2
    add ecx, 12        ; ecx = x^3 + x^2 + 12

    ; Convert ecx to ASCII string in 'result'
    mov edi, result
    mov eax, ecx
    mov ecx, 0         ; digit count

convert_loop:
    mov edx, 0
    mov ebx, 10
    div ebx            ; eax = eax / 10, edx = remainder
    add dl, '0'
    push dx
    inc ecx
    test eax, eax
    jnz convert_loop

print_digits:
    pop dx
    mov [edi], dl
    inc edi
    loop print_digits

    ; Display result
    mov edx, result
    sub edi, edx
    display result, edi

exit:
    mov eax,1
    xor ebx,ebx
    int 80h