;------------------------------------------
; int atoi(Integer number)
; Ascii to integer function (atoi)
f_atoi:
    push    rbx             ; preserve rbx on the stack to be restored after function runs
    push    rcx             ; preserve rcx on the stack to be restored after function runs
    push    rdx             ; preserve rdx on the stack to be restored after function runs
    push    rsi             ; preserve rsi on the stack to be restored after function runs
    mov     rsi, rax        ; move pointer in rax into rsi (our number to convert)
    mov     rax, 0          ; initialise rax with decimal value 0
    mov     rcx, 0          ; initialise rcx with decimal value 0
 
.multiplyLoop:
    xor     rbx, rbx        ; resets both lower and uppper bytes of rbx to be 0
    mov     r8, [rsi+rcx]   ; move a single byte into rbx register's lower half
    cmp     r8, 48          ; compare rbx register's lower half value against ascii value 48 (char value 0)
    jl      .finished       ; jump if less than to label finished
    cmp     r8, 57          ; compare rbx register's lower half value against ascii value 57 (char value 9)
    jg      .finished       ; jump if greater than to label finished
 
    sub     r8, 48          ; convert rbx register's lower half to decimal representation of ascii value
    add     rax, rbx        ; add rbx to our interger value in rax
    mov     rbx, 10         ; move decimal value 10 into rbx
    mul     rbx             ; multiply rax by rbx to get place value
    inc     rcx             ; increment rcx (our counter register)
    jmp     .multiplyLoop   ; continue multiply loop
 
.finished:
    mov     rbx, 10         ; move decimal value 10 into rbx
    div     rbx             ; divide rax by value in rbx (in this case 10)
    pop     rsi             ; restore rsi from the value we pushed onto the stack at the start
    pop     rdx             ; restore rdx from the value we pushed onto the stack at the start
    pop     rcx             ; restore rcx from the value we pushed onto the stack at the start
    pop     rbx             ; restore rbx from the value we pushed onto the stack at the start
    ret


;------------------------------------------
; void iprintLF(Integer number)
; Integer printing function with linefeed (itoa)
f_iprintLF:
    call    f_iprint          ; call our integer printing function
 
    push    rax             ; push rax onto the stack to preserve it while we use the rax register in this function
    mov     rax, 0Ah        ; move 0Ah into rax - 0Ah is the ascii character for a linefeed
    push    rax             ; push the linefeed onto the stack so we can get the address
    mov     rax, rsp        ; move the address of the current stack pointer into rax for sprint
    call    f_sprint          ; call our sprint function
    pop     rax             ; remove our linefeed character from the stack
    pop     rax             ; restore the original value of rax before our function was called
    ret
 
;------------------------------------------
; int slen(String message)
; String length calculation function
f_slen:
    push    rbx
    mov     rbx, rax
 
f_nextchar:
    cmp     byte [rax], 0
    jz      f_finished
    inc     rax
    jmp     f_nextchar
 


f_finished:
    sub     rax, rbx
    pop     rbx
    ret

;------------------------------------------
; void sprint(String message)
; String printing function
f_sprint:
    push    rdx
    push    rcx
    push    rbx
    push    rax
    call    f_slen
 
    mov     rdx, rax
    pop     rax
 
    mov     rcx, rax
    mov     rbx, 1
    mov     rax, 4
    int     80h
 
    pop     rbx
    pop     rcx
    pop     rdx
    ret

;------------------------------------------
; void iprint(Integer number)
; Integer printing function (itoa)
f_iprint:
    push    rax             ; preserve rax on the stack to be restored after function runs
    push    rcx             ; preserve rcx on the stack to be restored after function runs
    push    rdx             ; preserve rdx on the stack to be restored after function runs
    push    rsi             ; preserve rsi on the stack to be restored after function runs
    mov     rcx, 0          ; counter of how many bytes we need to print in the end
 
f_divideLoop:
    inc     rcx             ; count each byte to print - number of characters
    mov     rdx, 0          ; empty rdx
    mov     rsi, 10         ; mov 10 into rsi
    idiv    rsi             ; divide rax by rsi
    add     rdx, 48         ; convert rdx to it's ascii representation - rdx holds the remainder after a divide instruction
    push    rdx             ; push rdx (string representation of an intger) onto the stack
    cmp     rax, 0          ; can the integer be divided anymore?
    jnz     f_divideLoop      ; jump if not zero to the label divideLoop
 
f_printLoop:
    dec     rcx             ; count down each byte that we put on the stack
    mov     rax, rsp        ; mov the stack pointer into rax for printing
    call    f_sprint          ; call our string print function
    pop     rax             ; remove last character from the stack to move rsp forward
    cmp     rcx, 0          ; have we printed all bytes we pushed onto the stack?
    jnz     f_printLoop       ; jump is not zero to the label printLoop
 
    pop     rsi             ; restore rsi from the value we pushed onto the stack at the start
    pop     rdx             ; restore rdx from the value we pushed onto the stack at the start
    pop     rcx             ; restore rcx from the value we pushed onto the stack at the start
    pop     rax             ; restore rax from the value we pushed onto the stack at the start
    ret
 

;------------------------------------------
; void exit()
; Exit program and restore resources
f_quit:
    mov     rbx, 0
    mov     rax, 1
    int     80h
    ret

