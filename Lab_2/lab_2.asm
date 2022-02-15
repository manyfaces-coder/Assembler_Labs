.386
.model flat,stdcall
option casemap:none

include /masm32/include/kernel32.inc
include /masm32/include/user32.inc
includelib /masm32/lib/kernel32.lib
includelib /masm32/lib/user32.lib
include /masm32/include/msvcrt.inc
includelib /masm32/lib/msvcrt.lib

.data
  variable_val dd 15
  output_x db 'x = ', 0
  output_y_1 db 'y1 = ', 0
  output_y_2 db 'y2 = ', 0
  output_res db 'Y = ', 0
  output_res_hex db 'Hex_Y = ', 0
  formatInt db "%d", 0 ; формат для целых чисел
  formatStr db "%s", 0 ; формат для строк
  formatSymb db "%c", 0 ;формат для символов
  formatHex db '%x', 0 ;формат для вывода 16-тиричного результата 
  out_text db 'Enter the value a:', 0
  tri dd 3

.data?
  enter_value dd ?
  result dd ?
  first_y dd ?
  second_y dd ?
  ost dd ?
  
.code
  start:
    invoke crt_printf,offset formatStr, ADDR out_text
    invoke crt_scanf,offset formatInt, offset enter_value

    CYCL:
      mov eax, variable_val
      cmp eax, 0
      jl val_less_zero
      sub eax, enter_value
      mov first_y, eax
      jmp calculate_second_y
      
      val_less_zero:

        module:
          neg eax
          js module
          mov first_y, eax

      calculate_second_y:
        
        mov eax, variable_val
        xor edx, edx
        div tri
        mov ost, edx
        cmp ost, 1
        je mod_eq_1
        mov second_y, 7
        jmp calc_res
      
        mod_eq_1:
          mov eax, variable_val
          add eax, enter_value
          mov second_y, eax

      calc_res:
        mov eax, first_y
        sub eax, second_y
        mov result, eax

  invoke crt_printf,offset formatStr, ADDR output_x
  invoke crt_printf,offset formatInt, variable_val
  invoke crt_printf, offset formatSymb, 10

  invoke crt_printf,ADDR formatStr, ADDR output_y_1
  invoke crt_printf,ADDR formatInt, first_y
  invoke crt_printf, offset formatSymb, 10

  invoke crt_printf,ADDR formatStr, ADDR output_y_2
  invoke crt_printf,ADDR formatInt, second_y
  invoke crt_printf, offset formatSymb, 10

  invoke crt_printf,ADDR formatStr, ADDR output_res
  invoke crt_printf,ADDR formatInt, result
  invoke crt_printf, offset formatSymb, 10

  invoke crt_printf,ADDR formatStr, ADDR output_res_hex
  invoke crt_printf,ADDR formatHex, result
  invoke crt_printf, offset formatSymb, 10
  invoke crt_printf, offset formatSymb, 10


  dec variable_val
  cmp variable_val,0
  je exit
  jmp CYCL
  exit:
    invoke ExitProcess, 0

  end start
