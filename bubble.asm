section .data
    string db "Enter number of items: ", 20         ; Prompt for number of items
    stringLen equ $-string
    string2 db "Enter item ", 20                    ; Prompt for each item
    string2Len equ $-string2
    string3 db "Entered array is: ", 20             ; Message before displaying array
    string3Len equ $-string3
    comma db ": ", 2                                ; Colon and space for formatting
    space db " ", 1                                 ; Space character
    newline db 10                                   ; Newline character

section .bss
    n resb 1                                        ; Stores number of items
    array resb 100                                  ; Array to store input numbers
    temp resb 100                                   ; Temporary storage for input/output

; Macro to display a string
%macro display 2
    mov eax, 4                                      ; sys_write syscall
    mov ebx, 1                                      ; file descriptor: stdout
    lea ecx, %1                                     ; pointer to string
    mov edx, %2                                     ; string length
    int 80h                                         ; call kernel
%endmacro

; Macro to take input from user
%macro input 2
    mov eax, 3                                      ; sys_read syscall
    mov ebx, 0                                      ; file descriptor: stdin
    lea ecx, %1                                     ; buffer to store input
    mov edx, %2                                     ; number of bytes to read
    int 80h                                         ; call kernel
%endmacro

; Macro to show a value (as character)
%macro showVal 2
    mov esi, %1
    add esi, '0'                                    ; Convert number to ASCII
    mov [temp], esi                                 ; Store in temp buffer
    display temp, %2                                ; Display the value
%endmacro

section .text
    global _start

_start:
    display string, stringLen-1                     ; Prompt for number of items
    input n, 2                                      ; Read input into n
    movzx esi, byte [n]                             ; Move input to esi
    sub esi, '0'                                    ; Convert ASCII to integer
    mov [n], esi                                    ; Store integer value in n

    mov edi, 0                                      ; edi = index for array
    _input_loop:
        cmp esi, edi                                ; Check if all items entered
        je _sort                                    ; If yes, jump to sort
        display string2, string2Len-1               ; Prompt for item
        push esi
        showVal edi, 1                              ; Show item number
        pop esi
        display comma, 2                            ; Display ": "
        input temp, 2                               ; Read item input
        movzx eax, byte [temp]                      ; Move input to eax
        ;sub eax, '0'                               ; (Commented out) Convert ASCII to integer
        mov [array+edi], eax                        ; Store input in array
        inc edi                                     ; Next index
        jmp _input_loop                             ; Repeat for next item

    _sort:
        movzx edx, byte [n]                         ; edx = number of items
        mov esi, 0                                  ; Outer loop index (i)
        _iloop:
            cmp esi, edx                            ; i < n?
            je _end_input_loop                      ; If not, end sorting
            mov edi, 0                              ; Inner loop index (j)
            mov ecx, edx
            sub ecx, esi
            dec ecx                                 ; ecx = n - i - 1
            _jloop:
                cmp edi, ecx                        ; j < n-i-1?
                je _done_j                          ; If not, end inner loop

                movzx eax, byte [array+edi]         ; Load array[j]
                movzx ebx, byte [array+edi+1]       ; Load array[j+1]
                cmp ebx, eax                        ; Compare array[j+1] and array[j]
                jge _skipswap                       ; If array[j+1] >= array[j], skip swap
                mov [array+edi+1], al               ; Swap array[j] and array[j+1]
                mov [array+edi], bl

                _skipswap:
                    inc edi                         ; Next j
                    jmp _jloop
            _done_j:
                inc esi                             ; Next i
                jmp _iloop

    _end_input_loop:
        display string3, string3Len-1               ; Display "Entered array is: "
        mov edi, 0                                  ; Index for output
        _output_loop:
            cmp esi, edi                            ; Output all items?
            je _exit                                ; If yes, exit
            movzx eax, byte [array+edi]             ; Load array[edi]
            ;add eax, '0'                           ; (Commented out) Convert to ASCII
            mov [temp], eax                         ; Store in temp
            display temp, 1                         ; Display value
            display space, 1                        ; Display space
            inc edi                                 ; Next item
            jmp _output_loop
    _exit:
        mov eax, 1                                  ; sys_exit syscall
        mov ebx, 0
        int 80h