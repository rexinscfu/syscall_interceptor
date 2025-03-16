; logger.asm - Logging functionality for syscall_interceptor
; REXIN, 2025

format ELF64

section '.text' executable

public _log_init
public _log_write
public _log_close

; Constants
LOG_BUFFER_SIZE equ 4096
MAX_LOG_SIZE equ 1024*1024*10  ; 10MB max log size

; Data section
section '.data' writeable

log_file_handle dd 0
log_buffer rb LOG_BUFFER_SIZE
log_buffer_pos dd 0
log_file_name db 'syscall_interceptor.log', 0
log_file_size dd 0

; Log initialization
; Input: none
; Output: eax = 0 on success, error code otherwise
_log_init:
    push rbx
    push rcx
    push rdx
    
    ; Open log file (create or append)
    mov rax, 2          ; sys_open
    lea rdi, [log_file_name]
    mov rsi, 102o       ; O_CREAT | O_WRONLY | O_APPEND
    mov rdx, 0644o      ; File permissions
    syscall
    
    cmp rax, 0
    jl .error
    
    ; Store file handle
    mov [log_file_handle], eax
    
    ; Reset buffer position
    mov dword [log_buffer_pos], 0
    
    ; Get file size
    mov rax, 8          ; sys_lseek
    mov rdi, [log_file_handle]
    xor rsi, rsi        ; offset = 0
    mov rdx, 2          ; SEEK_END
    syscall
    
    cmp rax, 0
    jl .error
    
    ; Store file size
    mov [log_file_size], eax
    
    ; Reset file position to end
    mov rax, 8          ; sys_lseek
    mov rdi, [log_file_handle]
    mov rsi, [log_file_size]
    mov rdx, 0          ; SEEK_SET
    syscall
    
    xor rax, rax        ; Return success
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret
    
.error:
    mov rax, -1         ; Return error
    jmp .done

; Write to log
; Input: rdi = pointer to null-terminated string
; Output: eax = 0 on success, error code otherwise
_log_write:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Check if log file is open
    cmp dword [log_file_handle], 0
    je .error
    
    ; Calculate string length
    mov rsi, rdi
    xor rcx, rcx
    
.strlen_loop:
    cmp byte [rsi], 0
    je .strlen_done
    inc rcx
    inc rsi
    jmp .strlen_loop
    
.strlen_done:
    ; Check if buffer has enough space
    mov eax, [log_buffer_pos]
    add eax, ecx
    cmp eax, LOG_BUFFER_SIZE
    jge .flush_buffer
    
.copy_to_buffer:
    ; Copy string to buffer
    mov rsi, rdi
    lea rdi, [log_buffer + log_buffer_pos]
    rep movsb
    
    ; Update buffer position
    add [log_buffer_pos], ecx
    
    xor rax, rax        ; Return success
    jmp .done
    
.flush_buffer:
    ; Write buffer to file
    mov rax, 1          ; sys_write
    mov rdi, [log_file_handle]
    lea rsi, [log_buffer]
    mov rdx, [log_buffer_pos]
    syscall
    
    ; Check for errors
    cmp rax, 0
    jl .error
    
    ; Update file size
    add [log_file_size], eax
    
    ; Check if log file is too large
    cmp dword [log_file_size], MAX_LOG_SIZE
    jge .rotate_log
    
    ; Reset buffer position
    mov dword [log_buffer_pos], 0
    
    ; Try again with the new string
    pop rdi
    push rdi
    jmp .copy_to_buffer
    
.rotate_log:
    ; TODO: Implement log rotation
    ; For now, just truncate the file
    mov rax, 77         ; sys_ftruncate
    mov rdi, [log_file_handle]
    xor rsi, rsi
    syscall
    
    ; Reset file size
    mov dword [log_file_size], 0
    
    ; Reset buffer position
    mov dword [log_buffer_pos], 0
    
    ; Try again with the new string
    pop rdi
    push rdi
    jmp .copy_to_buffer
    
.error:
    mov rax, -1         ; Return error
    
.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Close log
; Input: none
; Output: eax = 0 on success, error code otherwise
_log_close:
    push rbx
    push rcx
    push rdx
    
    ; Check if log file is open
    cmp dword [log_file_handle], 0
    je .done
    
    ; Flush buffer if needed
    cmp dword [log_buffer_pos], 0
    je .close_file
    
    ; Write buffer to file
    mov rax, 1          ; sys_write
    mov rdi, [log_file_handle]
    lea rsi, [log_buffer]
    mov rdx, [log_buffer_pos]
    syscall
    
.close_file:
    ; Close file
    mov rax, 3          ; sys_close
    mov rdi, [log_file_handle]
    syscall
    
    ; Reset file handle
    mov dword [log_file_handle], 0
    
    xor rax, rax        ; Return success
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret 