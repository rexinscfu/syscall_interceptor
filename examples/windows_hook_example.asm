; windows_hook_example.asm - Example of syscall hooking on Windows
; REXIN, 2025

format PE64 console

include '../include/syscall_defs.inc'

section '.text' code readable executable

extern _log_init
extern _log_write
extern _log_close
extern _hook_init
extern _hook_syscall
extern _unhook_syscall
extern _unhook_all

; Import necessary Windows functions
section '.idata' import data readable writeable

library kernel32, 'kernel32.dll', \
        msvcrt, 'msvcrt.dll'

import kernel32, \
       ExitProcess, 'ExitProcess', \
       GetStdHandle, 'GetStdHandle', \
       WriteFile, 'WriteFile'

import msvcrt, \
       printf, 'printf'

; Custom NtWriteFile handler
; This will be called instead of the original NtWriteFile syscall
custom_NtWriteFile_handler:
    ; Save registers
    push rax
    push rcx
    push rdx
    push r8
    push r9
    push r10
    push r11
    
    ; Log the NtWriteFile syscall
    lea rcx, [write_msg]
    call _log_write
    
    ; Restore registers
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rax
    
    ; Call original NtWriteFile syscall
    ; In a real implementation, we would call the original handler
    ; For now, we'll just return success
    xor rax, rax        ; Return STATUS_SUCCESS
    
    ret

; Entry point
main:
    ; Initialize logger
    call _log_init
    
    ; Log start message
    lea rcx, [start_msg]
    call _log_write
    
    ; Initialize syscall hooking
    call _hook_init
    test rax, rax
    jnz .error
    
    ; Hook NtWriteFile syscall
    lea rcx, [NtWriteFile_name]
    lea rdx, [custom_NtWriteFile_handler]
    call _hook_syscall
    test rax, rax
    jnz .error
    
    ; Test the hook by writing to stdout
    mov rcx, -11        ; STD_OUTPUT_HANDLE
    call [GetStdHandle]
    
    mov rcx, rax        ; hFile
    lea rdx, [test_msg] ; lpBuffer
    mov r8, test_msg_len ; nNumberOfBytesToWrite
    lea r9, [bytes_written] ; lpNumberOfBytesWritten
    xor eax, eax        ; lpOverlapped = NULL
    push rax
    call [WriteFile]
    
    ; Unhook NtWriteFile syscall
    lea rcx, [NtWriteFile_name]
    call _unhook_syscall
    
    ; Unhook all syscalls
    call _unhook_all
    
    ; Log end message
    lea rcx, [end_msg]
    call _log_write
    
    ; Close logger
    call _log_close
    
    ; Exit
    xor ecx, ecx        ; status = 0
    call [ExitProcess]
    
.error:
    ; Log error message
    lea rcx, [error_msg]
    call _log_write
    
    ; Close logger
    call _log_close
    
    ; Exit with error
    mov ecx, 1          ; status = 1
    call [ExitProcess]

section '.data' data readable writeable

; Messages
start_msg db 'Starting syscall hook example', 0
write_msg db 'NtWriteFile syscall intercepted', 0
test_msg db 'This is a test message', 13, 10
test_msg_len = $ - test_msg
end_msg db 'Syscall hook example completed', 0
error_msg db 'Error in syscall hook example', 0
NtWriteFile_name db 'NtWriteFile', 0

; Variables
bytes_written dd 0 