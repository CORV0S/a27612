%include 'functions32.asm'
;; Assemble and link as follows:
;;        nasm -f elf -g test.asm
;;        ld -m elf_i386 -o test test.o
;;   
;;      TEST FILES FOR RUNNING SIMPLE FUNCTIONS

SECTION .bss
   servip1 resb 256
   servport resb 256

SECTION .data
   ip_msg1      db "Please enter the server's ip in hex: ", 0x0a, 0
   ip_msg1_len  equ $ - ip_msg1

   port_msg      db "Please enter the server's port in hex: ", 0x0a, 0
   port_msg_len  equ $ - port_msg

;; Client main entry point
global _start
_start:
    call _get_server
    


    mov eax, servip1

    call f_sprint


    call f_quit


   

_get_server:
   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, ip_msg1 
   mov edx, ip_msg1_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, servip1 
   mov edx, 256     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, port_msg 
   mov edx, port_msg_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, servport
   mov edx, 256     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ret

