#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../include/syscall_interceptor.h"

extern int _log_init(void);
extern int _log_write(const char* message);
extern int _log_close(void);
extern int _hook_init(void);
extern int _hook_syscall(int syscall_number, syscall_handler_t handler);
extern int _unhook_syscall(int syscall_number);
extern int _unhook_all(void);
extern const char* _get_syscall_name(int syscall_number);
extern int _get_syscall_number(const char* name);

int log_init(void) {
    return _log_init();
}

int log_write(const char* message) {
    return _log_write(message);
}

int log_close(void) {
    return _log_close();
}

int hook_init(void) {
    return _hook_init();
}

int hook_syscall(int syscall_number, syscall_handler_t handler) {
    return _hook_syscall(syscall_number, handler);
}

int unhook_syscall(int syscall_number) {
    return _unhook_syscall(syscall_number);
}

int unhook_all(void) {
    return _unhook_all();
}

const char* get_syscall_name(int syscall_number) {
    return _get_syscall_name(syscall_number);
}

int get_syscall_number(const char* name) {
    return _get_syscall_number(name);
} 