global proberen
global verhogen
global proberen_time

extern get_os_time

section .text

align 8
%macro proberen_m 0
; wait for resources (spinlock)
%%prob:
  cmp dword [rdi], esi
  jl %%prob
  
; lower the semaphore
  mov r11d, esi
  neg r11d
  lock xadd dword [rdi], r11d
  cmp r11d, esi
; check if it was legal
  jge %%proberen_ok
; if not, raise the semaphore
  lock add dword [rdi], esi
  jmp %%prob
  
%%proberen_ok:
%endmacro

proberen:
  proberen_m
  ret

verhogen:
; raise the semaphore
  lock add dword [rdi], esi
  ret


proberen_time:  
; saving crucial registers at stack
  push rdi
  push rsi

; pushing garbage to align rsp
  push r13
 
  call get_os_time
  
; removing garbage
  pop r13

; getting back
  pop rsi
  pop rdi

; saving the result of get_os_time
  push rax
  
  proberen_m

  call get_os_time

; calculating time difference
  pop rcx
  sub rax, rcx
  ret

 


