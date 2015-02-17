;*******************************************
; FILE: hello_world64.asm
; 
; $nasm -f elf64 hello_world64.asm
; $ld -o hello_world64 hello_world64.o
; $./hello_world64
;  Hello World!
; $ 
;*******************************************

; Assembler Directives
bits 64    ; target processor mode - 64bit

section .data
	hlw : db  'Hello World!', 0x0a

section .text ;

global _start
_start:
	; this is comment
	mov	rax, 1   ; sys_write
	mov	rdi, 1   ; stdout

	mov	rsi, hlw ; This is Hello World! address 
	
	; length ( 12byte + 1byte(0x0a: Line Feed) )
	mov	rdx, 13  ; 
	syscall          ; execute sys_write

exit:
	; sys_exit (return_code)
	mov	rax, 60    ; sys_exit
	mov	rdi,  0    ; return 0 (Success)
	syscall



