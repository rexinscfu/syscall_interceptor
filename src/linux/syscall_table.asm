; syscall_table.asm - Linux syscall table definitions
; REXIN, 2025

format ELF64

include '../include/syscall_defs.inc'

section '.text' executable

public _get_syscall_name
public _get_syscall_number

; Get syscall name by number
; Input: rdi = syscall number
; Output: rax = pointer to syscall name or 0 if not found
_get_syscall_name:
    push rbx
    push rcx
    
    ; Check if syscall number is valid
    cmp rdi, MAX_SYSCALL_NR
    jae .not_found
    
    ; Get syscall name
    mov rax, syscall_names
    mov rbx, rdi
    imul rbx, 8         ; Each entry is a pointer (8 bytes)
    add rax, rbx
    mov rax, [rax]      ; Load pointer to name
    
    jmp .done
    
.not_found:
    xor rax, rax        ; Return NULL
    
.done:
    pop rcx
    pop rbx
    ret

; Get syscall number by name
; Input: rdi = pointer to syscall name
; Output: rax = syscall number or -1 if not found
_get_syscall_number:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Save syscall name pointer
    mov rsi, rdi
    
    ; Iterate through syscall names
    xor rbx, rbx        ; syscall number
    
.loop:
    ; Check if we've reached the end
    cmp rbx, MAX_SYSCALL_NR
    jae .not_found
    
    ; Get syscall name
    mov rax, syscall_names
    mov rcx, rbx
    imul rcx, 8         ; Each entry is a pointer (8 bytes)
    add rax, rcx
    mov rdi, [rax]      ; Load pointer to name
    
    ; Compare names
    push rsi
    push rdi
    
.compare_loop:
    mov al, [rdi]
    mov cl, [rsi]
    
    ; Check if end of string
    test al, al
    jz .end_of_str1
    test cl, cl
    jz .end_of_str2
    
    ; Compare characters
    cmp al, cl
    jne .not_equal
    
    ; Move to next character
    inc rdi
    inc rsi
    jmp .compare_loop
    
.end_of_str1:
    ; Check if both strings ended
    test cl, cl
    jz .equal
    jmp .not_equal
    
.end_of_str2:
    ; First string didn't end
    test al, al
    jnz .not_equal
    
.equal:
    ; Strings are equal, found the syscall
    pop rdi
    pop rsi
    mov rax, rbx
    jmp .done
    
.not_equal:
    ; Strings are not equal, try next syscall
    pop rdi
    pop rsi
    inc rbx
    jmp .loop
    
.not_found:
    mov rax, -1         ; Return -1 (not found)
    
.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

section '.data' writeable

; Syscall names table
syscall_names:
    dq sys_read_name
    dq sys_write_name
    dq sys_open_name
    dq sys_close_name
    dq sys_stat_name
    dq sys_fstat_name
    dq sys_lstat_name
    dq sys_poll_name
    dq sys_lseek_name
    dq sys_mmap_name
    ; ... more syscalls would be defined here
    
    ; For brevity, we're only including a few syscalls
    ; In a real implementation, all syscalls would be listed
    
    ; Pad the rest with zeros
    times (MAX_SYSCALL_NR - 10) dq 0

; Syscall name strings
sys_read_name db 'read', 0
sys_write_name db 'write', 0
sys_open_name db 'open', 0
sys_close_name db 'close', 0
sys_stat_name db 'stat', 0
sys_fstat_name db 'fstat', 0
sys_lstat_name db 'lstat', 0
sys_poll_name db 'poll', 0
sys_lseek_name db 'lseek', 0
sys_mmap_name db 'mmap', 0
; ... more syscall names would be defined here 