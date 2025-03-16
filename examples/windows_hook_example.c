#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include "../include/syscall_interceptor.h"

void custom_NtWriteFile_handler(void) {
    log_write("NtWriteFile syscall intercepted from C");
}

int main() {
    HANDLE hFile;
    DWORD bytesWritten;
    const char* message = "Testing NtWriteFile syscall\n";
    
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
    
    if (hook_syscall("NtWriteFile", custom_NtWriteFile_handler) != 0) {
        log_write("Failed to hook NtWriteFile syscall");
        log_close();
        return 1;
    }
    
    hFile = GetStdHandle(STD_OUTPUT_HANDLE);
    WriteFile(hFile, message, strlen(message), &bytesWritten, NULL);
    
    unhook_syscall("NtWriteFile");
    unhook_all();
    
    log_write("Syscall hook example completed");
    log_close();
    
    return 0;
} 