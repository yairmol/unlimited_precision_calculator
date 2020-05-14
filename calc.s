section .bss
  input_buffer: resb 80
section .rodata
  integer_string_format: db '%d', 10, 0
  calc_string_format: db '%s', 0
  calc_string: db "calc: ", 0
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
  ;sub esp, 1            ; allocate a byte as a local variable on stack that is the size of the allocated stack
  pushad
  ;mov byte [ebp - 1], 5      ; set default size of stack to 5
  mov ebx, [ebp + 8]    ; get argc. ebp <- argc
  cmp ebx, 1            ; check number of arguments
  je no_args
  ; mov edx, [ebp + 12]   ; set edx to point to the argv array
  ; dec ebx               ; set ebx to be the last index of the argv array
  ; for_args:
  ;   cmp ebx, 1
  ;   je end_for_args
  ;   mov ecx, [edx + ebx]      ; set edx to be the current argument
  ;   cmp word [ecx], '-d'  ; check if the argument is for debug
  ;   jne is_stack_size
  ;     mov byte [debug], 1   ; if the argument was -d than set the debug flag to 1
  ;   jmp end_if_debug
  ;   is_stack_size:
  ;     mov al, [ecx]     ; ecx is the current argument which holds the stack size. al <- argv[ebx][0]
  ;     sub
  ;   end_if_debug:
  ;   dec ebx
  ;   jmp for_args
  ; end_for_args:
  no_args:
  call myCalc           ; call myCalc
  push eax              ; push number of calculations as a second argument to printf
  push integer_string_format ; push the format string as first argument to printf
  call printf
  add esp, 8            ; clean stack
  popad
  ;add esp, 1            ; pop the local variable              
  mov esp, ebp	
	pop ebp
  ret
    

myCalc:                 ; singature: myCalc() => int. description: calculator main function, retruns the number of operations done.
  push ebp
  mov ebp, esp
  pushad
  while_start:
    push calc_string   ; push the "calc: " string as argument to print f
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
    
    not_plus:
    cmp byte [input_buffer], 'p'
    jne not_p
    call popAndPrint
    
    not_p:
    cmp byte [input_buffer], 'd'
    jne not_dup
    call duplicate

    not_dup:
    cmp byte [input_buffer], '&'
    jne not_and
    call bitwiseAnd
    
    not_and:
    cmp byte [input_buffer], '|'
    jne not_or
    call bitwiseOr

    not_or:
    cmp byte [input_buffer], 'n'
    jne is_num
    call numOfHexDigits
    
    is_num:
    mov edx, 0
    mov edx, input_buffer ; edx now points to the input buffer

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
      je EOF
      cmp byte bl, 10
      je EOF
      cmp byte bl, 58 
      jng is_digit2
      sub byte bl, 7
      is_digit2:
      sub byte bl, 48

      shl al, 4         ; multiply al by 16
      add al, bl
      ;TODO: enter eax to a node
      push edx
      push eax
      push integer_string_format
      call printf
      add esp, 8
      pop edx

      inc edx
      jmp parse_to_dec
    EOF:
      ;TODO: enter eax to a node
      push eax
      push integer_string_format
      call printf
      add esp, 8
      
    parse_to_dec_end:
    jmp while_start
  while_end:
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

  
