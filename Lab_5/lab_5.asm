.386
.model flat, stdcall
option casemap :none

include /masm32/include/kernel32.inc
include /masm32/include/user32.inc
includelib /masm32/lib/kernel32.lib
includelib /masm32/lib/user32.lib
include /masm32/include/windows.inc

BSIZE equ 4

.data
	mn_dec dd 10d

	zero_err db "Division by zero!"

	in_a db "Enter a: "
	a dd ?

	in_b db "Enter b: "
	b dd ?

	in_c db "Enter c: "
	@c dd ?

	in_d db "Enter d: "
	d dd ?

	in_e db "Enter e: "
	e dd ?

	in_f db "Enter f: "
	f dd ?

	in_g db "Enter g: "
	g dd ?

	in_h db "Enter h: "
	h dd ?

	in_k db "Enter k: "
	k dd ?

	in_m db "Enter m: "
	
	x dd 0
	perenos db 0ah, 0dh, 0
	
	m dd ?

	stdout dd ?

	stdin dd ?

	cRead dd ?

	rez db "(a/b+cde)/(f/g+hk)+m = "
	counter dw ?
	buf db ?
	buffer_key_2 db ?
	buf_1 db ?
	;cRead dd ? ?????
.code

start:

invoke GetStdHandle, -10

mov stdin, eax

invoke GetStdHandle, -11

mov stdout, eax

lea esi, [in_a]

call display

mov a, eax

lea esi, [in_b]

call display

call EROR_ZERO

mov b, eax

lea esi, [in_c]

call display

mov @c, eax

lea esi, [in_d]

call display

mov d, eax

lea esi, [in_e]

call display

mov e, eax

lea esi, [in_f]

call display


mov f, eax

lea esi, [in_g]

call display

call EROR_ZERO

mov g, eax

lea esi, [in_h]

call display

mov h, eax

lea esi, [in_k]

call display

mov k, eax

lea esi, [in_m]

call display

mov m, eax

invoke WriteConsole, stdout, offset rez, 23, 0, 0
;РАСЧЕТ

mov eax, a

mov ebx, b

div ebx; a/b

mov a, eax

mov eax, @c

mov ebx, d

mul ebx; cd

mov ebx, e

mul ebx; cde

mov @c, eax

mov eax, a

add eax, @c; (a/b+cde)

mov a, eax

mov eax, f

mov ebx, g

div ebx; f/g

mov f, eax

mov eax, h

mov ebx, k

mul ebx; hk

mov h, eax

mov eax, f

add eax, h; f/g+hk

mov f, eax

mov eax, a

mov ebx, f

div ebx; (a/b+cde)/(f/g+hk)

mov a, eax

mov eax, a

add eax, m

call RESULT


display proc

	lea edi, [buf_1]

	mov ecx, 9d

	rep movsb

	invoke WriteConsole, stdout, offset [buf_1], 9d, 0, 0
	
	mov counter, 0
	read:
		cmp counter, 4
		je next

		invoke ReadConsoleInput, stdin, ADDR [buf], BSIZE, offset cRead ; читаем все из консоли в буфер buffer_key_1
		cmp [buf+10d], 0dh ; проверяется нажатие клавиши Enter
		je next ; если ENTER нажата, то выходим из цикла ввода

		cmp [buf+14d], 0 ; если ничего не введено, то идем опять на опрос консоли
		je read

		cmp [buf+14d], 48 ; Если введеный код меньше кода цифры то на начало ввода
		jl read ; проверка если введеный код меньше кода цифры

		cmp [buf+14d], 58 ; Если введеный код больше кода цифр, то опять на ввод
		jnc read ; проверка переноса - его не будет если код больше кода цифры

		cmp [buf+04d], 1h ; Если нажата клавиша - именно нажата!!!
		jne read ; условие - если не равно 1, то клавиша не нажата (может мышка, а может событие какое-то) - идти на опрос консоли

		invoke WriteConsole, stdout, offset [buf+14d], 1, 0, 0 ; вывести символ нажатой клавиши (будут только цифры)

		mov eax, x ; считываем формируемое число

		mul mn_dec; если введена еще одна цифра, то значить увеличиваем порядок на 10

		mov x, eax ; сохраняем формируемое число

		xor eax, eax ; обнуляем регистр eax

		mov al, [buf+14d] ; в самый младший байт регистра eax записываем код введеной цифры

		sub al, 30h ; преобразуем из кода в цифру

		add x, eax ; прибавляем к формируемому числу
		
		inc counter
		
		jmp read

	next:
		
		cmp counter, 2
		jb ex
		
		mov [buf+10d], 00h

		invoke ReadConsoleInput, stdin, offset [buf], BSIZE, offset cRead ; чистка буфера клавиатуры (читаем от туда все что есть)

		invoke WriteConsole, stdout, offset [perenos], 2d, 0, 0 ; перейти на новую строку

		mov eax, x

		mov x, 0

		ret

display endp

EROR_ZERO proc

cmp eax, 0

je @exit

ret

@exit:

invoke WriteConsole, stdout, offset [zero_err], 17d, 0, 0

EROR_ZERO endp

RESULT PROC

	xor ecx, ecx ; подготовка счетчика - обнуление

	xor edx, edx ; будет использоввн для приведения значения к размерности чисел

@3:

	mov ebx, mn_dec

	div ebx ; деление числа на 10, чтобы представить его в десятичной системе счиления

	; будет браться остаток от деления и к нему прибавляться 30h, чтобы найти ASCII- код числа для вывода на экран

	; при делении первый остаток от деления дает нам правую цифру, которая должна быть выведена поседней

	add edx, 30h ; добавление 30h для нахождения кода числа (преобразвание в букву)

	push edx ; временное сохранение в стеке всех чисел - чтобы их перевернуть - сделать парвильный порядок символов

	xor edx, edx; обнуление edx, так как будет использовать у него только dl для записи только одной цифры

	inc ecx ; увеличение счетчика - сколько цифр- столько раз будет увеличен счетчик

	cmp eax, 0 ; если делимое равно нулю (все остатки от деления найдены) то значить все цифры обработыны

	jne @3 ; переход на обработку следующей цифры, если в регистре еще есть значение

	; если не равно, то переход

	mov edi, 0 ; обнуление edi, который будет использоваться как счетчик для доступа к ячейкам

	; памяти куда будут записаны символы выводимых цифр для числа

@4:

	pop edx ; чтение ASCII-кода цифры из стека (читается сначала старший разряд, так как он был помещен последним в стек)

	mov [buffer_key_2 + edi], dl ; по адресу буфера вывода сохраняем только один байт, соотвутствующий цифре

	inc edi ; переходим к следующему байту

	dec ecx ; уменьшаем счетчик-количество цифр в числе (был получен в предыдушщем цикле)

	jnz @4 ; пока не обработаны все цифры чистаем из стека следующую цифру и ложем в буфер

	; пока не ноль - пока ecx больше нуля

	invoke WriteConsole, stdout, offset [buffer_key_2], 8d, 0, 0
	
RESULT ENDP


ex:
end start
