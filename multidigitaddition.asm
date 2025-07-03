section .data
    prompt1 db "First: ", 0      ; Prompt for first number
    prompt2 db "Second: ", 0     ; Prompt for second number
    resultmsg db "Sum: ", 0      ; Message before displaying sum

section .bss
    num1 resb 4                  ; Buffer for first input (up to 3 digits + newline)
    num2 resb 4                  ; Buffer for second input
    sumstr resb 12               ; Buffer for sum as string (max 10 digits + newline + null)

section .text
    global _start

%macro print 2
    mov eax,4                    ; syscall number for print
    mov ebx,1                    ; file descriptor 1 (stdout)
    mov ecx,%1                   ; pointer to message
    mov edx,%2                   ; message length
    int 0x80                     ; make syscall
%endmacro

%macro input 2
    mov eax,3                    ; syscall number for input
    mov ebx,0                    ; file descriptor 0 (stdin)
    mov ecx,%1                   ; pointer to buffer
    mov edx,%2                   ; buffer length
    int 0x80                     ; make syscall
%endmacro

_start:
    ; === Get first number ===
    print prompt1,7          ; Print "First: "
    input num1,4              ; Read up to 4 bytes into num1

    ; Convert first number (supports 1-3 digits)
    mov esi,num1                 ; ESI points to input buffer
    xor eax,eax                  ; Clear EAX (will hold number)
read1:
    mov bl,[esi]                 ; Load next byte from buffer
    cmp bl,10                    ; Check for newline (ASCII 10)
    je done1                     ; If newline, done reading digits
    sub bl,'0'                   ; Convert ASCII to integer
    imul eax,10                  ; Multiply current value by 10 (shift left)
    add eax,ebx                  ; Add new digit
    inc esi                      ; Move to next byte
    jmp read1                    ; Repeat for next digit
done1:
    mov ebx,eax                  ; Store first number in EBX

    ; === Get second number ===
    print prompt2,8          ; Print "Second: "
    input num2,4              ; Read up to 4 bytes into num2

    mov esi,num2                 ; ESI points to second input buffer
    xor eax,eax                  ; Clear EAX for new number
read2:
    mov bl,[esi]                 ; Load next byte
    cmp bl,10                    ; Check for newline
    je done2                     ; If newline, done
    sub bl,'0'                   ; Convert ASCII to integer
    imul eax,10                  ; Multiply by 10
    add eax,ebx                  ; Add digit
    inc esi                      ; Next byte
    jmp read2                    ; Repeat
done2:

    add eax,ebx                  ; Add first and second numbers, result in EAX

    ; === Convert sum to string ===
    mov edi,sumstr+11            ; Point EDI to end of sumstr buffer
    mov byte [edi],10            ; Store newline at end
    dec edi                      ; Move back for digits
    cmp eax,0
    jne convert_loop             ; If sum not zero, convert digits
    mov byte [edi],'0'           ; If sum is zero, store '0'
    jmp print_sum

convert_loop:
    xor edx,edx                  ; Clear EDX for division
    mov ecx,10                   ; Divisor (base 10)
    div ecx                      ; EAX = EAX / 10, EDX = remainder
    add dl,'0'                   ; Convert remainder to ASCII
    mov [edi],dl                 ; Store digit
    dec edi                      ; Move back
    cmp eax,0                    ; More digits?
    jne convert_loop             ; Repeat if so
    inc edi                      ; Adjust EDI to point to first digit

print_sum:
    print resultmsg,5        ; Print "Sum: "
    mov edx, sumstr+12           ; Calculate length of sum string
    sub edx, edi
    print edi, edx           ; Print sum string

    ; === Exit ===
    mov eax,1                    ; syscall number for exit
    xor ebx,ebx                  ; exit code 0
    int 0x80                     ; make syscall