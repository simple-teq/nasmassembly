;*******************************************
; FILE: sample_add.asm
; 
; $nasm -f elf64 sample_add.asm
; $ld -o sample_add sample_add.o
; $./sample_add
;
;  
;*******************************************
; Assembler Directives
bits 64       ; target processor mode - 64bit
section .text ;

global _start
_start:

	; add 3 + 2 = 5 
	mov	rax, 33h ; this is ASCII Code '3'
	mov	rbx,  2h ; for adding 2
	add	rax, rbx ; rax + rbx = 33h + 2h = '3' + 2
	push	rax      ; push stack for print
	mov	rdx, 02h   ; print character length
	lea	rsi, [rsp] ;
	mov	rax, 1 ; sys_write
	mov	rdi, 1 ; stdout
	syscall

	; print LF (= Line Feed)
	mov	rax, 0x0a ; Line Feed
	push	rax
	lea	rsi, [rsp]
	mov	rax, 1 ; sys_write
	mov	rdi, 1 ; stdout
	syscall 

	;sys_exit(return_code)
	mov	rax,	60	; sys_exit
	mov	rdi,	0	; return 0 (success)
	syscall			; if this is not, then 'segmentaition fault'

