; syscall_table.asm - Windows syscall table definitions
; REXIN, 2025

format PE64 DLL

include '../include/syscall_defs.inc'

section '.text' code readable executable

public get_syscall_name
public get_syscall_number

; Get syscall name by number
; Input: rcx = syscall number
; Output: rax = pointer to syscall name or 0 if not found
get_syscall_name:
    push rbx
    push rcx
    
    ; Check if syscall number is valid
    cmp rcx, MAX_SYSCALL_NR
    jae .not_found
    
    ; Get syscall name
    lea rax, [syscall_names]
    mov rbx, rcx
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
; Input: rcx = pointer to syscall name
; Output: rax = syscall number or -1 if not found
get_syscall_number:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Save syscall name pointer
    mov rsi, rcx
    
    ; Iterate through syscall names
    xor rbx, rbx        ; syscall number
    
.loop:
    ; Check if we've reached the end
    cmp rbx, MAX_SYSCALL_NR
    jae .not_found
    
    ; Get syscall name
    lea rax, [syscall_names]
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

section '.data' data readable writeable

; Syscall names table
syscall_names:
    dq sys_NtCreateFile_name
    dq sys_NtOpenFile_name
    dq sys_NtReadFile_name
    dq sys_NtWriteFile_name
    dq sys_NtClose_name
    dq sys_NtDeviceIoControlFile_name
    dq sys_NtQueryInformationFile_name
    dq sys_NtSetInformationFile_name
    dq sys_NtQueryDirectoryFile_name
    dq sys_NtCreateSection_name
    ; ... more syscalls would be defined here
    
    ; For brevity, we're only including a few syscalls
    ; In a real implementation, all syscalls would be listed
    
    ; Pad the rest with zeros
    times (MAX_SYSCALL_NR - 10) dq 0

; Syscall name strings
sys_NtCreateFile_name db 'NtCreateFile', 0
sys_NtOpenFile_name db 'NtOpenFile', 0
sys_NtReadFile_name db 'NtReadFile', 0
sys_NtWriteFile_name db 'NtWriteFile', 0
sys_NtClose_name db 'NtClose', 0
sys_NtDeviceIoControlFile_name db 'NtDeviceIoControlFile', 0
sys_NtQueryInformationFile_name db 'NtQueryInformationFile', 0
sys_NtSetInformationFile_name db 'NtSetInformationFile', 0
sys_NtQueryDirectoryFile_name db 'NtQueryDirectoryFile', 0
sys_NtCreateSection_name db 'NtCreateSection', 0
; ... more syscall names would be defined here 