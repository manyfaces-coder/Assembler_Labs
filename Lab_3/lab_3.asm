.386 
.model flat,stdcall 
option casemap:none 

include /masm32/include/kernel32.inc 
include /masm32/include/user32.inc 
includelib /masm32/lib/kernel32.lib 
includelib /masm32/lib/user32.lib 
include /masm32/include/msvcrt.inc 
includelib /masm32/lib/msvcrt.lib 

BSIZE equ 10 


.data 
  formatInt db "%d", 0 ; формат для целых чисел 
  formatSymb db "%c", 0 ;формат для символов 

  rez db 0 
  mn_two dd 2d 

  first_out db "Enter the number: " 
  res_out db "Result: ", 0 

  x dd 0 

.data? 
  stdin dd ? 
  stdout dd ? 
  buf db 0A0h dup (?) ; Буфер для считывания конструкций из буфера ввода 
  counter dw ? 
  cRead dd ? 

.code 

start: 
  invoke GetStdHandle, -10 ; указатель на чтение из консоли 
  mov stdin,eax ; указатель сохраняем в переменную 

  invoke GetStdHandle, -11 ; указатель на вывод в консоль 
  mov stdout,eax ; указатель вывода сохраняем в переменную 
  invoke WriteConsole, stdout, ADDR first_out, 18, 0, 0 

  read_1: 

    cmp counter, 8 
    je calculation 

    invoke ReadConsoleInput, stdin, ADDR buf, BSIZE, ADDR cRead ; читаем все из консоли в буфер buffer_key_1 

    cmp [buf+14d], 0dh ; проверяется нажатие клавиши Enter 
    je calculation ; если ENTER нажата, то выходим из цикла ввода 

    cmp [buf+14d], 0 ; если ничего не введено, то идем опять на опрос консоли 
    je read_1 
  
    cmp [buf+14d], 48 ; Если ввеженый код меньше кода цифры то на начало ввода 

    jl read_1 ; проверка если введеный код меньше кода цифры 

    cmp [buf+14d], 50 ; Если введеный код юольше кода цифр, то опять на ввод 
    jnc read_1 ; проверка переноса - его не будет если код больше кода цифры 

    cmp [buf+04d], 1h ; Если нажата клавиша - именно нажата!!! 
    jne read_1 ; условие - если не равно 1, то клавиша не нажата (может мышка, а может событи какое-то) - идти на опрос консоли 
    
    invoke WriteConsole, stdout, ADDR [buf+14d], 1, 0, 0 ; вывести символ нажатой клавиши (будут только цифры) 


    mov eax, x ; считываем формируемое число 
    mul mn_two; если введена еще одна цифра, то значить увеличиваем порядок на 10 
    mov x, eax ; сохраняем формируемое число 

    xor eax, eax ; обнуляем регистр eax 
    mov al, [buf+14d] ; в самый младший байт регистра eax записываем код введеной цифры 
    sub al, 30h ; преобразуем из кода в цифру 
    add x, eax ; прибавляем к формируемому числу 

    inc counter 

    jmp read_1 


  calculation: 

    invoke crt_printf, offset formatSymb, 10 
    mov counter, 0 
    mov eax, x 
    mov rez, al 
    invoke crt_printf, offset formatInt, rez 
    invoke crt_printf, offset formatSymb, 10 
    and rez, 28 
    not rez 
    shl rez, 2 
    xor rez,00111000b 
    invoke crt_printf, offset formatSymb, 10 
    invoke crt_printf, offset formatInt, rez 
    invoke crt_printf, offset formatSymb, 10 
    invoke WriteConsole, stdout, ADDR res_out, 8, 0, 0 
    jmp proxod 


  proxod: 
    sal rez, 1 
    jc vivod_one 
    jmp vivod_zero 

  vivod_one: 
    invoke crt_printf, offset formatInt, 1 
    inc counter 
    cmp counter, 8 
    je exit 
    jmp proxod 

    vivod_zero: 
    invoke crt_printf, offset formatInt, 0 
    inc counter 
    cmp counter, 8 
    je exit 
    jmp proxod 
  exit: 
    end start
