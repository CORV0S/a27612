%include 'functions32.asm'
;; Assemble and link as follows:
;;        nasm -f elf -g test.asm
;;        ld -m elf_i386 -o test test.o
;;   
;;      TEST FILES FOR RUNNING SIMPLE FUNCTIONS

SECTION .bss
   servip resb 5

SECTION .data
   ip_msg      db "Please enter the server's ip address: ", 0x0a, 0
   ip_msg_len  equ $ - ip_msg
   max_ip_len  equ 16

;; Client main entry point
global _start
_start:
    call _get_server
    


    mov eax, servip

    call f_atoi

    add eax, 3

    call f_iprintLF

    call f_quit

_get_server:
   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, ip_msg 
   mov edx, ip_msg_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, servip 
   mov edx, max_ip_len     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ret

