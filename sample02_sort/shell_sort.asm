;------------------------------------------
; shell_sort.asm
; $nasm -f elf64 shell_sort.asm
; $ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o shell_sort shell_sort.o
; $./shell_sort
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
	; init gap loop 
	; if rsi = 0 then exit sort routin20
	mov  rsi,  ARRAY_SIZE	; this is gap value

outer_ex_loop:
	; rsi / 2 = gap 
	; ex. 10 / 2 = 5        : this is first gap value
	mov  rax, rsi		; A
	mov  rbx, 2		; B
	mov  rdx, 0		; this is need 
	div  rbx		; A / B = answer (RAX)
	cmp  rax,  0x00		; if rax = 0 
	je   finish_sort	; exit sourt routine

	mov  rsi,  rax	 	; for next gap
	mov  rbx, array		; get the address of the array
	
	mov  rbp, 0		; init loop index 

outer_loop:
	; insertion sort start
	add  rbp, rsi		; rbp + rsi (gap). ex. 0 + 5 = 5
	cmp  rbp, ARRAY_SIZE	; finish sort ? rbp >= ARRAY_SIZE
	jge  outer_ex_loop	; next loop
	
insert_cmp:
	mov  rdx, [rbx + rbp*8] ; D array [i  ] value . this is tmp value

	; two register no good 
	; [rbx + (rbp - rsi)]    : is no good
	mov  r9, rbp
	sub  r9, rsi
	mov  rax, [rbx + (r9)*8] ; A array [i-gap] value

	cmp  rdx, rax		 ; D compare A
	jge  inse_vars		 ; D >= A

	jne  outer_loop		 ; goto next outer loop

inse_vars:
	mov  r13, rbp		 ; insertion loop count save
	
inse_vars_loop:
	sub  r13,  rsi		   ; for [ j - 1] 
	mov  r14,  [rbx + (r13)*8] ; from array[j-1]

	add  r13,  rsi                  ; for [ j ]
	mov  qword [rbx + (r13)*8], r14 ; to   array[j]
	sub  r13,  rsi
	cmp  r13, 0		; swap loop count <= 0
	jl   inse_vars_exit	; loop exit
	
	cmp  rdx,  [rbx + (r13)*8] ; tmp <= next
	jle  inse_vars_exit        ; loop exit
	jmp  inse_vars_loop	   ; goto outer_loop


inse_vars_exit:
	add  r13,  rsi		         ; for [ j ] / insertion index
	mov  qword [rbx + (r13) *8], rdx ; value to array[j]
	jmp  outer_loop			 ; next value


myexit:
	;sys_exit(return_code)
	mov	rax,	60	; sys_exit
	mov	rdi,	0	; return 0 (success)
	syscall			;



