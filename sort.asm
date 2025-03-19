global _start

section .data
    ; ソート対象の整数配列 (例: 3, 1, 4, 2)
    array   dd 3, 1, 6, 2
    n       equ 4               ; 配列の要素数
    newline     db 0Ah          ; 改行文字

section .bss
    ; 整数→文字列変換用のバッファ（最大 10 桁＋符号＋終端用に12バイト）
    int_buffer  resb 12

section .text
_start:
    ; ----- バブルソートの実装 -----
    ; 外側ループ: 配列要素数 - 1 回の繰り返し
    mov ecx, n
outer_loop:
    dec ecx               ; n-1回のループになる
    jz sorting_done       ; カウンタが0ならソート終了

    mov esi, 0            ; 内側ループのインデックスを0に初期化
inner_loop:
    ; array[esi] と array[esi+1] を比較
    mov eax, [array + esi*4]
    mov ebx, [array + esi*4 + 4]
    cmp eax, ebx
    jle no_swap           ; 既に昇順ならスキップ

    ; 要素の入れ替え
    mov [array + esi*4], ebx
    mov [array + esi*4 + 4], eax

no_swap:
    inc esi               ; 次の要素へ
    cmp esi, ecx        ; 内側ループは外側ループカウンタ分だけ回す
    jl inner_loop

    jmp outer_loop

sorting_done:
    ; ----- ソートされた配列の各値を出力 -----
    mov ecx, n          ; 配列の要素数
    mov esi, array      ; 配列の先頭アドレス
print_loop:
    mov eax, [esi]      ; 次の整数を取得
    call print_int      ; 数値を文字列化して出力
    add esi, 4        ; 次の配列要素へ
    loop print_loop

    ; プログラム終了
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

; -----------------------------------------------------------
; print_int サブルーチン
;  引数: EAX に変換したい整数（負数も対応）
;  出力: 数値を ASCII 文字列に変換して標準出力に書き出す
;         ※変換結果の後に改行も出力します。
; 使用レジスタ: EAX, EBX, ECX, EDX, ESI, EDI（呼び出し前後で復元）
; -----------------------------------------------------------
print_int:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ; --- 負の数の場合、'-'を出力して絶対値に変換 ---
    cmp     eax, 0
    jge     .convert_digits    ; 0以上ならそのまま変換
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
