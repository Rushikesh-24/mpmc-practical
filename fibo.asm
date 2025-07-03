section .bss
    num resb 2
    fibo resb 2
    
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
        imul al, 10
        add al, ah
    
    single_digit:
        cmp al, 7
        ja exit           ; exit if input > 7
        mov cl, al        ; number of Fibonacci numbers to print

    mov eax, 0        ; first Fibonacci number
    mov ebx, 1        ; second Fibonacci number

print_fibo:
    cmp cl, 0
    je exit
    mov [fibo], al
    add byte [fibo], '0'
    display fibo,1
    sub byte [fibo], '0'
    mov ecx, eax      ; save current eax (F(n-2)) in ecx
    mov eax, ebx      ; eax = F(n-1)
    add ebx, ecx      ; ebx = F(n) = F(n-1) + F(n-2)
    dec cl
    jmp print_fibo

exit: 
    mov eax,1
    xor ebx,ebx
    int 80h