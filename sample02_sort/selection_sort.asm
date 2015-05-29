;------------------------------------------
; selection_sort.asm
; $nasm -f elf64 selection_sort.asm
; $ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o selection_sort selection_sort.o
; $./selection_sort
;------------------------------------------

; 
; Thank you !
; http://www.ibm.com/developerworks/jp/linux/library/l-gas-nasm.html
;

; Assembler Directives
bits 64      ; target processor mode - 64bit

section .data
	array dq  89,10,67,1,4,27,12,34,86,3	; target array (8byte * count)
	ARRAY_SIZE equ ($ - array) / 8		; ($ - array) = 8byte * count
	array_fmt db '  %d ', 10, 0		; message formt (for C Lib)
	usort_str db 'unsorted array:', 0	; message 1
	sort_str  db 'sorted   array:', 0	; message 2
	newline   db 10, 0			; LF (0x0a)
	buff  dd  0				; buffer

section .text ;
	; standard C Library
	extern puts		; writes strings 
	extern printf		; print string 

global _start
_start:
	
	push usort_str  	; for output str
	mov  rdi, [rsp] 	; for output str
	call puts       	; Linux C puts function
	add  rsp, 8     	; this is stack pointer init 32bit

	; to stack	
	push ARRAY_SIZE		; array count
	push array		; target array
	push array_fmt		; for message
	call print_array10	; before array

	; selection sort
	push ARRAY_SIZE		; array count
	push qword array	; array
	call sort_routine20	; sort

	; Adjust the stack pointer
	push sort_str
	mov  rdi, [rsp]
	call puts
	add  rsp, 8
	
	push ARRAY_SIZE
	push array
	push array_fmt
	call print_array10

	jmp myexit		; goto exit

print_array10:
	mov  rbp, [rsp]		; stack pointer -> func ret
	mov  rdx, [rsp +  8]	; array_fmt NG:rbp + 8 ?
	mov  rbx, [rsp + 16]	; array
	mov  rcx, [rsp + 24]	; ARRAY_SIZE
	mov  rsi, 0
	mov  r15, 0

push_loop:
	; save to stack
	push rcx   		; ARRAY_SIZE
	push rdx   		; array_fmt
	push rbx   		; array
	mov rsi, [rbx + r15*8]	; rcx
	xor rax, rax		;
	mov rdi, rdx		;
	call printf		; print arrays
	
	pop rbx			; array
	pop rdx			; array_fmt
	pop rcx			; ARRAY_SIZE
	inc r15			; r15 = 1
	loop push_loop		; dec rcx , goto push_loop
	
	push newline		; LF
	mov  rdi, [rsp]		;
	call puts		;
	pop  rdi		;
	ret			; return 

sort_routine20:
	mov  rbp, [rsp] 	; retunr address
	
	; Get the address of the array
	mov  rbx, [rsp+8]	
	; Store array size
	mov  rcx, [rsp+16]
	dec  rcx

	; Prepare for outer loop here
	xor  rsi, rsi

outer_loop:
	; This stores the min index
	mov  rbp, rsi  ; i 
	mov  rdi, rsi  ; index of min
	inc  rdi       ; i ++1
	
inner_loop:
	cmp  rdi, ARRAY_SIZE	; compare last index
	jge  swap_vars		; change value
	xor  rax, rax		; clear 
	mov  rdx, [rbx + rbp*8] ; D arra[i] address
	mov  rax, [rbx + rdi*8] ; A array[min] address
	cmp  rdx, rax    	; D compare A
	jge  check_next  	; D >= A
	mov  rbp, rdi    	; change index min

check_next:
	inc  rdi		; rdi++
	jmp  inner_loop		; goto inner Loop

swap_vars:
	mov  rdx, [rbx + rbp*8] ; min value address
	mov  rax, [rbx + rsi*8] ; target value
	mov  qword [rbx + rsi*8], rdx ;
	mov  qword [rbx + rbp*8], rax ;
	inc  rsi
	loop outer_loop		; dec rcx , goto outer_loop

	ret

myexit:
	;sys_exit(return_code)
	mov	rax,	60	; sys_exit
	mov	rdi,	0	; return 0 (success)
	syscall			;



