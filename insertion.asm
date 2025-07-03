
section .data
    string db "Enter number of items: ", 20
    stringLen equ $-string
    string2 db "Enter item ", 20
    string2Len equ $-string2
    string3 db "Entered array is: ", 20
    string3Len equ $-string3
    comma db ": ", 2
    space db " ", 1
    newline db 10
section .bss
    n resb 1
    array resb 100
    temp resb 100
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

%macro showVal 2
    mov esi, %1
    add esi, '0'
    mov [temp], esi
    display temp, %2
%endmacro

%macro printArray 2
        pusha
        movzx esi, byte [%2]
        mov edi, 0
        %%_output_loop:
            cmp esi, edi
            je %%_done_printing
            movzx eax, byte [%1+edi]
            ;add eax, '0'
            mov [temp], eax
            display temp, 1
            display space, 1
            inc edi
            jmp %%_output_loop
        %%_done_printing:
            display newline, 1
            popa
%endmacro

section .text
    global _start

_start:
    display string, stringLen-1
    input n, 2
    movzx esi, byte [n]
    sub esi, '0'
    mov [n], esi
    
    mov edi, 0
    _input_loop:
        cmp esi, edi
        je _sort
        display string2, string2Len-1
        push esi
        showVal edi, 1
        pop esi
        display comma, 2
        input temp, 2
        movzx eax, byte [temp]
        ;sub eax, '0'
        mov [array+edi], eax
        inc edi
        jmp _input_loop
        
    _sort:
        movzx edx, byte [n]
        mov esi, 1
        _iloop:
            cmp esi, edx
            je _end_input_loop
            mov edi, esi
            dec edi
            printArray array, n
            _jloop:
                cmp edi, 0
                jl _done_j
                movzx eax, byte [array+edi+1]
                movzx ebx, byte [array+edi]
                cmp ebx, eax
                jle _done_j
                mov [array+edi+1], bl
                mov [array+edi], al
                dec edi
                jmp _jloop
            _done_j:
                inc esi
                jmp _iloop
                
    _end_input_loop:    
        display string3, string3Len-1
        printArray array, n
    _exit:
        mov eax, 1
        mov ebx, 0
        int 80h