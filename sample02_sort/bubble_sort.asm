;------------------------------------------
; bubble_sort.asm
; $nasm -f elf64 bubble_sort.asm
; $ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o bubble_sort bubble_sort.o
; $./bubble_sort
;------------------------------------------

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
	
	mov  rdi, usort_str	; for output str
	call puts       	; Linux C puts function
	
	call print_array10	; before array print

	; selection sort
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

	; Store array size
	mov  rcx, ARRAY_SIZE

outer_loop:
	; This stores the min index
	mov  rbp, 0	 ; i 
	dec  rcx	 ; outer loop limit decrement
	
	cmp  rcx, 0	 ; finish sort ?
	je   finish_sort 
	
	
inner_loop:
	cmp  rbp, rcx		; inner loop finish ?
	je   outer_loop		; goto next outer loop
	xor  rax, rax		; clear 
	mov  rdx, [rbx + rbp*8]     ; D array[i  ] value
	mov  rax, [rbx + (rbp+1)*8] ; A array[i+1] value
	cmp  rax, rdx		; A compare D
	jge  swap_vars		; A >= D 
	
	inc  rbp		; inner index ++
	jmp  inner_loop		; next

swap_vars:
	mov  rdx,  [rbx + rbp*8]	; array[i  ]
	mov  rax,  [rbx + (rbp+1)*8] 	; array[i+1]
	mov  qword [rbx + (rbp+1)*8], rdx ; array[i+1]
	mov  qword [rbx + rbp*8    ], rax ; array[i  ]
	; ret
	inc  rbp
	jmp inner_loop		; dec rcx , goto outer_loop


myexit:
	;sys_exit(return_code)
	mov	rax,	60	; sys_exit
	mov	rdi,	0	; return 0 (success)
	syscall			;



