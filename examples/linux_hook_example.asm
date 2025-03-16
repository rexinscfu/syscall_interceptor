; linux_hook_example.asm - Example of syscall hooking on Linux
; REXIN, 2025

format ELF64 executable

include '../include/syscall_defs.inc'

section '.text' executable

extern hook_init
extern hook_syscall
extern unhook_syscall
extern unhook_all
extern log_init
extern log_write
extern log_close

; Custom write syscall handler
; This will be called instead of the original write syscall
custom_write_handler:
    ; Save registers
    push rax
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11
    
    ; Log the write syscall
    lea rdi, [write_msg]
    call log_write
    
    ; Restore registers
    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    ; Call original write syscall
    ; In a real implementation, we would call the original handler
    ; For now, we'll just do the syscall directly
    mov rax, SYS_write
    syscall
    
    ret

; Entry point
_start:
    ; Initialize logger
    call log_init
    
    ; Log start message
    lea rdi, [start_msg]
    call log_write
    
    ; Initialize syscall hooking
    call hook_init
    test rax, rax
    jnz .error
    
    ; Hook write syscall
    mov rdi, SYS_write
    lea rsi, [custom_write_handler]
    call hook_syscall
    test rax, rax
    jnz .error
    
    ; Test the hook by writing to stdout
    mov rax, SYS_write
    mov rdi, 1          ; stdout
    lea rsi, [test_msg]
    mov rdx, test_msg_len
    syscall
    
    ; Unhook write syscall
    mov rdi, SYS_write
    call unhook_syscall
    
    ; Unhook all syscalls
    call unhook_all
    
    ; Log end message
    lea rdi, [end_msg]
    call log_write
    
    ; Close logger
    call log_close
    
    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; status = 0
    syscall
    
.error:
    ; Log error message
    lea rdi, [error_msg]
    call log_write
    
    ; Close logger
    call log_close
    
    ; Exit with error
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; status = 1
    syscall

section '.data' writeable

; Messages
start_msg db 'Starting syscall hook example', 0
write_msg db 'Write syscall intercepted', 0
test_msg db 'This is a test message', 10
test_msg_len = $ - test_msg
end_msg db 'Syscall hook example completed', 0
error_msg db 'Error in syscall hook example', 0 