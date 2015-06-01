;------------------------------------------
; insertion_sort.asm
; $nasm -f elf64 insertion_sort.asm
; $ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o insertion_sort insertion_sort.o
; $./insertion_sort
;------------------------------------------

; Assembler Directives
bits 64      ; target processor mode - 64bit

section .data
	array dq  89,10,67,1,4,27,12,34,86,91	; target array (8byte * count)
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
	
	mov  rdi, usort_str	; for output str
	call puts       	; Linux C puts function
	
	call print_array10	; before array print

	; sort
	call sort_routine20	; sort


finish_sort:
	mov  rdi, sort_str	; for output str
	call puts		; print
	add  rsp, 8		; this line need
	call print_array10	; print sort array

	jmp myexit		; goto exit

print_array10:
	mov  rcx, ARRAY_SIZE	; [rsp + 24]	; ARRAY_SIZE
	mov  r15, 0

push_loop:
	push rcx		 ; ARRAY_SIZE / printf destroy RCX 
	mov rsi, [array + r15*8] ; array 
	mov rdi, array_fmt	 ; array format
	call printf		 ; print array[r15]
		
	pop rcx			 ; ARRAY_SIZE store
	inc r15			 ; r15 += 1
	loop push_loop		 ; dec rcx , goto push_loop. if rcx = 0 then goto next
	
	mov  rdi, newline	 ; LF
	call puts		 ;
	ret			 ; return 

sort_routine20:
	; Get the address of the array
	mov  rbx, array 
	mov  rbp, 0		; init loop index

outer_loop:
	; outer loop index
	inc  rbp 		; outer loop start 1 !
	cmp  rbp, ARRAY_SIZE	; finish sort ? rbp = ARRAY_SIZE
	je   finish_sort	;  
	
insert_cmp:
	mov  rdx, [rbx + rbp*8]     ; D array [i  ] value . this is tmp value
	mov  rax, [rbx + (rbp-1)*8] ; A array [i-1] value
	cmp  rdx, rax		; D compare A
	jge  inse_vars		; D >= A

	cmp  rbp, ARRAY_SIZE	; 
	jne  outer_loop		; rbp <> ARRAY_SIZE goto next outer loop

inse_vars:
	mov  r13, rbp		; loop count save
	
inse_vars_loop:
	mov  r14,  [rbx + (r13-1)*8]	  ; array[j-1]
	mov  qword [rbx + (r13  )*8], r14 ; array[j]
	; ret
	dec  r13
	cmp  r13, 0		; swap loop count <= 0
	jle  inse_vars_exit	; loop
	cmp  rdx,  [rbx + (r13-1)*8]  ; next <= tmp
	jle  inse_vars_exit
	jmp  inse_vars_loop	; goto outer_loop


inse_vars_exit:
	mov  qword [rbx + (r13 ) *8], rdx
	jmp  outer_loop


myexit:
	;sys_exit(return_code)
	mov	rax,	60	; sys_exit
	mov	rdi,	0	; return 0 (success)
	syscall			;



