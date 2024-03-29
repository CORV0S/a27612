;; TCP echo server using x86_64 Linux syscalls
;; Assemble and link as follows:
;;        nasm -f elf64 -o server.o server.asm
;;        ld server.o -o server
;;   
;;
%include        'functions.asm'

global _start

;; Data definitions
struc sockaddr_in
    .sin_family resw 1
    .sin_port resw 1
    .sin_addr resd 1
    .sin_zero resb 8
endstruc

section .bss
    sock resw 2
    client resw 2
    echobuf resb 256
    read_count resw 2
    msg resb 256
    msgnum resb 5
    ipstr resb 20
    portstr resb 10

section .data
    sock_err_msg        db "Failed to initialize socket", 0x0a, 0
    sock_err_msg_len    equ $ - sock_err_msg

    bind_err_msg        db "Failed to bind socket", 0x0a, 0
    bind_err_msg_len    equ $ - bind_err_msg

    lstn_err_msg        db "Socket Listen Failed", 0x0a, 0
    lstn_err_msg_len    equ $ - lstn_err_msg

    accept_err_msg      db "Accept Failed", 0x0a, 0
    accept_err_msg_len  equ $ - accept_err_msg

    accept_msg          db "Client Connected!", 0x0a, 0
    accept_msg_len      equ $ - accept_msg

    got_here          db "Got here", 0x0a, 0
    got_here_len      equ $ - got_here

    getmsg          db "Enter your message: ", 0x0a, 0
    getmsg_len      equ $ - getmsg

    getip_msg          db "Enter server ip: ", 0x0a, 0
    getip_msg_len      equ $ - getip_msg

    getport_msg          db "Enter server port: ", 0x0a, 0
    getport_msg_len      equ $ - getport_msg

    getmsgnumstr          db "How many messages?: ", 0x0a, 0
    getmsgnumstr_len      equ $ - getmsgnumstr

    ;; sockaddr_in structure for the address the listening socket binds to
    pop_sa istruc sockaddr_in
        at sockaddr_in.sin_family, dw 2           ; AF_INET
        at sockaddr_in.sin_port, dw 0xce56        ; port 22222 in host byte order
        at sockaddr_in.sin_addr, dd 0             ; localhost - INADDR_ANY
        at sockaddr_in.sin_zero, dd 0, 0
    iend
    sockaddr_in_len     equ $ - pop_sa

section .text

;; Sever main entry point
_start:
    ;; Initialize listening and client socket values to 0, used for cleanup 
    mov      word [sock], 0
    mov      word [client], 0

    ;call _getip
    ;call _getport

    ;; Initialize socket
    call     _socket
    call     _got_here

    ;; Bind and Listen

    call     _connect
    call     _got_here
    call _getmsgnum
    mov eax, msgnum
    call atoi
    push rax
    ;; Main loop handles connection requests (accept()) then echoes data back to client
    .mainloop:

        
        call _get_msg
        ;; Read and echo string back to the client
        ;; up the connection on their end.

        ;.readloop:
            call     _echo
            call     _read
            call     _print

     pop rax
     dec rax
     
     cmp rax, 0
     je .done
     push rax
     jmp .mainloop
     .done:
            

            ;; read_count is set to zero when client hangs up
            ; mov     rax, [read_count]
            ; cmp     rax, 0
            ; je      .read_complete
        ;jmp .readloop

        .read_complete:
        ;; Close client socket
        mov    rdi, [sock]
        call   _close_sock
        mov    word [sock], 0
    ;jmp    .mainloop

    ;; Exit with success (return 0)
    mov     rdi, 0
    call     _exit

;; Performs a sys_socket call to initialise a TCP/IP listening socket. 
;; Stores the socket file descriptor in the sock variable
_socket:
    mov         rax, 41     ; SYS_SOCKET
    mov         rdi, 2      ; AF_INET
    mov         rsi, 1      ; SOCK_STREAM
    mov         rdx, 0    
    syscall
    
    ;; Check if socket was created successfully
    cmp        rax, 0
    jle        _socket_fail

    ;; Store the new socke_accept_failt descriptor 
    mov        [sock], rax

    ret


_connect:
    mov         rax, 42          ; SYS_CONNECt
    mov         rdi, [sock]      ; AF_INET
    mov         rsi, pop_sa      ; SOCK_STREAM
    mov         rdx, sockaddr_in_len    
    syscall
    call     _got_here

    ret

;; Reads up to 256 bytes from the client into echobuf and sets the read_count variable
;; to be the number of bytes read by sys_read
_read:
    ;; Call sys_read
    mov     rax, 0          ; SYS_READ
    mov     rdi, [sock]   ; client socket fd
    mov     rsi, echobuf    ; buffer
    mov     rdx, 256        ; read 256 bytes 
    syscall 

    ;; Copy number of bytes read to variable
    mov     [read_count], rax

    ret 

;; Print data received from client
_print:
    mov       rax, 1             ; SYS_WRITE
    mov       rdi, 1             ; STDOUT
    mov       rsi, echobuf
    mov       rdx, [read_count]
    syscall

    ret

;; Sends up to the value of read_count bytes from echobuf to the client socket
;; using sys_write 
_echo:
    mov     rax, 1               ; SYS_WRITE
    mov     rdi, [sock]        ; client socket fd
    mov     rsi, msg         ; buffer
    mov     rdx, 256    ; number of bytes received in _read
    syscall

    ret

;; Performs sys_close on the socket in rdi
_close_sock:
    mov     rax, 3        ; SYS_CLOSE
    syscall

    ret

;; Error Handling code
;; _*_fail loads the rsi and rdx registers with the appropriate
;; error messages for given system call. Then call _fail to display the
;; error message and exit the application.
_socket_fail:
    mov     rsi, sock_err_msg
    mov     rdx, sock_err_msg_len
    call    _fail

_bind_fail:
    mov     rsi, bind_err_msg
    mov     rdx, bind_err_msg_len
    call    _fail

_listen_fail:
    mov     rsi, lstn_err_msg
    mov     rdx, lstn_err_msg_len
    call    _fail

_accept_fail:
    mov     rsi, accept_err_msg
    mov     rdx, accept_err_msg_len
    call    _fail


_got_here:    
    push rax                    ; store current rax
    push rdi                    ; store current rax
    push rsi                    ; store current rax
    push rdx                    ; store current rax
    ;; Print connection message to stdout
    mov       rax, 1             ; SYS_WRITE
    mov       rdi, 1             ; STDOUT
    mov       rsi, got_here
    mov       rdx, got_here_len
    syscall

    pop rdx                    ; store current rax
    pop rsi                    ; store current rax
    pop rdi                    ; store current rax
    pop rax                    ; store current rax
    ret

;; Calls the sys_write syscall, writing an error message to stderr, then exits
;; the application. rsi and rdx must be loaded with the error message and
;; length of the error message before calling _fail
_fail:
    mov        rax, 1 ; SYS_WRITE
    mov        rdi, 2 ; STDERR
    syscall

    mov        rdi, 1
    call       _exit

;; Exits cleanly, checking if the listening or client sockets need to be closed
;; before calling sys_exit
_exit:
    mov        rax, [sock]
    cmp        rax, 0
    je         .client_check
    mov        rdi, [sock]
    call       _close_sock

    .client_check:
    mov        rax, [client]
    cmp        rax, 0
    je         .perform_exit
    mov        rdi, [client]
    call       _close_sock

    .perform_exit:
    mov        rax, 60
    syscall

_get_msg:
    push rax                    ; store current rax
    push rdi                    ; store current rax
    push rsi                    ; store current rax
    push rdx                    ; store current rax
    ;; Print connection message to stdout
    mov       rax, 1             ; SYS_WRITE
    mov       rdi, 1             ; STDOUT
    mov       rsi, getmsg
    mov       rdx, getmsg_len
    syscall

    mov eax, 3 
    mov ebx, 0     ; descriptor value for stdin
    mov ecx, msg 
    mov edx, 256     ;5 bytes (numeric, 1 for sign) of that information 
    int 80h

    pop rdx                    ; store current rax
    pop rsi                    ; store current rax
    pop rdi                    ; store current rax
    pop rax                    ; store current rax
ret

_getmsgnum:
    push rax                    ; store current rax
    push rdi                    ; store current rax
    push rsi                    ; store current rax
    push rdx                    ; store current rax
    ;; Print connection message to stdout
    mov       rax, 1             ; SYS_WRITE
    mov       rdi, 1             ; STDOUT
    mov       rsi, getmsgnumstr
    mov       rdx, getmsgnumstr_len
    syscall

    mov eax, 3 
    mov ebx, 0     ; descriptor value for stdin
    mov ecx, msgnum 
    mov edx, 5     ;5 bytes (numeric, 1 for sign) of that information 
    int 80h

    pop rdx                    ; store current rax
    pop rsi                    ; store current rax
    pop rdi                    ; store current rax
    pop rax                    ; store current rax
    
ret

_getip:
    push rax                    ; store current rax
    push rdi                    ; store current rax
    push rsi                    ; store current rax
    push rdx                    ; store current rax
    ;; Print connection message to stdout
    mov       rax, 1             ; SYS_WRITE
    mov       rdi, 1             ; STDOUT
    mov       rsi, getip_msg
    mov       rdx, getip_msg_len
    syscall

    mov eax, 3 
    mov ebx, 0     ; descriptor value for stdin
    mov ecx, ipstr 
    mov edx, 20     ;5 bytes (numeric, 1 for sign) of that information 
    int 80h

    pop rdx                    ; store current rax
    pop rsi                    ; store current rax
    pop rdi                    ; store current rax
    pop rax                    ; store current rax
    
ret

_getport:
    push rax                    ; store current rax
    push rdi                    ; store current rax
    push rsi                    ; store current rax
    push rdx                    ; store current rax
    ;; Print connection message to stdout
    mov       rax, 1             ; SYS_WRITE
    mov       rdi, 1             ; STDOUT
    mov       rsi, getport_msg
    mov       rdx, getport_msg_len
    syscall

    mov eax, 3 
    mov ebx, 0     ; descriptor value for stdin
    mov ecx, portstr 
    mov edx, 10     ;5 bytes (numeric, 1 for sign) of that information 
    int 80h

    pop rdx                    ; store current rax
    pop rsi                    ; store current rax
    pop rdi                    ; store current rax
    pop rax                    ; store current rax
    
ret


;------------------------------------------
; int atoi(Integer number)
; Ascii to integer function (atoi)
atoi:
    push    rbx             ; preserve ebx on the stack to be restored after function runs
    push    rcx             ; preserve ecx on the stack to be restored after function runs
    push    rdx             ; preserve edx on the stack to be restored after function runs
    push    rsi             ; preserve esi on the stack to be restored after function runs
    mov     esi, eax        ; move pointer in eax into esi (our number to convert)
    mov     eax, 0          ; initialise eax with decimal value 0
    mov     ecx, 0          ; initialise ecx with decimal value 0
 
.multiplyLoop:
    xor     ebx, ebx        ; resets both lower and uppper bytes of ebx to be 0
    mov     bl, [esi+ecx]   ; move a single byte into ebx register's lower half
    cmp     bl, 48          ; compare ebx register's lower half value against ascii value 48 (char value 0)
    jl      .finished       ; jump if less than to label finished
    cmp     bl, 57          ; compare ebx register's lower half value against ascii value 57 (char value 9)
    jg      .finished       ; jump if greater than to label finished
 
    sub     bl, 48          ; convert ebx register's lower half to decimal representation of ascii value
    add     eax, ebx        ; add ebx to our interger value in eax
    mov     ebx, 10         ; move decimal value 10 into ebx
    mul     ebx             ; multiply eax by ebx to get place value
    inc     ecx             ; increment ecx (our counter register)
    jmp     .multiplyLoop   ; continue multiply loop
 
.finished:
    mov     ebx, 10         ; move decimal value 10 into ebx
    div     ebx             ; divide eax by value in ebx (in this case 10)
    pop     rsi             ; restore esi from the value we pushed onto the stack at the start
    pop     rdx             ; restore edx from the value we pushed onto the stack at the start
    pop     rcx             ; restore ecx from the value we pushed onto the stack at the start
    pop     rbx             ; restore ebx from the value we pushed onto the stack at the start
    ret
