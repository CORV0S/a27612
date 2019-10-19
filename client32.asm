%include 'functions32.asm'
;; Assemble and link as follows:
;;        nasm -f elf -g test.asm
;;        ld -m elf_i386 -o test test.o
;;   
;;      TEST FILES FOR RUNNING SIMPLE FUNCTIONS

SECTION .bss
   servip1 resb 256
   servport resb 256
   msgnum resb 5
   buffer resb 1
   msgstring resb 256

SECTION .data
   ip_msg1      db "Please enter the server's ip in hex: ", 0x0a, 0
   ip_msg1_len  equ $ - ip_msg1

   port_msg      db "Please enter the server's port in hex: ", 0x0a, 0
   port_msg_len  equ $ - port_msg

   num_msg      db "how many messages would you like to send: ", 0x0a, 0
   num_msg_len  equ $ - num_msg

   msg      db "Enter your message: ", 0x0a, 0
   msg_len  equ $ - num_msg

;; Client main entry point
global _start
_start:
    call _get_server
    
    call _socket
 
    call _connect

    mov eax, num_msg
    mov ecx, 0
    loop:
      push eax
      push ecx
      call _get_msg
      call _write
      call _read
      pop ecx
      pop eax
      cmp eax, ecx
      jl loop

    end:
      call _close

      call f_quit

_socket:
 
    push    byte 6              ; push 6 onto the stack (IPPROTO_TCP)
    push    byte 1              ; push 1 onto the stack (SOCK_STREAM)
    push    byte 2              ; push 2 onto the stack (PF_INET)
    mov     ecx, esp            ; move address of arguments into ecx
    mov     ebx, 1              ; invoke subroutine SOCKET (1)
    mov     eax, 102            ; invoke SYS_SOCKETCALL (kernel opcode 102)
    int     80h                 ; call the kernel
ret
 
_connect:
 
    mov     edi, eax            ; move return value of SYS_SOCKETCALL into edi (file descriptor for new socket, or -1 on error)
    push    servip1             ; push 139.162.39.66 onto the stack IP ADDRESS (reverse byte order)
    push    servport            ; push 80 onto stack PORT (reverse byte order)
    push    word 2              ; push 2 dec onto stack AF_INET
    mov     ecx, esp            ; move address of stack pointer into ecx
    push    byte 16             ; push 16 dec onto stack (arguments length)
    push    ecx                 ; push the address of arguments onto stack
    push    edi                 ; push the file descriptor onto stack
    mov     ecx, esp            ; move address of arguments into ecx
    mov     ebx, 3              ; invoke subroutine CONNECT (3)
    mov     eax, 102            ; invoke SYS_SOCKETCALL (kernel opcode 102)
    int     80h                 ; call the kernel
ret
 
_write:
 
    mov     edx, 43             ; move 43 dec into edx (length in bytes to write)
    mov     ecx, msgstring      ; move address of our request variable into ecx
    mov     ebx, edi            ; move file descriptor into ebx (created socket file descriptor)
    mov     eax, 4              ; invoke SYS_WRITE (kernel opcode 4)
    int     80h                 ; call the kernel
ret
 
_read:
 
    mov     edx, 1              ; number of bytes to read (we will read 1 byte at a time)
    mov     ecx, buffer         ; move the memory address of our buffer variable into ecx
    mov     ebx, edi            ; move edi into ebx (created socket file descriptor)
    mov     eax, 3              ; invoke SYS_READ (kernel opcode 3)
    int     80h                 ; call the kernel
 
    cmp     eax, 0              ; if return value of SYS_READ in eax is zero, we have reached the end of the file
    jz      _close              ; jmp to _close if we have reached the end of the file (zero flag set)
 
    mov     eax, buffer         ; move the memory address of our buffer variable into eax for printing
    call    f_sprint            ; call our string printing function
    jmp     _read               ; jmp to _read
ret
 
_close:
 
    mov     ebx, edi            ; move edi into ebx (connected socket file descriptor)
    mov     eax, 6              ; invoke SYS_CLOSE (kernel opcode 6)
    int     80h                 ; call the kernel
ret
   

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

   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, num_msg 
   mov edx, num_msg_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, msgnum
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ret


_get_msg:
   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, msg 
   mov edx, msg_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, msgstring 
   mov edx, 256     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h
   
   ret
