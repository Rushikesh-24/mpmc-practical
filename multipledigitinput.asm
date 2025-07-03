section .bss
    num resb 10
    buffer resb 12

section .text
    global _start

%macro display 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
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
    ; Get input (e.g. "1234\n")
    input num, 9

    ; Parse string to integer
    xor esi, esi
    xor ecx, ecx
parse_loop:
    mov al, [num+esi]
    cmp al, 10       ; newline?
    je parsed_done
    sub al, '0'
    imul ecx, ecx, 10
    add ecx, eax
    inc esi
    jmp parse_loop

parsed_done:
    mov [num], ecx   ; store integer value

    ; Convert integer back to string
    mov eax, [num]
    mov edi, buffer+10
    cmp eax, 0
    jne convert_digits
    mov byte [edi-1], '0'
    mov edi, edi-1
    jmp show_result

convert_digits:
convert_loop:
    xor edx, edx
    mov ecx, 10
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    cmp eax, 0
    jne convert_loop

show_result:
    lea ecx, [edi]
    mov edx, buffer+10
    sub edx, edi
    display ecx, edx

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h