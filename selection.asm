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
        sub eax, '0'
        mov [array+edi], eax
        inc edi
        jmp _input_loop
        
    _sort:
        mov esi, 0
        _iloop:
            movzx edx, byte [n] 
            cmp esi, edx
            je _end_input_loop
            mov ebx, esi
            mov edi, esi
            inc edi
            _jloop:
                movzx edx, byte [n] 
                cmp edi, edx
                je _done_j
                movzx ecx, byte [array+edi]
                movzx eax, byte [array+ebx]
                cmp ecx, eax
                jge _skipsetmin
                mov ebx, edi
                _skipsetmin:
                    inc edi
                    jmp _jloop
                    
                _done_j:
                    movzx ecx, byte [array+esi]
                    movzx eax, byte [array+ebx] 
                    mov [array+esi], al
                    mov [array+ebx], cl
                    inc esi
                    jmp _iloop
                
    _end_input_loop:
        display string3, string3Len-1
        mov edi, 0
        _output_loop:
            cmp esi, edi
            je _exit
            movzx eax, byte [array+edi]
            add eax, '0'
            mov [temp], eax
            display temp, 1
            display space, 1
            inc edi
            jmp _output_loop
    _exit:
        mov eax, 1
        mov ebx, 0
        int 80h