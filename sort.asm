global _start

section .data
    array   dd 3, 1, 6, 2
    n       equ 4

section .bss
    int_buffer  resb 12

section .text
_start:
    mov ecx, n
outer_loop:
    dec ecx
    jz sorting_done

    mov esi, 0
inner_loop:
    mov eax, [array + esi*4]
    mov ebx, [array + esi*4 + 4]
    cmp eax, ebx
    jle no_swap

    mov [array + esi*4], ebx
    mov [array + esi*4 + 4], eax

no_swap:
    inc esi
    cmp esi, ecx
    jl inner_loop

    jmp outer_loop

sorting_done:
    mov ecx, n
    mov esi, array
print_loop:
    mov eax, [esi]
    call print_int
    add esi, 4
    loop print_loop

    mov eax, 1
    xor ebx, ebx
    int 0x80

print_int:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    jmp .convert_digits

.convert_digits:
    lea     edi, [int_buffer + 11]
    mov     byte [edi], 0
    dec     edi
    cmp     eax, 0
    jne     .convert_loop
    mov     byte [edi], '0'
    jmp     .print_number

.convert_loop:
.convert_digit_loop:
    xor     edx, edx
    mov     ebx, 10
    div     ebx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    cmp     eax, 0
    jne     .convert_digit_loop

.print_number:
    lea     ecx, [edi+1]
    lea     ebx, [int_buffer + 11]
    sub     ebx, ecx
    mov     eax, 4
    mov     edx, ebx
    mov     ebx, 1
    int     0x80

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     ebp
    ret