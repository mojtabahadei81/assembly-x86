%include "asm_io.inc"

segment .data
	array: dd -5.2,22.3,-33.4,13.8,13.3,22.4,27.1,14.89
	LEN equ ($-array)/4
	SEARCH_ITEM: dd 13.8
	msg1: db "this item is not exist in array",10,0
	msg2: db "this array is full!",10,0
	msg3: db "index of 'SEARCH_ITEM' in array:  ",0
	key: dd 13.8
	key2: dd 6.34
	capacity: dd LEN
	varLen: dd LEN
	
segment .bss
	temp: resd	LEN
	
segment .text
        global  _asm_main
		
_asm_main:
        enter   0,0
        pusha

		; call printArray for initial array (unsorted array)
		push dword [varLen]
		push array
		call printArray
		add esp,8
		
		; call mergeSort function for sort array
		push dword [varLen] ; right
		push 0	 ; left
		push array
		call mergeSort
		add esp, 12
		
		; print sorted array
		push dword [varLen]
		push array
		call printArray
		add esp,8
		
		; call binary_search function for search "SEARCH_ITEM" in sorted array
		mov eax, [varLen]
		dec eax
		push dword [SEARCH_ITEM]
		push eax ; push right
		push 0 ; push left
		push array
		call binary_search
		
		; print result of binary_search.
		; binary_search function returns index of "SEARCH_ITEM" in sorted array to eax.
		; if "SEARCH_ITEM" not found in array binary_search returns '-1' to eax
		push eax
		mov eax,msg3
		call print_string
		pop eax
		call print_int
		call print_nl
		
		; call "deleteElement" for delete float 'key' that defined in segment.data
		push dword [key]
		push dword [varLen]
		push array
		call deleteElement
		add esp,12
		mov [varLen],eax
		
		; print array after deleting key
		push dword [varLen]
		push array
		call printArray
		add esp,8
		
		; call insertElement for insert 'key2' to sorted array
		push dword [capacity]
		push dword [key2]
		push dword [varLen]
		push array
		call insertElement
		add esp,16
		mov [varLen],eax
		
		; print array after inserting
        push dword [varLen]
		push array
		call printArray
		add esp,8
		
		; insert 'key2' again
		mov eax,[varLen]
		push dword [capacity]
		push dword [key2]
		push eax
		push array
		call insertElement
		add esp,16
		mov [varLen],eax
		
		; print array...
        push eax
		push array
		call printArray
		add esp,8
		
		; the end :)
		popa
        mov eax,0
        leave
        ret
		

mergeSort:
		enter 0,0
		pusha
		%define array [ebp+8]
		%define left [ebp+12]
		%define right [ebp+16]
		
		;if(right-left <= 1) -> go to merging
		mov eax, right
		sub eax, left
		cmp eax, 2
		jl endfunc
			
		; calculate middle index
		cdq
		mov ebx, 2
		div ebx
		add eax, left	; middle index
		
		; call mergeSort for smaller section on the left of middle index
		push eax 		; push middle index as right
		push dword left
		push dword array
		call mergeSort
		add esp, 12

		; call mergeSort for smaller section on the right of middle index
		push dword right
		push eax		; push middle index as left
		push dword array
		call mergeSort
		add esp, 12

		; call merge function for merging smaller right and left section of array that sorted before
		push dword right
		push eax 		;middle index
		push dword left
		push dword array
		call merge
		add esp, 16
		
	endfunc:
		popa
		leave
		ret
		
		
		
merge:
		enter 0,0
		pusha
		%define array [ebp+8]
		%define left [ebp+12]
		%define middle [ebp+16]
		%define right [ebp+20]
		
		;calc len of subArray for "rep movsd" in endl
		mov ecx, right
		sub ecx, left
		
		;store address of array[left], array[right] and array[middle] in 'left', 'right' and 'middle'
		mov eax,array
		mov edx,left
		lea ebx,[eax+4*edx]
		mov left,ebx
		mov edx,right
		lea ebx,[eax+4*edx]
		mov right,ebx 
		mov edx,middle
		lea ebx,[eax+4*edx]
		mov middle,ebx

		;edx = tempArray (that defined in segment.bss)
		mov edx, temp

		mov	esi, left 	;esi = &array[left]
		mov edi, middle ;edi = &array[middle]
		
	forloopl:
		cmp esi, middle
		jl while2
		cmp edi, right
		jl while3
		jmp endl

	while2:
		cmp edi, right
		jl if.1
		fld dword [esi]
		fstp dword [edx]
		add edx, 4
		add esi, 4
		jmp forloopl

	while3:
		fld dword [edi]
		fstp dword [edx]
		add edx, 4
		add edi, 4
		jmp forloopl

	if.1:
		fld dword [edi]
		fld dword [esi]
		fcomip st1
		fstp
		ja if.2
		fld dword [esi]
		fstp dword [edx]
		add edx, 4
		add esi, 4
		jmp forloopl

	if.2:
		fld dword [edi]
		fstp dword [edx]
		add edi, 4
		add edx, 4
		jmp forloopl
	
	endl:
		mov esi, temp
		mov edi, left
		rep movsd
		popa
		leave
		ret
		


binary_search:
		enter 4,0
		%define mid [ebp-4]
		%define Array [ebp+8]
		%define left [ebp+12]
		%define right [ebp+16]
		%define searchItem [ebp+20]
		
        mov eax,right
        cmp eax,left
        jl  notFound
		
		; mid = (right + left)/2
		mov eax,right 
        add eax,left  
        shr eax,1
        mov mid,eax 
	
	if_1:
		; if(array[mid] == searchItem)
		mov ecx,Array
        lea eax,[ecx + eax * 4] 
		fld dword [eax] 
        fld dword searchItem
        fxch st1
        fucompp
        fnstsw ax 
        and ah,69 ; 69: ‭01000101‬         
        xor ah,64 ; 64: ‭01000000‬
        jne if_2
        mov eax,mid
        jmp endl2
		
	if_2:
		; if(array[mid] > searchItem)
        fld dword [eax]
        fld dword searchItem
        fxch st1
        fucompp
        fnstsw ax
        test ah,69
        jne callBinarySearchForRight
		
    callBinarySearchForLeft:    
		mov eax,mid 
        dec eax 
        push dword searchItem
        push eax
        push dword left
        push dword Array
        call binary_search
        add esp,16
        jmp endl2
		
	callBinarySearchForRight:
        mov eax,mid
        inc eax
        push dword searchItem
        push dword right 
        push eax 
        push dword Array 
        call binary_search
        add esp,16
        jmp endl2 
	notFound:
		mov eax, msg1
		call print_string
        mov eax, -1
	endl2:
        leave 
        ret
		
		
deleteElement:
        enter 8,0
		%define pos [ebp-4]
		%define i [ebp-8]
		%define Array2 [ebp+8]
		%define len2 [ebp+12]
		%define key [ebp+16]
		
		; finding position of key in sorted array 
        mov eax,len2
		dec eax
		push dword key
		push eax ; push right
		push 0 ; push left
		push dword Array2
		call binary_search
		add esp,16
        
		; if(pos == -1) -> notFound
		mov pos, eax
        cmp pos, dword -1
        jne start_loop
        mov eax, len2 
        jmp endl3
		
	start_loop:
        mov eax,pos
        mov i,eax
		jmp check_loop_conditions

	;arr[i] = arr[i + 1];
	loopde:
        mov eax, i
		mov ecx,Array2
        lea edx, [ecx+eax*4]  
        mov eax, i
        inc eax
        lea ebx, [ecx+eax*4]  
        mov eax, [ebx]
        mov [edx], eax 
        inc dword i
		mov eax,i
	check_loop_conditions:
        mov eax, len2
        dec eax
        cmp eax, i
        jg  loopde
        mov eax, len2
        dec eax
	endl3:
        leave 
        ret
		
		
insertElement:
		enter 4,0
		%define Array3 [ebp+8]
		%define n3 [ebp+12]
		%define key3 [ebp+16]
		%define capacity3 [ebp+20]
		%define j [ebp-4]
		
		; if(n >= capacity) -> return n
		mov eax, n3
        cmp eax, capacity3
        jl startLoop3
		mov eax, msg2
		call print_string
        mov  eax, n3
        jmp  endl4
		
	startLoop3:
        mov eax, n3
        dec eax
        mov j, eax
	loop3:
        cmp dword j, 0
        jl endloop3
        mov eax, dword j
		mov ebx, dword Array3
        fld dword key3
        fld dword [ebx + eax * 4]
        fucompp
        fnstsw ax
        test ah, 69
        jne endloop3
		mov eax, j
		mov ecx, j
		inc ecx
        fld dword [ebx+eax*4]
        fstp dword [ebx+ecx*4]
    lll:    
		dec dword j
        jmp loop3
		
	endloop3:
        mov eax, j
        inc eax
        mov ebx,Array3
        fld dword key3
        fstp dword [ebx+eax*4]
        mov eax, n3
        inc eax
		
	endl4:
        leave
        ret		
		

		
printArray:
		enter 0,0
		pusha
		%define len [ebp+12]
		%define array [ebp+8]
		mov esi,array
		mov ecx,0
		mov edx,len
		dec edx
	loop1:
		lea ebx,[esi+4*ecx]
		mov eax,[ebx]
		call print_float
		mov eax,32
		call print_char
		cmp ecx,edx
		je endloop2
		inc ecx
		jmp loop1
	endloop2:
		call print_nl
		popa
		leave
		ret