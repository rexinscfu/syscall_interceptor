; hook.asm - Linux syscall hooking functionality
; REXIN, 2025

format ELF64

include '../include/syscall_defs.inc'

section '.text' executable

public hook_init
public hook_syscall
public unhook_syscall
public unhook_all

extern log_write

; Constants
MAX_HOOKS equ 64

; Data section
section '.data' writeable

; Original syscall table entries
original_syscalls rq MAX_HOOKS
hook_count dd 0
hook_active db 0

; Hook initialization
; Input: none
; Output: eax = 0 on success, error code otherwise
hook_init:
    push rbx
    push rcx
    push rdx
    
    ; Check if already initialized
    cmp byte [hook_active], 1
    je .already_init
    
    ; Find syscall table address
    call find_syscall_table
    test rax, rax
    jz .error
    
    ; Store syscall table address
    mov [syscall_table_addr], rax
    
    ; Reset hook count
    mov dword [hook_count], 0
    
    ; Mark as initialized
    mov byte [hook_active], 1
    
    ; Log initialization
    lea rdi, [init_msg]
    call log_write
    
    xor rax, rax        ; Return success
    jmp .done
    
.already_init:
    xor rax, rax        ; Return success
    jmp .done
    
.error:
    mov rax, -1         ; Return error
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret

; Find syscall table address
; Output: rax = syscall table address or 0 on failure
find_syscall_table:
    push rbx
    push rcx
    push rdx
    
    ; This is a placeholder - in a real implementation, we would
    ; search for the syscall table in memory or use a known offset
    ; from a kernel symbol
    
    ; For now, we'll use a hardcoded address for demonstration
    ; In a real implementation, this would be determined at runtime
    mov rax, 0xffffffff81801400  ; Example address, will be replaced
    
    ; Log the found address
    lea rdi, [table_found_msg]
    call log_write
    
    pop rdx
    pop rcx
    pop rbx
    ret

; Hook a syscall
; Input: rdi = syscall number, rsi = new handler address
; Output: eax = 0 on success, error code otherwise
hook_syscall:
    push rbx
    push rcx
    push rdx
    
    ; Check if initialized
    cmp byte [hook_active], 0
    je .not_init
    
    ; Check if syscall number is valid
    cmp rdi, MAX_SYSCALL_NR
    jae .invalid_syscall
    
    ; Check if we have room for more hooks
    mov eax, [hook_count]
    cmp eax, MAX_HOOKS
    jae .too_many_hooks
    
    ; Save original syscall handler
    mov rbx, [syscall_table_addr]
    mov rcx, [rbx + rdi*8]
    mov [original_syscalls + rax*8], rcx
    
    ; Install new handler
    mov [rbx + rdi*8], rsi
    
    ; Increment hook count
    inc dword [hook_count]
    
    ; Log the hook
    push rdi
    push rsi
    lea rdi, [hook_msg]
    call log_write
    pop rsi
    pop rdi
    
    xor rax, rax        ; Return success
    jmp .done
    
.not_init:
    mov rax, -1         ; Not initialized
    jmp .done
    
.invalid_syscall:
    mov rax, -2         ; Invalid syscall number
    jmp .done
    
.too_many_hooks:
    mov rax, -3         ; Too many hooks
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret

; Unhook a syscall
; Input: rdi = syscall number
; Output: eax = 0 on success, error code otherwise
unhook_syscall:
    push rbx
    push rcx
    push rdx
    
    ; Check if initialized
    cmp byte [hook_active], 0
    je .not_init
    
    ; Check if syscall number is valid
    cmp rdi, MAX_SYSCALL_NR
    jae .invalid_syscall
    
    ; Find the hook
    xor rcx, rcx
    mov eax, [hook_count]
    test eax, eax
    jz .not_hooked
    
.find_loop:
    ; TODO: Implement hook lookup
    ; For now, we'll just restore from the original_syscalls array
    ; This is a simplification - in a real implementation, we would
    ; track which syscalls are hooked
    
    ; Restore original handler
    mov rbx, [syscall_table_addr]
    mov rdx, [original_syscalls + rcx*8]
    mov [rbx + rdi*8], rdx
    
    ; Decrement hook count
    dec dword [hook_count]
    
    ; Log the unhook
    push rdi
    lea rdi, [unhook_msg]
    call log_write
    pop rdi
    
    xor rax, rax        ; Return success
    jmp .done
    
.not_init:
    mov rax, -1         ; Not initialized
    jmp .done
    
.invalid_syscall:
    mov rax, -2         ; Invalid syscall number
    jmp .done
    
.not_hooked:
    mov rax, -4         ; Syscall not hooked
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret

; Unhook all syscalls
; Input: none
; Output: eax = 0 on success, error code otherwise
unhook_all:
    push rbx
    push rcx
    push rdx
    
    ; Check if initialized
    cmp byte [hook_active], 0
    je .not_init
    
    ; Check if any hooks are active
    mov eax, [hook_count]
    test eax, eax
    jz .no_hooks
    
    ; TODO: Implement unhooking all syscalls
    ; For now, this is a placeholder
    
    ; Reset hook count
    mov dword [hook_count], 0
    
    ; Log the unhook all
    lea rdi, [unhook_all_msg]
    call log_write
    
    xor rax, rax        ; Return success
    jmp .done
    
.not_init:
    mov rax, -1         ; Not initialized
    jmp .done
    
.no_hooks:
    xor rax, rax        ; No hooks to remove
    
.done:
    pop rdx
    pop rcx
    pop rbx
    ret

section '.data' writeable

syscall_table_addr dq 0

; Log messages
init_msg db 'Syscall interceptor initialized', 0
table_found_msg db 'Syscall table found', 0
hook_msg db 'Syscall hooked', 0
unhook_msg db 'Syscall unhooked', 0
unhook_all_msg db 'All syscalls unhooked', 0 