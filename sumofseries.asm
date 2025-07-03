section .bss
    num resb 3
    sumstr resb 12
    avgstr resb 12

section .data
    summsg db "Sum: ",0
    avgmsg db 10,"Avg: ",0

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
    input num,3

    ; Convert input to integer (handle up to 2 digits)
    movzx eax, byte [num]
    sub eax, '0'
    movzx ebx, byte [num+1]
    cmp bl, 10
    je .single_digit
    sub ebx, '0'
    imul eax, eax, 10
    add eax, ebx
.single_digit:
    mov ecx, eax      ; ecx = n

    ; Calculate sum = n(n+1)(2n+1)/6
    mov eax, ecx      ; eax = n
    mov ebx, ecx
    inc ebx           ; ebx = n+1
    imul eax, ebx     ; eax = n*(n+1)
    mov ebx, ecx
    shl ebx, 1        ; ebx = 2n
    inc ebx           ; ebx = 2n+1
    imul eax, ebx     ; eax = n*(n+1)*(2n+1)
    mov ebx, 6
    xor edx, edx
    div ebx           ; eax = sum

    push eax          ; save sum for average
    mov esi, sumstr
    call int_to_str   ; convert sum to string

    display summsg, 5
    mov edx, esi
    sub edx, sumstr
    display sumstr, edx

    ; Calculate average = sum / n
    pop eax           ; eax = sum
    mov ebx, ecx      ; ebx = n
    xor edx, edx
    div ebx           ; eax = average

    mov esi, avgstr
    call int_to_str

    mov edx, esi
    sub edx, avgstr
    display avgmsg, 5
    display avgstr, edx

    ; Exit
    mov eax,1
    xor ebx,ebx
    int 80h

;----------------------------------------
; int_to_str: Converts EAX to string at ESI, returns ESI at end of string
;----------------------------------------
int_to_str:
    mov ecx, 0
    mov ebx, 10
    .convert:
        xor edx, edx
        div ebx
        add dl, '0'
        push dx
        inc ecx
        test eax, eax
        jnz .convert
    .out:
        pop dx
        mov [esi], dl
        inc esi
        loop .out
    ret