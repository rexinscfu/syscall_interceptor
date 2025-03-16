#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/syscall.h>
#include "../include/syscall_interceptor.h"

void custom_write_handler(void) {
    log_write("Write syscall intercepted from C");
    
    syscall(SYS_write, 1, "This message was intercepted\n", 29);
}

int main() {
    if (log_init() != 0) {
        fprintf(stderr, "Failed to initialize logger\n");
        return 1;
    }
    
    log_write("Starting syscall hook example from C");
    
    if (hook_init() != 0) {
        log_write("Failed to initialize syscall hooking");
        log_close();
        return 1;
    }
    
    if (hook_syscall(SYS_write, custom_write_handler) != 0) {
        log_write("Failed to hook write syscall");
        log_close();
        return 1;
    }
    
    write(1, "Testing write syscall\n", 22);
    
    unhook_syscall(SYS_write);
    unhook_all();
    
    log_write("Syscall hook example completed");
    log_close();
    
    return 0;
} 