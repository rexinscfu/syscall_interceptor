#ifndef SYSCALL_INTERCEPTOR_H
#define SYSCALL_INTERCEPTOR_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*syscall_handler_t)(void);

int log_init(void);
int log_write(const char* message);
int log_close(void);

#ifdef __linux__
int hook_init(void);
int hook_syscall(int syscall_number, syscall_handler_t handler);
int unhook_syscall(int syscall_number);
int unhook_all(void);
const char* get_syscall_name(int syscall_number);
int get_syscall_number(const char* name);
#elif defined(_WIN32)
int hook_init(void);
int hook_syscall(const char* syscall_name, syscall_handler_t handler);
int unhook_syscall(const char* syscall_name);
int unhook_all(void);
const char* get_syscall_name(int syscall_number);
int get_syscall_number(const char* name);
#endif

#ifdef __cplusplus
}
#endif

#endif /* SYSCALL_INTERCEPTOR_H */ 