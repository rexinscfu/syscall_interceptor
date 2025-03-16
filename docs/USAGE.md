# syscall_interceptor Usage Guide

## Overview

The syscall_interceptor library provides a framework for intercepting, monitoring, and modifying system calls on both Linux and Windows platforms. This document describes how to use the library in your own projects.

## Building the Library

### Linux

```bash
cd build
./build_linux.sh
```

This will produce `build/output/libsyscall_interceptor.o`, which you can link with your application.

### Windows

```bash
cd build
build_windows.bat
```

This will produce `build\output\syscall_interceptor.lib`, which you can link with your application.

## API Reference

The library provides both a C API and direct assembly functions.

### C API

Include the header file in your C code:

```c
#include "syscall_interceptor.h"
```

#### Common Functions

```c
int log_init(void);
int log_write(const char* message);
int log_close(void);
```

#### Linux-specific Functions

```c
int hook_init(void);
int hook_syscall(int syscall_number, syscall_handler_t handler);
int unhook_syscall(int syscall_number);
int unhook_all(void);
const char* get_syscall_name(int syscall_number);
int get_syscall_number(const char* name);
```

#### Windows-specific Functions

```c
int hook_init(void);
int hook_syscall(const char* syscall_name, syscall_handler_t handler);
int unhook_syscall(const char* syscall_name);
int unhook_all(void);
const char* get_syscall_name(int syscall_number);
int get_syscall_number(const char* name);
```

### Assembly API

For direct assembly usage, the functions have an underscore prefix:

```
_log_init
_log_write
_log_close
_hook_init
_hook_syscall
_unhook_syscall
_unhook_all
_get_syscall_name
_get_syscall_number
```

## Example Usage

See the `examples` directory for complete examples of using the library on both Linux and Windows, in both C and assembly.

### Basic Usage Pattern (C)

```c
#include "syscall_interceptor.h"

void custom_syscall_handler(void) {
    log_write("Syscall intercepted");
    // Your custom handling code here
}

int main() {
    log_init();
    hook_init();
    
    // Hook a syscall
    hook_syscall(SYSCALL_NUMBER, custom_syscall_handler);
    
    // Your application code here
    
    // Unhook when done
    unhook_syscall(SYSCALL_NUMBER);
    unhook_all();
    log_close();
    
    return 0;
}
```

## Limitations

- The library requires root/administrator privileges to hook syscalls
- Not all syscalls can be safely hooked
- Hooking certain syscalls may cause system instability
- The library is not thread-safe

## Troubleshooting

If you encounter issues:

1. Check the log file (`syscall_interceptor.log`) for error messages
2. Ensure you have the necessary privileges
3. Try hooking a different syscall
4. Check for conflicts with other hooking libraries

## License

This library is provided under the MIT License. See the LICENSE file for details. 