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
    xor esi,esi

loop:
    movzx eax,byte [count]
    cmp eax,esi
    je not_found

    movzx eax, byte [array+esi]
    movzx ebx, byte [buffer]
    cmp eax, ebx
    je found
    inc esi
    jmp loop
    

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
    