section .data
    prompt db "enter:",0
    promptLen equ $-prompt
section .bss
    num resb 2
    array resb 12
    buffer resb 2
    min resb 2
    
section .text
    global _start
    
%macro display 2
    mov eax,4
    mov ebx,1
    mov ecx,%1
    mov edx,%2
    int 80h
%endmacro
%macro input 2
    mov eax,3
    mov ebx,0
    mov ecx,%1
    mov edx,%2
    int 80h
%endmacro

_start:
    input num,2
    display num,2
    
    mov eax,[num]
    sub eax,'0'
    mov [num],eax
    xor esi,esi
    
input_array:
    movzx eax,byte [num]
    cmp esi,eax
    jge sort
    display prompt, promptLen
    input buffer,2
    movzx eax, byte [buffer]
    ; cmp eax, 10
    ; je input_array 
    sub eax,'0'
    mov [array+esi],eax
    inc esi
    jmp input_array
 
done:   
xor esi,esi
display_array:
    movzx  eax, byte [num]
    cmp esi,eax
    jge exit
    
    mov eax,[array+esi]
    add al,'0'
    mov [buffer],al
    display buffer,1
    inc esi
    jmp display_array
    
sort:
    xor esi, esi             ; i = 0
outer_loop:
    movzx eax, byte [num]
    dec eax                   ; n - 1
    cmp esi, eax
    jge done_sorting

    mov [min], esi            ; min = i

    mov edi, esi
    inc edi                   ; j = i + 1

inner_loop:
    movzx eax, byte [num]
    cmp edi, eax
    jge do_swap               ; if j >= n, inner loop done

    movzx eax, byte [array+edi]
    movzx ebx, byte [min]
    movzx ecx, byte [array+ebx]

    cmp eax, ecx
    jge skip_update_min
    mov [min], edi
skip_update_min:
    inc edi
    jmp inner_loop

do_swap:
    ; Swap array[esi] and array[min]
    movzx eax, byte [min]
    cmp esi, eax
    je skip_swap

    ; Load values
    movzx ebx, byte [array+esi]
    movzx ecx, byte [array+eax]

    ; Do the swap
    mov [array+esi], cl
    mov [array+eax], bl

skip_swap:
    inc esi
    jmp outer_loop

done_sorting:
    jmp done
    
exit:
    mov eax,1
    xor ebx,ebx
    int 80h
    