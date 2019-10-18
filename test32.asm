%include 'functions32.asm'
;; Assemble and link as follows:
;;        nasm -f elf -g test.asm
;;        ld -m elf_i386 -o test test.o
;;   
;;      TEST FILES FOR RUNNING SIMPLE FUNCTIONS

SECTION .bss
   servip1 resb 5
   servip2 resb 5
   servip3 resb 5
   servip4 resb 5
   servport resb 5

SECTION .data
   ip_msg1      db "Please enter the server's ip 1st octet (192).168.72.3: ", 0x0a, 0
   ip_msg1_len  equ $ - ip_msg1
   ip_msg2      db "Please enter the server's ip 2nd octet 192.(168).72.3: ", 0x0a, 0
   ip_msg2_len  equ $ - ip_msg2
   ip_msg3      db "Please enter the server's ip 3rd octet 192.168.(72).3: ", 0x0a, 0
   ip_msg3_len  equ $ - ip_msg3
   ip_msg4      db "Please enter the server's ip 4th octet 192.168.72.(3): ", 0x0a, 0
   ip_msg4_len  equ $ - ip_msg4
   port_msg      db "Please enter the server's port: ", 0x0a, 0
   port_msg_len  equ $ - port_msg

;; Client main entry point
global _start
_start:
    call _get_server
    


    mov eax, servip1

    call f_atoi

    mov ecx, 3
    call _power
    mul ebx

    call f_iprintLF

    call f_quit

_power:
   push eax
   mov eax, 256
   powloop:
      cmp ecx, 0
      je powfin
      mov ebx, 256
      mul ebx
      dec ecx
      jmp powloop
   powfin:
      mov ebx, eax
      pop eax

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
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, ip_msg2 
   mov edx, ip_msg2_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, servip2 
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, ip_msg3 
   mov edx, ip_msg3_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, servip3 
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, ip_msg4 
   mov edx, ip_msg4_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, servip4 
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
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
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ret

