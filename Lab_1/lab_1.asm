.386

.model flat,stdcall
option casemap:none

include includes\kernel32.inc
include includes\user32.inc

includelib includes\kernel32.lib
includelib includes\user32.lib

BSIZE equ 10

a equ 1
b equ 4
e_c equ 2
d equ 3
e equ 8
f equ 5
g equ 4
h equ 0
k equ 12
m equ 7

.data

  ifmt db "%d", 0; строка формата

  buf db BSIZE dup(?); буфер выходного потока

  result dd ?

  stdout dd ?

  cWritten dd ?

.code

start:

  mov result, a-b+e_c-d+e+f+g-h+k+m

  invoke GetStdHandle, -11 ; дескриптор вывода

  mov stdout,eax ; по умолчанию помещается в eax

  invoke wsprintf, ADDR buf, ADDR ifmt, result

  invoke WriteConsoleA, stdout, ADDR buf, BSIZE, ADDR

  cWritten, 0

  invoke ExitProcess,0

end start
