%include 'functions.asm'
;; TCP echo server using x86_64 Linux syscalls
;; Assemble and link as follows:
;;        nasm -f elf64 -o test.o test.asm
;;        ld test.o -o test
;;   
;;      TEST FILES FOR RUNNING SIMPLE FUNCTIONS

SECTION .bss
   serv_ip resb 16

SECTION .data
   ip_msg      db "Please enter the server's ip address: ", 0x0a, 0
   ip_msg_len  equ $ - ip_msg
   max_ip_len  equ 16

;; Client main entry point
global _start
_start:
    call _get_server
    


    mov rax, serv_ip

    call f_sprint
    ;call f_atoi

    ;add rax, 6
    ;call f_iprint

    call f_quit

_get_server:
   ;Prompt User 
   mov rax, 4 
   mov rbx, 1     ; descriptor value for stdout
   mov rcx, ip_msg 
   mov rdx, ip_msg_len 
   int 80h 

   ;Read and store the user input 
   mov rax, 3 
   mov rbx, 0     ; descriptor value for stdin
   mov rcx, serv_ip 
   mov rdx, max_ip_len     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ret

