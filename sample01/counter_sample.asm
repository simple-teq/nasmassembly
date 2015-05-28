;*******************************************
; FILE: counter_sample.asm
; 
; $nasm -f elf64 counter_sample.asm
; $gcc -o counter_sample counter_sample.o
; $./counter_sample
;  
;*******************************************
; Assembler Directives
bits 64       ; target processor mode - 64bit

;
; ***********
; count.dat : you have to create this file. it's write only '0'.
; ***********
; 0
;

	; sysmte call	
	SYS_READ	dq	00000000	; read
        SYS_WRITE	dq	00000001	; write
        SYS_OPEN	dq	00000002	; open
	SYS_CLOSE	dq	00000003	; close
	SYS_CREAT	dq	00000085        ; creat
	SYS_BRK		dq	00000012	; brk
	SYS_STAT	dq	00000004	; stat

	; file read parameter
	O_RDONLY	db	00000000	; Read Only
	O_WRONLY	db	00000001	; Write Only
	O_RDWR		dq	00000002	; Read and Write

	; terminal
	STDOUT		dq	00000001	; standard output

	; file path ./count.dat
	FILENAME	db 'count.dat', 00H  
	ERRORTEXT1	db 'ERROR OPEN', 00H 
	ERRORTEXT1_LEN	equ	$-ERRORTEXT1 
	ERRORTEXT2	db 'ERROR READ', 00H
	ERRORTEXT2_LEN	equ	$-ERRORTEXT2 
	ERRORTEXT3	db 'ERROR WRITE', 00H
	ERRORTEXT3_LEN	equ	$-ERRORTEXT3 

section .bss 
	buffer: 	resb 64 
	datalen: 	resw 1 
	handle:		resw 1  

section .text 
	
	global main
main:
	
	; FILE OPEN
FILE_OPEN: 
	mov	rax,	[SYS_OPEN]	; system call OPEN
	mov	rdi,	FILENAME	; file path address
	mov	rsi,	[O_RDWR]	; READ and WRITE
	syscall

	; Check File Open Result
	mov	r10,	rax		; file discriptor to R10
	cmp	rax,	0x00000000	; compare
	jl	c_MSG_ERROR		; rax < 0 then error

FILE_DATA_READ: 
	mov	rax,	[SYS_READ]	; system call READ
	mov	rdi,	r10		; file discriptor
	mov	rsi,	buffer		; read to memory
	mov	rdx,	63		; length 
	syscall
	
	
	;jnc FILE_READ_OK 
	cmp	rax,	0x00000000	; compare
	jl	c_MSG_ERROR_READ	; goto Error Msg

FILE_READ_OK: 
	mov	r13,	rax		; data length
	sub	r13,	1		; 最後の制御文字分(1byte)を減らす

COUNT_INC:  ; 前準備　（数値が格納されている 先頭アドレスと 最終桁のアドレスを保存）
	mov	rsi, buffer		; 読み込み後の先頭アドレス
	mov	r14, r13
	add	r14, buffer		; 文字数（byte）+ 読み込み後の先頭アドレス
	mov	rdi, r14		; 読み込み後の終了アドレス

INC_DIGIT:   ; 各桁の分岐処理 
	cmp	rsi, rdi		; ファイルの先頭 と 処理中の桁アドレスを比較
	jz	INC_DIGIT_1		; 桁上がり発生
	dec	rdi			; address を一つ減算 
	mov	al,	[rdi]		; 対象桁の値を取得 (2byte : ASCIIコード)
	cmp	al,	'9'		; 9かどうかを比較 
	jnz	INC_DIGIT_2     	; 9以外の場合にジャンプ 通常の桁上がり
	mov	al,	'0'		; Ascii コード "0"
	mov	[rdi],	al		; 処理中の桁を"0"に設定 
	jmp INC_DIGIT 

INC_DIGIT_1:  ; 桁上がり発生（全ての桁が9である場合）
	add	r13,	1		; 制御文字を加算
	mov	rcx,	r13		; 元々のデータ長 
	mov	rsi,	buffer		; データの格納されたアドレス
	add	rsi,	rcx		; 桁数を加算
	mov	rdi,	rsi		; 最終桁
	dec	rsi			; 1桁目（アドレスを一つ減らす）
	std 				; movsbを

INC_DIGIT_LOOP: ;数値移動 
	movsb  				; コピー  rsi -> rdi
	loop	INC_DIGIT_LOOP		; データ長分ループ
	mov	rcx,	r13		; 元々のデータ長
	inc	rcx			; 一桁増やす
	mov	r13,	rcx		; データ長に元々の桁数＋1
	mov	al, 	'1'		; '1'を設定。
	mov	[buffer], al		; 最上位の桁に値を設定
	jmp COUNT_INC_END		; 終了

INC_DIGIT_2:   ; 通常のカウントアップ
	inc	al			; inc al ; インクリメント (asciiコードでも大丈夫)
	mov	[rdi],	al		; 対象の桁(アドレス)に値を設定

COUNT_INC_END: 

MOVE_FILE_POINT: ; sys_write 用にファイルポインタを先頭に移動
	
	mov	rax,	8		; system call lseek
	mov	rdi,	r10		; file discriptor
	mov	rsi,	0		; offset (先頭)
	mov	rdx,	0		; SEEK_SET
	syscall

FILE_DATA_WRITE: 
	mov	rax,	[SYS_WRITE]	; system call write
	mov	rdi,	r10		; file discriptor
	mov	rsi,	buffer		; 数値データ
	mov	rdx,	r13		; LENGTH
	syscall	

FILE_CLOSE: 
	mov	rax,	3		;sys_close
	mov	rdi,	r10		; file discriptor
	syscall

c_CONTENT_WRITE:
	mov	rax,	[SYS_WRITE]
	mov	rsi,	buffer		; value
	mov	rdx,	r13		; length
	mov	rdi,	[STDOUT]	; terminal
	syscall

c_WRITE_LF:
	; print LF (= Line Feed)
	mov	rax,	0x0a		; LF
	push	rax
	mov	rdx,	02h		; char length
	lea	rsi,	[rsp]		; [rsp] is stack pointer
	mov	rax, [SYS_WRITE]	; sys_write
	mov	rdi, [STDOUT]		; stdout
	syscall
	pop	rax

c_EXIT:
	;sys_exit(return_code)
	mov	rax,	60	; sys_exit
	mov	rdi,	0	; return 0 (success)
	syscall			; if this is not, then 'segmentaition fault'

c_MSG_ERROR:
	; FILE OPEN ERROR Message
	mov	rdx, ERRORTEXT1_LEN
	mov	rsi, ERRORTEXT1
	mov	rax, [SYS_WRITE]
	mov	rdi, [STDOUT]
	syscall
	jmp	c_WRITE_LF	; write LF & exit

c_MSG_ERROR_READ:
	; FILE READ ERROR Message
	mov	rdx, ERRORTEXT2_LEN
	mov	rsi, ERRORTEXT2
	mov	rax, [SYS_WRITE]
	mov	rdi, [STDOUT]
	syscall
	jmp	c_WRITE_LF	; write LF & exit



