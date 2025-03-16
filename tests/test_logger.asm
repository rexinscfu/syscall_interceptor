; test_logger.asm - Test for the logger module
; REXIN, 2025

format ELF64 executable

section '.text' executable

extern log_init
extern log_write
extern log_close

; Entry point
_start:
    ; Initialize logger
    call log_init
    test eax, eax
    jnz .error
    
    ; Write test messages
    lea rdi, [msg1]
    call log_write
    
    lea rdi, [msg2]
    call log_write
    
    lea rdi, [msg3]
    call log_write
    
    ; Close logger
    call log_close
    
    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; status = 0
    syscall
    
.error:
    ; Exit with error
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; status = 1
    syscall

section '.data' writeable

; Test messages
msg1 db 'Test message 1', 0
msg2 db 'Test message 2', 0
msg3 db 'Test message 3', 0 