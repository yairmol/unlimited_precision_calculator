; a macro that recives one argument and pushed it to the operand stack
%macro push_operand_stack 1
  mov dword [ecx], %1
  add ecx, 4
%endmacro
; a macro that recieves one argument, pops a linked list from the operand stack and stores it in the argument
%macro pop_operand_stack 1
  sub ecx, 4
  mov dword %1, [ecx]
%endmacro

section .bss
  input_buffer: resb 80
section .rodata
  integer_string_format: db '%d', 10, 0
  calc_string_format: db '%s', 0
  calc_string: db "calc: ", 0
  debug_string: db "debug: ", 0
  hexa_string_fornat: db "%X", 0
section .data
  debug: db 0
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
  pushad
  push ebx
  push integer_string_format
  call printf
  add esp, 8
  popad
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
      jng is_digit3
        sub al, 7       ; if char is letter
      is_digit3:
        sub al, 48
      mov [ebp-4], al   ; store the current stack size in its variable
      inc ecx
      mov al, [ecx]     ; al <- argv[ebx][1]
      cmp al, 0         ; check if there is another digit
      je end_if_debug   ; if not then finish
      cmp al, 58        ; if yes then cast it appropriatly
      jng is_digit4
        sub al, 7       ; if char is letter
      is_digit4:
        sub al, 48
      shl byte [ebp-4], 4
      add [ebp-4], al
    end_if_debug:
    dec ebx
    jmp for_args
  end_for_args:
  mov eax, 0
  mov al, [ebp-1]
  push eax
  push integer_string_format
  call printf
  add esp, 8
  no_args:
  push 4                ; push size of each cell
  push dword [ebp - 4]        ; push number of cells in stack
  call calloc           ; allocate memory for operand_stack on heap
  add esp, 8            ; clean stack
  mov ecx, eax          ; ecx will be the operand_stack pointer
  call myCalc           ; call myCalc
  push eax              ; push number of calculations as a second argument to printf
  push integer_string_format ; push the format string as first argument to printf
  call printf
  add esp, 8            ; clean stack
  popad
  add esp, 1            ; pop the local variable              
  mov esp, ebp	
	pop ebp
  ret
    

myCalc:                 ; singature: myCalc() => int. description: calculator main function, retruns the number of operations done.
  push ebp
  mov ebp, esp
  pushad
  while_start:
    push ecx            ; save operand_stack pointer ecx
    push calc_string    ; push the "calc: " string as argument to print f
    push calc_string_format
    call printf
    add esp, 8          ; pop argument from stack
    pop ecx             ; restore ecx
    push ecx            ; save ecx
    push dword [stdin]  ; push stdin as first argument
    push dword 80       ; push 80 as the max size of string
    push input_buffer   ; push the input buffer pointer as the first argument
    call fgets
    add esp, 12         ; clean stack
    pop ecx             ; restore
    cmp byte [input_buffer], 'q'
    je while_end        ; quit

    cmp byte [input_buffer], '+'
    jne not_plus
    call unsignedAddition
    jmp while_start
    
    not_plus:
    cmp byte [input_buffer], 'p'
    jne not_p
    call popAndPrint
    jmp while_start
    
    not_p:
    cmp byte [input_buffer], 'd'
    jne not_dup
    call duplicate
    jmp while_start

    not_dup:
    cmp byte [input_buffer], '&'
    jne not_and
    call bitwiseAnd
    
    not_and:
    cmp byte [input_buffer], '|'
    jne not_or
    call bitwiseOr
    jmp while_start

    not_or:
    cmp byte [input_buffer], 'n'
    jne is_num
    call numOfHexDigits
    jmp while_start
    
    is_num:
    mov edx, 0
    mov edx, input_buffer ; edx now points to the input buffer
    mov esi, 0            ; esi is the linked list pointer, currently equals to NULL
    parse_to_dec:
      mov eax, 0
      mov al, [edx]       ; al now contains the current character
      cmp byte al, 0      ; checks for EOF
      je parse_to_dec_end
      cmp byte al, 10     ; checks for \n
      je parse_to_dec_end
      cmp byte al, 58     ; checks if it is a number or letter
      jng is_digit        ; assuming the input is vaild, jump if the current byte is 0-9
      sub byte al, 7      ; if it is a letter
      is_digit:
      sub byte al, 48

      inc edx
      mov ebx, 0
      mov bl, [edx]
      cmp byte bl, 0
      je one_digit
      cmp byte bl, 10
      je one_digit
      cmp byte bl, 58 
      jng is_digit2
      sub byte bl, 7
      is_digit2:
      sub byte bl, 48

      shl al, 4         ; multiply al by 16
      add al, bl

      ; push edx
      ; push eax
      ; push integer_string_format
      ; call printf
      ; add esp, 8
      ; pop edx

      push esi
      push eax
      call append    ; create a link for al and append
      add esp, 8
      mov esi, eax

      inc edx
      jmp parse_to_dec
    one_digit:
      ; push eax
      ; push integer_string_format
      ; call printf
      ; add esp, 8

      push esi
      push eax
      call append    ; create a link for al and append
      add esp, 8
      mov esi, eax
      
    parse_to_dec_end:
    push_operand_stack esi
    push esi
    call print_list
    add esp, 4
    jmp while_start
  while_end:
  popad
  mov esp, ebp	
	pop ebp
  ret

; every link has a memory location, its pointer. when we push a linked list to the operand stack
; we push the pointer to the first link of the linked list.
; every link is composed of 5 bytes, the first byte is 2 two hexadecimal digits. the next 4 is a pointer to the next link.
; append is a function that recieves 2 arguments, a byte sized argument that will be wrapped inside a link, and
; a linked list to which the new link will be appended at the start. it returns a linked_list with the the new link as it's head
append: ; signature: append(char new, link* list) => link*
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

print_list:
  push ebp
  mov ebp, esp
  pushad
  mov ebx, [ebp + 8]    ; get the argument which is a pointer to the head of a list
  cmp ebx, 0            ; check if null
  je end_func
  push dword [ebx + 1]  ; push link->next
  call print_list
  add esp, 4            ; clean stack
  mov edx, 0
  mov dl, [ebx]
  pushad                ; save registers
  push edx
  push hexa_string_fornat
  call printf
  add esp, 8
  popad
  end_func:
  popad
  mov esp, ebp
  pop ebp
  ret



unsignedAddition:       ; signature: unsignedAddition(list, list) => list ; description: adds two numbers represented with a linked list
  push ebp              ; stores the result in the first argument and returns it.
  mov ebp, esp
  pushad
  
  
  popad
  mov esp, ebp	
	pop ebp
  ret
  
popAndPrint:            ; signature: popAndPrint() => void
  push ebp
  mov ebp, esp
  pushad

  
  popad
  mov esp, ebp	
	pop ebp
  ret
  
  
duplicate:              ; signature: duplicate() => void
  push ebp
  mov ebp, esp
  pushad
  

  popad
  mov esp, ebp	
	pop ebp
  ret
  
  
bitwiseAnd:             ; signature: bitwiseAnd() => void
  push ebp
  mov ebp, esp
  pushad


  popad
  mov esp, ebp	
	pop ebp
  ret
  
  
bitwiseOr:              ; signature: bitwiseOr() => void
  push ebp
  mov ebp, esp
  pushad


  popad
  mov esp, ebp	
	pop ebp
  ret

  
numOfHexDigits:         ; signature: numOfHexDigits() => void
  push ebp
  mov ebp, esp
  pushad


  popad
  mov esp, ebp	
	pop ebp
  ret


unsignedMultiplication: ; signature: unsignedMultiplication() => void
  push ebp
  mov ebp, esp
  pushad


  popad
  mov esp, ebp	
	pop ebp
  ret

  
