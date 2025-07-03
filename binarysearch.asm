section .data
    prompt db "enter:",0
    promptLen equ $-prompt
section .bss
    count resb 2
    array resb 12
    buffer resb 2
    
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
    input count,2
    display count,2
    
    mov eax,[count]
    sub eax,'0'
    mov [count],eax
    xor esi,esi
    
input_array:
    movzx eax,byte [count]
    cmp esi,eax
    jge done
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
    movzx  eax, byte [count]
    cmp esi,eax
    jge search
    
    mov eax,[array+esi]
    add al,'0'
    mov [buffer],al
    display buffer,1
    inc esi
    jmp display_array
    
search:
    display prompt,promptLen
    input buffer,2
    movzx eax, byte [buffer]
    sub eax,'0'
    mov [buffer],al

    xor esi,esi                ; esi = low = 0
    movzx edi, byte [count]
    dec edi                    ; edi = high = count-1

binary_search:
    cmp esi, edi
    jg not_found

    mov eax, esi
    add eax, edi
    shr eax, 1                 ; eax = mid = (low+high)/2

    movzx ebx, byte [array+eax] ; ebx = array[mid]
    movzx ecx, byte [buffer]    ; ecx = key

    cmp ebx, ecx
    je found

    jl greater_than            ; if array[mid] < key, search right half

    dec eax                    ; high = mid-1
    mov edi, eax
    jmp binary_search

greater_than:
    inc eax                    ; low = mid+1
    mov esi, eax
    jmp binary_search

found:
    mov byte [buffer], 'F'
    display buffer, 1
    jmp exit

not_found:
    mov byte [buffer], 'N'
    display buffer, 1
    jmp exit
    
exit:
    mov eax,1
    xor ebx,ebx
    int 80h
    