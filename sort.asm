global _start

section .data
    array   dd 3, 1, 6, 2
    n       equ 4
    newline     db 0Ah

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

    cmp     eax, 0
    jge     .convert_digits
    ; 負の場合
    neg     eax               ; 絶対値にする
    mov     byte [int_buffer], '-'  ; '-' をバッファ先頭に格納
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, int_buffer
    mov     edx, 1
    int     0x80

.convert_digits:
    ; int_buffer の末尾（バッファサイズ12）から逆順に数字を格納
    lea     edi, [int_buffer + 11]
    mov     byte [edi], 0     ; 終端用のヌル（sys_writeでは使わないが）
    dec     edi

    ; もし EAX が 0 の場合は、そのまま '0' を格納
    cmp     eax, 0
    jne     .convert_loop
    mov     byte [edi], '0'
    jmp     .print_number

.convert_loop:
    ; EAX が 0 になるまで10で割り、余りを文字に変換
.convert_digit_loop:
    xor     edx, edx
    mov     ebx, 10
    div     ebx               ; quotient in EAX, remainder in EDX
    add     dl, '0'           ; ASCII変換
    mov     [edi], dl
    dec     edi
    cmp     eax, 0
    jne     .convert_digit_loop

.print_number:
    ; ここで、数字文字列は (edi+1) から int_buffer+11 までに格納されている
    lea     ecx, [edi+1]      ; 出力する文字列の先頭アドレス
    lea     ebx, [int_buffer + 11]
    sub     ebx, ecx        ; 出力する文字数を計算
    mov     eax, 4          ; sys_write
    mov     edx, ebx        ; 出力文字数
    mov     ebx, 1          ; stdout
    int     0x80

    ; 数値出力後に改行を出力
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     ebp
    ret
