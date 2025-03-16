; syscall_defs.inc - Syscall definitions for syscall_interceptor
; REXIN, 2025

; Maximum syscall number
MAX_SYSCALL_NR equ 500

; Linux syscall numbers
SYS_read equ 0
SYS_write equ 1
SYS_open equ 2
SYS_close equ 3
SYS_stat equ 4
SYS_fstat equ 5
SYS_lstat equ 6
SYS_poll equ 7
SYS_lseek equ 8
SYS_mmap equ 9
SYS_mprotect equ 10
SYS_munmap equ 11
SYS_brk equ 12
SYS_rt_sigaction equ 13
SYS_rt_sigprocmask equ 14
SYS_rt_sigreturn equ 15
SYS_ioctl equ 16
SYS_pread64 equ 17
SYS_pwrite64 equ 18
SYS_readv equ 19
SYS_writev equ 20
SYS_access equ 21
SYS_pipe equ 22
SYS_select equ 23
SYS_sched_yield equ 24
SYS_mremap equ 25
SYS_msync equ 26
SYS_mincore equ 27
SYS_madvise equ 28
SYS_shmget equ 29
SYS_shmat equ 30
; ... more syscalls would be defined here

; Windows syscall numbers
; Note: Windows syscall numbers can change between Windows versions
; These are example values and would need to be determined at runtime
WIN_NtCreateFile equ 0x55
WIN_NtOpenFile equ 0x33
WIN_NtReadFile equ 0x06
WIN_NtWriteFile equ 0x08
WIN_NtClose equ 0x0C
WIN_NtDeviceIoControlFile equ 0x07
WIN_NtQueryInformationFile equ 0x0B
WIN_NtSetInformationFile equ 0x0D
WIN_NtQueryDirectoryFile equ 0x0E
WIN_NtCreateSection equ 0x4A
