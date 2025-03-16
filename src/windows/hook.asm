; hook.asm - Windows syscall hooking functionality
; REXIN, 2025

format PE64 DLL

include '../include/syscall_defs.inc'

section '.text' code readable executable

public hook_init
public hook_syscall
public unhook_syscall
public unhook_all

extern log_write

; Constants
MAX_HOOKS equ 64

; Data section
section '.data' data readable writeable

; Original syscall table entries
original_syscalls rq MAX_HOOKS
hook_count dd 0
hook_active db 0

; Hook initialization
; Input: none
; Output: rax = 0 on success, error code otherwise
hook_init:
    push rbx
    push rcx
    push rdx
    
    ; Check if already initialized
    cmp byte [hook_active], 1
    je .already_init
    
    ; Find NTDLL base address
    call find_ntdll
    test rax, rax
    jz .error
    
    ; Store NTDLL base address
    mov [ntdll_base], rax
    
    ; Reset hook count
    mov dword [hook_count], 0
    
    ; Mark as initialized
    mov byte [hook_active], 1
    
    ; Log initialization
    lea rcx, [init_msg]
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

; Find NTDLL base address
; Output: rax = NTDLL base address or 0 on failure
find_ntdll:
    push rbx
    push rcx
    push rdx
    
    ; This is a placeholder - in a real implementation, we would
    ; use PEB to find the loaded modules and locate NTDLL
    
    ; For now, we'll use a hardcoded address for demonstration
    ; In a real implementation, this would be determined at runtime
    mov rax, 0x7FFE0000  ; Example address, will be replaced
    
    ; Log the found address
    lea rcx, [ntdll_found_msg]
    call log_write
    
    pop rdx
    pop rcx
    pop rbx
    ret

; Hook a syscall
; Input: rcx = syscall name, rdx = new handler address
; Output: rax = 0 on success, error code otherwise
hook_syscall:
    push rbx
    push rsi
    push rdi
    
    ; Save parameters
    mov rsi, rcx        ; syscall name
    mov rdi, rdx        ; new handler
    
    ; Check if initialized
    cmp byte [hook_active], 0
    je .not_init
    
    ; Check if we have room for more hooks
    mov eax, [hook_count]
    cmp eax, MAX_HOOKS
    jae .too_many_hooks
    
    ; Find syscall address
    mov rcx, rsi
    call find_syscall
    test rax, rax
    jz .syscall_not_found
    
    ; Save original syscall address
    mov rbx, [hook_count]
    mov [original_syscalls + rbx*8], rax
    
    ; Install hook
    ; In a real implementation, we would modify the function prologue
    ; to jump to our handler. For now, this is a placeholder.
    
    ; Increment hook count
    inc dword [hook_count]
    
    ; Log the hook
    push rsi
    push rdi
    lea rcx, [hook_msg]
    call log_write
    pop rdi
    pop rsi
    
    xor rax, rax        ; Return success
    jmp .done
    
.not_init:
    mov rax, -1         ; Not initialized
    jmp .done
    
.too_many_hooks:
    mov rax, -3         ; Too many hooks
    jmp .done
    
.syscall_not_found:
    mov rax, -2         ; Syscall not found
    
.done:
    pop rdi
    pop rsi
    pop rbx
    ret

; Find syscall address
; Input: rcx = syscall name
; Output: rax = syscall address or 0 on failure
find_syscall:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Save syscall name
    mov rsi, rcx
    
    ; Get NTDLL base
    mov rdi, [ntdll_base]
    test rdi, rdi
    jz .error
    
    ; TODO: Implement syscall lookup in NTDLL exports
    ; For now, this is a placeholder
    
    ; Return a dummy address for demonstration
    mov rax, rdi
    add rax, 0x1000     ; Example offset
    
    jmp .done
    
.error:
    xor rax, rax        ; Return NULL
    
.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Unhook a syscall
; Input: rcx = syscall name
; Output: rax = 0 on success, error code otherwise
unhook_syscall:
    push rbx
    push rcx
    push rdx
    push rsi
    
    ; Save syscall name
    mov rsi, rcx
    
    ; Check if initialized
    cmp byte [hook_active], 0
    je .not_init
    
    ; Find the hook
    ; TODO: Implement hook lookup
    ; For now, this is a placeholder
    
    ; Log the unhook
    lea rcx, [unhook_msg]
    call log_write
    
    xor rax, rax        ; Return success
    jmp .done
    
.not_init:
    mov rax, -1         ; Not initialized
    jmp .done
    
.not_hooked:
    mov rax, -4         ; Syscall not hooked
    
.done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Unhook all syscalls
; Input: none
; Output: rax = 0 on success, error code otherwise
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
    lea rcx, [unhook_all_msg]
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

section '.data' data readable writeable

ntdll_base dq 0

; Log messages
init_msg db 'Syscall interceptor initialized', 0
ntdll_found_msg db 'NTDLL found', 0
hook_msg db 'Syscall hooked', 0
unhook_msg db 'Syscall unhooked', 0
unhook_all_msg db 'All syscalls unhooked', 0 