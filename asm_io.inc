	extern  read_int, print_int, print_string, print_double
	extern	read_char, print_char, print_nl, print_float
	extern  sub_dump_regs, sub_dump_mem, sub_dump_math, sub_dump_stack

%macro 	dump_regs 1
	push	  dword %1
	call	  sub_dump_regs
%endmacro

%macro print_flt 1
segment .data
    %%str: dq %1
segment .text
    push eax
	push ebx
    mov eax, [%%str]
	mov ebx, [%%str+4]
    call print_double
    pop ebx
	pop eax
%endmacro

%macro print_str 1
segment .data
    %%str: db %1, 0
segment .text
    push eax
    mov eax, %%str
    call print_string
    pop eax
%endmacro
;
; usage: dump_mem label, start-address, # paragraphs
%macro  dump_mem 3
	push	 dword %1
	push	 dword %2
	push	 dword %3
	call	 sub_dump_mem
%endmacro

%macro	dump_math 1
	push	 dword %1
	call	 sub_dump_math
%endmacro

%macro  dump_stack 3
	push	 dword %3
        push     dword %2
	push	 dword %1
        call     sub_dump_stack
%endmacro