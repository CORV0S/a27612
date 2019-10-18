%include        'functions.asm'

struc sockaddr_in
   .sin_family resw 1
   .sin_port resw 1
   .sin_addr resd 1
   .sin_zero resb 8
endstruc

section .bss
   sock resw 2
   server resw 2
   echobuf resb 256
   read_count resw 2
   serv_ip resb 5
   serv_port resb 5
   ipoctone resb 5
   ipocttwo resb 5
   ipoctthree resb 5
   ipoctfour resb 5
   power resb 5

section .data
   sock_err_msg     db "Failed to initialize socket", 0x0a, 0
   sock_err_msg_len equ $ - sock_err_msg

   connect_err_msg     db "Failed to connect to server", 0x0a, 0
   connect_err_msg_len equ $ - connect_err_msg

   connect_msg      db "Connection successful", 0x0a, 0
   connect_msg_len  equ $ - connect_msg

   ip_msg      db "Please enter the server's ip address: ", 0x0a, 0
   ip_msg_len  equ $ - ip_msg

   port_msg      db "Please enter the server's port number: ", 0x0a, 0
   port_msg_len  equ $ - port_msg

   pop_sa istruc sockaddr_in
      at sockaddr_in.sin_family, dw 2
      at sockaddr_in.sin_port, dw 0xce56
      at sockaddr_in.sin_addr, dd 0
      at sockaddr_in.sin_zero, dd 0, 0
   iend
   sockaddr_in_len    equ $ pop_sa

section .text

;; Client main entry point
_start:
   ;; Initialize the client and server socket values to 0, used for cleanup
   mov    word [sock], 0
   mov    word [server], 0

   ;; Initialize socket
   call   _socket

   .mainloop
      ;; prompt for server address
      call _get_server
      ;; prompt for server port
      call _get_port
      ;; convert server ip to hex

      ;; convert port to hex

      ;; connect to server

      ;; prompt loop

         ;; prompt for phrase to echo

         ;; send phrase to server

         ;; receive phrase to server

         ;; echo phrase

         ;; prompt if done

         ;; if done close connection and end, if not done loop to prompt for phrase

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
   mov ecx, serv_ip 
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h

   ret
_get_port:
   ;Prompt User 
   mov eax, 4 
   mov ebx, 1     ; descriptor value for stdout
   mov ecx, port_msg 
   mov edx, port_msg_len 
   int 80h 

   ;Read and store the user input 
   mov eax, 3 
   mov ebx, 0     ; descriptor value for stdin
   mov ecx, serv_port 
   mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
   int 80h 

   ret
;; Perfomrs a sys_socket call to initialise a TCP/IP listening socket.
;; Stores the sockett file descriptor in the sock variable
_socket:
   mov   rax, 41   ; SYS_SOCKET
   mov   rdi, 2    ; AF_INET
   mov   rsi, 1    ; SOCK_STREAM
   mov   rdx, 0
   syscall

   ;; Check if socket was created successfully
   cmp   rax, 0
   jle   _socket_fail

   ;; Store the new socket descriptor
   mov    [sock], rax

   ret

_connect:

;; Read up to 256 bytes from the client into echobuf and sets the read_count variable
;; to be the number of bytes read by sys_read
_read:  
;; send  a  series  of  messages  of  the  server,  which  the  server  will  simply echo back to the client. The client will print ;; out the echoed strings together with the server IP.  •You  will  also  modify  the  server  code  to  receive  a  series  of  mes
   ;; Call sys_read
   mov   rax, 0         ; SYS_READ
   mov   rdi, [server]  ; server socket fd
   mov   rsi, echobuf   ; buffer
   mov   rdx, 256       ; read 256 bytes
   syscall

   ;; Copy number of bytes read to variable
   mov    [read_count], rax

   ret

;; Performs sys_close on the socket in rdi\
_close_sock:
   mov   rax, 3   ; SYS_CLOSE
   syscall

   ret

;; Sends up to the value of read_count bytes from echobyf to the server socket
;; using sys_write
_echo:
   mov   rax, 1
   mov   rdi, [server]
   mov   rsi, echobuf
   mov   rdx, [read_count]
   syscall

   ret

;; Error Handling code
;; _*_fail loads the rsi and rdx registers with the appropriate
;; error messages for given system call. Then call _fail to display the
;; error message and exit the application.
_socket_fail:
   mov   rsi, sock_err_msg
   mov   rdx, sock_err_msg_len
   call  _fail

_connect_fail:
   mov   rsi, connect_err_msg
   mov   rdx, connect_err_msg_len
   call  _fail

;; Calls the sys_write syscall, writing an error message to stderr, then exits
;; the application, rsi and rdx must be loaded with the error message and
;; length of the error message before calling _fail
_fail:
   mov   rax, 1 ; SYS_WRITE
   mov   rdi, 1 ; STDERR
   syscall

   mov   rdi, 1
   call  _exit

;; Exits cleanly, checking if the server socket need to be closed
;; before calling sys_exit
_exit:
   mov   rax, [sock]
   cmp   rax, 0
   je    .server_check
   mov   rdi, [sock]
   call  _close_sock

   .server_check:
   mov   rax, [server]
   cmp   rax, 0
   je    .perform_exit
   mov   rdi, [server]
   call  _close_sock

   .perform_exit:
   mov   rax, 60
   syscall

;-----------------------------------------
; convert ip address to integer sum:
; example = (input) 192.168.42.72 = (72 * 256^0) + (42 * 256^1) + (168 * 256^2) + (192 * 256^3)
; = (output) 3232246344
_iptoi:
; find length of string
   mov rax, serv_ip
   call slen
; ip address length is now rax
   psh 999 ; to show no more items in stack
   mov rsi, rax
   
; check each character, push each onto stack byte[ip_addr] = ip_addr[0] therefore byte[ip_addr + 1] = ip_addr[1]
; begin checking loop from end of address to the beginning
; when check == "." pop stack into first octet var
; continue until all chars have been checked for string length
nextaddresschar:
   mov rbx, 0
   cmp byte [rbx], rsi
   jg _ldotfound
   inc rbx
   cmp byte [rsi], '.'
   je _dotfound
   jne _pushnum
   jmp nextaddresschar

; math time

ret

; if '.' is found in address string, pop stack and convert to int
_dotfound:
  pop rax
  ; atoi
  mov rcx, rax
  pop rax
  cmp rax, 999
  je endstack
  ; atoi
  mov rdx, 10
  mul rdx
  add rcx, rax
  pop rax 
  cmp rax, 999
  je endstack
  ; atoi
  rdx, 100
  mul rdx
  add rcx, rax
  ; store item in variable
  mov ipoctone, rcx
  

endstack:
  push 999
  jmp nextaddresschar

; if '.' is not found in address push char onto stack
_pushnum:
   mov rcx, byte [rax]
   push rcx
   ret

; convert integer to hexadecimal
; example = (input) 3232246344
; = (output) 0xc0a82a48
_itoh:

ret