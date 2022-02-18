.386
.model flat, stdcall
option casemap :none

include includes\kernel32.inc
include includes\user32.inc
include \masm32\include\windows.inc
includelib includes\kernel32.lib
includelib includes\user32.lib


BSIZE equ 25

.data 
in_file_name db "C:\Users\komp4\Documents\ASM Visual\Projects\lb_6\in.txt", 0
out_file_name db "C:\Users\komp4\Documents\ASM Visual\Projects\lb_6\out.txt",0
v_1 db "Symbol before = ", 0
v_2 db "Symbol after = ", 0
num_str db 30h ; 0 номер строки
ord_num_symb dd 0; порядковый номер символа
crnt_str db 1024 dup(?) ;текущая строка для анализа
array_sh db 1024 dup(?) ;массивв отсортированных строк
buf db 1024 dup(?)

symb_check db ?; символ для сравнения
count_of_read db ?
stdout dd ?
stdin dd ?
std_out_file dd ?
std_in_file dd ?
size_file dd ?
buf_1 db ?
buf_2 db ?
symb_before db ?
symb_after db ?
cRead dw ?
cWritten dw ?

.code

start:

	invoke GetStdHandle , -10 ;дескриптор ввода на консоль 

	mov stdin,eax

	invoke GetStdHandle, -11 ;дескриптор вывода на консоль 

	mov stdout, eax ; указатель вывода сохраняем в переменную

	invoke WriteConsoleA,stdout,ADDR v_1, 16, ADDR cWritten,NULL;приглашение ввода
   
	invoke ReadConsole ,stdin, ADDR symb_before, BSIZE, ADDR cRead,NULL;ввод
	
	cmp cRead,2 ;если ничего не введено
    jz Exit   ;то выход
   
	invoke WriteConsoleA,stdout,ADDR v_2, 16, ADDR cWritten,NULL;приглашение ввода
   
	invoke ReadConsole ,stdin, ADDR symb_after, BSIZE,ADDR cRead,NULL;ввод
	
    cmp cRead,2 ;если ничего не введено
    jz Exit     ;то выход
    
	invoke CreateFileA, ADDR in_file_name, GENERIC_READ, 0, 0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0

	mov std_in_file, eax

	invoke ReadFile, std_in_file, ADDR buf, sizeof buf, ADDR cRead, 0

	invoke CloseHandle, std_in_file

	;ОБРАБОТКА СТРОК
	
	mov esi, OFFSET buf; исходный массив

	mov edi, OFFSET crnt_str

	cld; df=0
	
	inc num_str;увеличивается номер строки 
	
	mov al, num_str

	mov ecx,ord_num_symb

	add [array_sh+ecx], al

	inc ord_num_symb

	mov ecx,ord_num_symb

	mov [array_sh+ecx], ')'

	inc ord_num_symb
	
Check_str:
	
	lodsb
	
	cmp al,13; 13 конец строки
	
	je NewStr
	
	cmp al,0; 10 перенос
	
	je Zapis

	mov ecx,ord_num_symb
	
	mov [array_sh+ecx], al ;добавляем прочитанный символ в массив
	
	inc ord_num_symb ;увеличиваем номер символа
	
	
	cmp al, symb_before
	           
	je Nashel
	
	stosb

	jmp Check_str

NewStr:

	lodsb
	
	mov ecx, ord_num_symb
	
	mov [array_sh+ecx], 13
	
	inc ord_num_symb
	
	inc num_str
	
	mov al, num_str

	mov ecx, ord_num_symb

	add [array_sh+ecx], al

	inc ord_num_symb

	mov ecx, ord_num_symb

	mov [array_sh+ecx], ')'

	inc ord_num_symb
	
	jmp Check_str

Nashel:
	mov ecx, ord_num_symb
	mov al, symb_after
	mov [array_sh+ecx], al
	inc ord_num_symb
	stosb
	jmp Check_str
	
Zapis:
	invoke CreateFileA,offset out_file_name,GENERIC_WRITE,0,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0

	mov std_out_file,eax

	invoke WriteFile,std_out_file,offset array_sh,sizeof array_sh,offset count_of_read,0

	invoke CloseHandle,std_out_file
	
Exit:
	
	invoke ExitProcess,0

	end start
