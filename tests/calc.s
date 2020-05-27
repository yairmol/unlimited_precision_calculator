; a macro that recives one argument and pushed it to the operand stack
%macro push_operand_stack 1
  push ebx 
  mov ebx, [stack_max_size]
  cmp [stack_size], ebx
  je %%pushing_error
  inc dword [stack_size]
  mov ecx, [stack_pointer]
  mov dword [ecx], %1
  add dword [stack_pointer], 4
  jmp %%end_of_push
  %%pushing_error:
  pushad
  push push_error_string
  push calc_string_format
  call printf
  add esp, 8
  popad
  push %1
  call free_list
  add esp, 4
  %%end_of_push:
  pop ebx
%endmacro
; a macro that recieves one argument, pops a linked list from the operand stack and stores it in the argument, if the stack is empty the given argument is 0
%macro pop_operand_stack 1
  mov dword %1, 0
  cmp dword [stack_size], 0
  je %%poping_error
  dec dword [stack_size] 
  sub dword [stack_pointer], 4
  mov ecx, [stack_pointer]
  mov dword %1, [ecx]
  jmp %%end_of_pop
  %%poping_error:
  pushad
  push pop_error_string
  push calc_string_format
  call printf
  add esp, 8
  popad
  %%end_of_pop:
%endmacro

%macro validate_operand_stack 1
  cmp dword [stack_size], %1
  jl %%not_enoght_operands
  mov eax, 1
  jmp %%enough_opernads
  %%not_enoght_operands:
  pushad
  push pop_error_string
  push calc_string_format
  call printf
  add esp, 8
  popad
  mov eax, 0
  %%enough_opernads:
%endmacro

section .bss
  input_buffer: resb 80
section .rodata
  integer_string_format: db '%d', 10, 0
  calc_string_format: db '%s', 0
  calc_string: db "calc: ", 0
  debug_string: db "debug: ",10, 0
  hexa_string_format2: db "%X", 0
  hexa_string_format: db "%02X", 0
  new_line: db 10, 0
  push_error_string: db "Error: Operand Stack Overflow",10,0
  pop_error_string: db "Error: Insufficient Number of Arguments on Stack", 10, 0
section .data
  debug: db 0
  stack_pointer: dd 0
  stack_size: dd 0
  stack_max_size: dd 5
section .text
  align 16
  global main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern getchar 
  extern fgets
  extern stdin

main:                   ; signature: main(int argc, char* argv[]) ; desc: main function, calls the myCalc function and prints the number returned by it.
  push ebp
  mov ebp, esp
  sub esp, 4            ; allocate a byte as a local variable on stack that is the size of the allocated stack
  pushad
  mov dword [ebp - 4], 5      ; set default size of stack to 5
  mov ebx, [ebp + 8]    ; get argc. ebp <- argc
  cmp ebx, 1            ; check number of arguments
  je no_args
  mov edx, [ebp + 12]   ; set edx to point to the argv array. edx <- char* argv[]
  dec ebx               ; set ebx to be the last index of the argv array
  ; pushad
  ; push ebx
  ; push integer_string_format
  ; call printf
  ; add esp, 8
  ; popad
  for_args:
    cmp ebx, 0
    je end_for_args
    mov ecx, [edx + 4*ebx]      ; set ecx to be the current argument ecx<-argv[ebx]
    cmp word [ecx], '-d'  ; check if the argument is for debug
    jne is_stack_size
      mov byte [debug], 1   ; if the argument was -d than set the debug flag to 1
    jmp end_if_debug
    is_stack_size:
      mov al, [ecx]     ; ecx is the current argument which holds the stack size. al <- argv[ebx][0]
      cmp al, 58
      jng is_digit4
        sub al, 7       ; if char is letter
      is_digit4:
        sub al, 48
      mov [ebp-4], al   ; store the current stack size in its variable
      inc ecx
      mov al, [ecx]     ; al <- argv[ebx][1]
      cmp al, 0         ; check if there is another digit
      je end_if_debug   ; if not then finish
      cmp al, 58        ; if yes then cast it appropriatly
      jng is_digit5
        sub al, 7       ; if char is letter
      is_digit5:
        sub al, 48
      shl byte [ebp-4], 4
      add [ebp-4], al
    end_if_debug:
    dec ebx
    jmp for_args
  end_for_args:
  ; mov eax, 0
  ; mov al, [ebp-4]
  ; push eax
  ; push integer_string_format
  ; call printf
  ; add esp, 8
  no_args:
  push 4                ; push size of each cell
  push dword [ebp - 4]        ; push number of cells in stack
  call calloc           ; allocate memory for operand_stack on heap
  add esp, 8            ; clean stack
  mov [stack_pointer], eax          ; stack_pointer will be the operand_stack pointer
  mov eax, [ebp - 4]
  mov [stack_max_size], eax
  call myCalc           ; call myCalc
  push eax              ; push number of calculations as a second argument to printf
  push integer_string_format ; push the format string as first argument to printf
  call printf
  add esp, 8            ; clean stack
  ; free stack
  empty_stack_while_start:
  cmp dword [stack_size], 0
  je empty_stack_while_end
  pop_operand_stack eax
  push eax              ; push the poped opernad form the stack to free its memory
  call free_list        ; free the memory pointed by eax
  add esp, 4            ; free the memory
  jmp empty_stack_while_start
  empty_stack_while_end:
  push dword [stack_pointer]
  call free             ; free the memory of the operand_stack
  add esp, 4
  popad
  add esp, 4            ; pop the local variable              
  mov esp, ebp	
	pop ebp
  ret

; signature: strpairity(char* str) => int
; purpose: returns 1 if the string str has an odd length and 0 if even
strpairity:
  push ebp
  mov ebp, esp
  sub esp, 4            ; local variable to store return value
  pushad
  mov ebx, [ebp + 8]    ; get char *str
  mov ecx, 0            ; init counter
  strpairity_while_start:
    cmp byte [ebx], 0
    je strpairity_while_end
    cmp byte [ebx], 10
    je strpairity_while_end
    inc ecx
    inc ebx
    cmp byte [ebx], 0
    je strpairity_while_end
    cmp byte [ebx], 10
    je strpairity_while_end
    dec ecx
    inc ebx
    jmp strpairity_while_start
  strpairity_while_end:
  mov [ebp - 4], ecx
  popad
  mov eax, [ebp - 4]    ; set return value to pairiry
  add esp, 4
  mov esp, ebp
  pop ebp
  ret

; signature: myCalc() => int
; description: calculator main function, retruns the number of operations done.
myCalc:
  push ebp
  mov ebp, esp
  sub esp, 4            ; allocate a local variable to count the number of operations
  pushad
  mov dword [ebp - 4], 0      ; init the counter to 0
  while_start:
    push calc_string    ; push the "calc: " string as argument to print f
    push calc_string_format
    call printf
    add esp, 8          ; pop argument from stack
    push dword [stdin]  ; push stdin as first argument
    push dword 80       ; push 80 as the max size of string
    push input_buffer   ; push the input buffer pointer as the first argument
    call fgets
    add esp, 12         ; clean stack
    cmp byte [input_buffer], 'q'
    je while_end        ; quit

    cmp byte [input_buffer], '+'
    jne not_plus
    call unsignedAddition
    inc dword [ebp - 4]
    jmp while_start
    
    not_plus:
    cmp byte [input_buffer], 'p'
    jne not_p
    call popAndPrint
    inc dword [ebp - 4]
    jmp while_start
    
    not_p:
    cmp byte [input_buffer], 'd'
    jne not_dup
    call duplicate
    inc dword [ebp - 4]
    jmp while_start

    not_dup:
    cmp byte [input_buffer], '&'
    jne not_and
    call bitwiseAnd
    inc dword [ebp - 4]
    jmp while_start
    
    not_and:
    cmp byte [input_buffer], '|'
    jne not_or
    call bitwiseOr
    inc dword [ebp - 4]
    jmp while_start

    not_or:
    cmp byte [input_buffer], 'n'
    jne is_num
    call numOfHexDigits
    inc dword [ebp - 4]
    jmp while_start
    
    is_num:
    mov edx, input_buffer ; edx now points to the input buffer
    mov esi, 0            ; esi is the linked list pointer, currently equals to NULL
    push edx
    call strpairity
    add esp, 4
    cmp eax, 0            ; if the pairity is even
    je parse_to_dec
    mov eax, 0            ; if there is an odd number of digits we would like our msb to be in a single node and all the other digits to be in pairs
    mov al, [edx]
    cmp byte al, 58       ; checks if it is a number or letter
    jng is_digit          ; assuming the input is vaild, jump if the current byte is 0-9
    sub byte al, 7        ; if it is a letter
    is_digit:
    sub byte al, 48
    push esi
    push eax
    call append    ; create a link for the msb
    add esp, 8
    mov esi, eax
    inc edx
    parse_to_dec:
      mov eax, 0
      mov al, [edx]       ; al now contains the current character
      cmp byte al, 0      ; checks for EOF
      je parse_to_dec_end
      cmp byte al, 10     ; checks for \n
      je parse_to_dec_end
      cmp byte al, 58     ; checks if it is a number or letter
      jng is_digit2       ; assuming the input is vaild, jump if the current byte is 0-9
      sub byte al, 7      ; if it is a letter
      is_digit2:
      sub byte al, 48

      inc edx
      mov ebx, 0
      mov bl, [edx]
      cmp byte bl, 58 
      jng is_digit3
      sub byte bl, 7
      is_digit3:
      sub byte bl, 48

      shl al, 4         ; multiply al by 16
      add al, bl

      push esi
      push eax
      call append    ; create a link for al and append
      add esp, 8
      mov esi, eax

      inc edx
      jmp parse_to_dec

    parse_to_dec_end:
    ; push esi        ; debug message
    ; call print_list
    ; add esp, 4
    push_operand_stack esi
    jmp while_start
  while_end:
  popad
  mov eax, [ebp - 4]  ; return the number of operations made
  add esp, 4          ; free local variable
  mov esp, ebp	
	pop ebp
  ret

; every link has a memory location, its pointer. when we push a linked list to the operand stack
; we push the pointer to the first link of the linked list.
; every link is composed of 5 bytes, the first byte is 2 two hexadecimal digits. the next 4 is a pointer to the next link.

; signature: append(char new, link* list) => link*
; purpose: append is a function that recieves 2 arguments, a byte sized argument that will be wrapped inside a link, and
; a linked list to which the new link will be appended at the start. it returns a linked_list with the the new link as it's head
append: 
  push ebp
  mov ebp, esp
  sub esp, 4
  pushad
  push 5
  call malloc           ; allocate memory for new link
  add esp, 4
  mov ebx, [ebp + 8]
  mov byte [eax], bl    ; set the first byte to the given argument
  mov ebx, [ebp + 12]
  mov dword [eax + 1], ebx
  mov [ebp - 4], eax
  popad
  mov eax, [ebp - 4]
  add esp, 4
  mov esp, ebp
  pop ebp
  ret

print_list: ; signature: print_list(link* list) => void. description: prints an hexadecimal number from a linked list
  push ebp
  mov ebp, esp
  pushad
  push dword [ebp + 8]
  call print_list_recursive
  add esp, 4
  push new_line
  push calc_string_format
  call printf
  add esp, 8
  popad
  mov esp, ebp
  pop ebp
  ret

print_list_recursive: ; signature: print_list(link* list) => void. description: prints an hexadecimal number from a linked list
  push ebp
  mov ebp, esp
  pushad
  mov ebx, [ebp + 8]    ; get the argument which is a pointer to the head of a list
  cmp dword [ebx + 1], 0            ; check if next is null
  jne next_not_null
  mov edx, 0
  mov dl, [ebx]
  push edx
  push hexa_string_format2
  call printf
  add esp, 8
  jmp end_func
  next_not_null:
  push dword [ebx + 1]  ; push link->next
  call print_list_recursive
  add esp, 4            ; clean stack
  mov edx, 0
  mov dl, [ebx]
  push edx
  push hexa_string_format
  call printf
  add esp, 8
  end_func:
  popad
  mov esp, ebp
  pop ebp
  ret



unsignedAddition:       ; signature: unsignedAddition() => void ; description: adds two numbers represented with a linked list
  push ebp              ; stores the result in the first argument and returns it.
  mov ebp, esp
  sub esp, 16           ; allocate 4 local variables, two for saving the pointer to the beggining of the operands, the other two
  ; for saving the previous link for both the operands
  pushad
  validate_operand_stack 2
  cmp eax, 0
  je end_unsigned_addition
  pop_operand_stack esi ; esi = stack.pop(), pop operands. 
  mov [ebp - 4], esi    ; temp = esi save a pointer to the beggining of the first linked list
  pop_operand_stack edi ; edi = stack.pop()
  mov [ebp - 16], edi
  clc                   ; CF = 0. clear the carry flag
  pushfd                ; save the flags so other commands won't change them
  addition_while_start:
    cmp esi, 0          ; if (esi == null)
    je addition_while_end
    cmp edi, 0          ; if (edi == null)
    je addition_while_end
    mov al, [edi]       ; al = edi->value
    popfd
    adc [esi], al       ; esi->value += al + carry_flag
    pushfd
    mov [ebp - 8], esi
    mov [ebp - 12], edi
    mov esi, [esi + 1]  ; esi = esi->next 
    mov edi, [edi + 1]  ; edi = edi->next
    jmp addition_while_start
  addition_while_end:
  cmp edi, 0
  je first_op_while_start
  ; the case whree len(edi) > len(esi) if we got here it means the loop ended because esi is 0 and edi isn't  
  mov esi, [ebp - 8]    ; esi = esi->prev
  mov [esi + 1], edi    ; esi(->prev)->next = edi. set esi to point. set esi to point to the rest of the edi list
  mov edi, [ebp - 12]   ; edi = edi->prev
  mov dword [edi + 1], 0      ; edi->next = NULL. detach the rest of edi from the start of it
  mov [ebp - 8], esi    ; set the esi->prev local variable
  mov esi, [esi + 1]    ; esi = esi->next. returning esi to point to the real next node
  first_op_while_start:
    cmp esi, 0
    je first_op_while_end
    popfd
    adc byte [esi], 0
    pushfd 
    mov [ebp - 8], esi  
    mov esi, [esi + 1]
    jmp first_op_while_start
  first_op_while_end:
  popfd
  jnc no_carry
  push dword 0          ; push NULL as first argument to append
  push dword 1          ; since there is a carry, push 1 to be the new MSB link
  call append           ; create a link for 1
  add esp, 8            ; clean stack
  mov esi, [ebp - 8]    ; set esi to the last non-null node
  mov [esi + 1], eax    ; set its next node to be the new created node of 1
  no_carry: 
  ; push dword [ebp - 4] ; debug message
  ; call print_list
  ; add esp, 4
  mov eax, [ebp - 4]
  push_operand_stack eax  ; this pushing must succeed since we poped 2 operands earlier
  push dword [ebp - 16]   ; free the second operand list
  call free_list
  add esp, 4
  end_unsigned_addition:
  popad
  add esp, 16
  mov esp, ebp	
	pop ebp
  ret
  
popAndPrint:            ; signature: popAndPrint() => void
  push ebp
  mov ebp, esp
  sub esp, 4
  pushad
  validate_operand_stack 1
  cmp eax, 0
  je end_pop_and_print
  pop_operand_stack esi
  mov [ebp - 4], esi
  mov edx, esi
  push edx
  call print_list
  add esp, 4
  mov eax, [ebp - 4]
  push eax
  call free_list
  add esp, 4
  end_pop_and_print:
  popad
  add esp, 4
  mov esp, ebp	
	pop ebp
  ret
  
  
duplicate:              ; signature: duplicate() => void
  push ebp
  mov ebp, esp
  sub esp, 4
  pushad
  validate_operand_stack 1
  cmp eax, 0
  je end_duplicate
  pop_operand_stack esi ; esi = stack.pop(), pop operands. 
  mov [ebp - 4], esi          ; temp = esi save a pointer to the beggining of the first linked list
  mov edi, 0
  dup_while_start:
    cmp esi, 0 ;if there are no more links
    je dup_while_end
    mov eax, 0
    mov al, [esi] ;al = esi->value
    push edi
    push eax
    call append
    add esp, 8
    mov edi, eax
    mov esi, [esi + 1]
    jmp dup_while_start
  dup_while_end:
  mov edx, [ebp - 4]
  ; push edx    ; debug message
  ; call print_list
  ; add esp, 4
  push_operand_stack edx  ; push the list we popped at the beginig 
  push_operand_stack edi  ; push the duplicate list. this push might not succeed, handled by the macro.
  end_duplicate:
  popad
  add esp, 4
  mov esp, ebp	
	pop ebp
  ret
  
  
  
  bitwiseAnd:
    push ebp
    mov ebp, esp
    sub esp, 8
    pushad
    validate_operand_stack 2
    cmp eax, 0
    je and_end_func
    pop_operand_stack esi ; esi = stack.pop(), pop operands. 
    mov [ebp - 4], esi    ; temp = esi save a pointer to the beggining of the first linked list
    pop_operand_stack edi    ; edi = stack.pop()
    mov [ebp - 8], edi
    and_while_start:
      cmp dword [esi + 1], 0  ; if esi->next == null
      je and_whlie_end
      cmp dword [edi + 1], 0  ; if edi->next == null
      je and_whlie_end
      mov al, [edi]   
      and [esi], al   ; esi & edi
      mov esi, [esi + 1]  ; esi = esi->next 
      mov edi, [edi + 1]  ; edi = edi->next
      jmp and_while_start
    and_whlie_end:
      cmp dword [edi + 1], 0  ; if |edi|<=|esi|
      je long_esi
      jmp long_esi_end
    long_esi:
      cmp dword [esi + 1], 0  ; if |esi| == |edi|
      je long_esi_end
      mov al, [edi]
      and [esi], al ;esi & edi
      mov edx, [esi + 1]
      mov dword [esi + 1], 0
      push edx
      call free_list
      add esp, 4
    long_esi_end:
      mov al, [edi]
      and [esi], al ; esi & edi
      mov eax, [ebp - 4]
      ; push eax      ; debug message
      ; call print_list
      ; add esp, 4  
      push_operand_stack eax ;   push esi, ; this pushing must succeed since we poped 2 operands earlier
      mov eax, [ebp - 8]
      push eax
      call free_list
      add esp, 4
    and_end_func:
    popad
    add esp, 8
    mov esp, ebp	
    pop ebp
    ret
  
  
bitwiseOr:              ; signature: bitwiseOr() => void
  push ebp
  mov ebp, esp
  sub esp, 8
  pushad
  validate_operand_stack 2
  cmp eax, 0
  je end_bitwiseor
  pop_operand_stack esi ; esi = stack.pop(), pop operands. 
  mov [ebp - 4], esi    ; temp = esi save a pointer to the beggining of the first linked list
  pop_operand_stack edi    ; edi = stack.pop()
  mov [ebp - 8], edi    ; temp = esi save a pointer to the beggining of the first linked list
  or_while_start:
    cmp dword [esi + 1], 0  ; if esi->next == null
    je or_whlie_end
    cmp dword [edi + 1], 0  ; if edi->next == null
    je or_whlie_end
    mov al, [edi]   
    or [esi], al   ; esi | edi
    mov esi, [esi + 1]  ; esi = esi->next 
    mov edi, [edi + 1]  ; edi = edi->next
    jmp or_while_start
  or_whlie_end:
    cmp dword [esi + 1], 0  ; if |edi|>=|esi|
    je long_edi
    jmp long_edi_end
  long_edi:
    cmp dword [edi + 1], 0 ; if |esi| == |edi|
    je long_edi_end
    mov al, [edi]   
    or [esi], al   ; esi | edi
    mov eax, [edi + 1]
    mov [esi + 1], eax ;esi->next = edi->next
    mov dword [edi + 1], 0
    jmp or_end_func
  long_edi_end:
    mov al, [edi]   
    or [esi], al   ; esi | edi
  or_end_func:
  mov eax, [ebp - 4]
  ; push eax    ; debug message
  ; call print_list
  ; add esp, 4  
  push_operand_stack eax ;   push esi, ; this pushing must succeed since we poped 2 operands earlier
  mov eax, [ebp - 8]
  push eax
  call free_list
  add esp, 4
  end_bitwiseor: 
  popad
  add esp, 8
  mov esp, ebp	
	pop ebp
  ret
  
numOfHexDigits:         ; signature: numOfHexDigits() => void
  push ebp
  mov ebp, esp
  sub esp, 4 ; declare a local variable
  pushad
  validate_operand_stack 1
  cmp eax, 0
  je end_numofhex
  pop_operand_stack esi
  mov [ebp - 4], esi
  mov edx, 0 ; edx is the counter
  count_while_start:
  cmp dword [esi + 1], 0 ; if esi->next == null
  je count_while_end
  add edx, 2 ;edx += 2
  mov esi, [esi + 1] ; esi = esi->next
  jmp count_while_start
  count_while_end:
  cmp byte [esi], 16 ;if esi < 16
  jl one_letter
  add edx, 1 ;add total of two
  one_letter:
  add edx, 1 ; else add total of one
  push 0
  push edx
  call append
  add esp, 8
  push_operand_stack eax
  mov eax, [ebp - 4]
  push eax
  call free_list
  add esp, 4
  end_numofhex:
  popad
  mov esp, ebp	
	pop ebp
  ret

; signature: free_list(link* list) => void 
; purpose: frees the memory of a linked list
free_list:
  push ebp
  mov ebp, esp
  pushad
  mov esi, [ebp + 8]    ; get the list argument
  cmp esi, 0            ; base case of NULL list
  je end_free_list_func
  push dword [esi + 1]  ; push the next link as argument
  call free_list        ; recursivly call this function to free the next node
  add esp, 4            ; clean stack
  push esi              ; push current list pointer ad argument to free function
  call free             ; free the allocated memory for the current node
  add esp, 4            ; clean stack
  end_free_list_func:
  popad
  mov esp, ebp
  pop ebp
  ret
  
