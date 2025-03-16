# syscall_interceptor

A low-level system call interception library written in FASM and C.

## Overview

This project provides a framework for intercepting, monitoring, and modifying system calls on both Linux and Windows platforms. It's designed for security researchers, performance analysts, and developers who need to understand or modify application behavior at the system call level.

## Features

- Transparent system call hooking
- Configurable filtering and modification of syscall parameters
- Memory-efficient logging system
- Performance analysis tools
- Visualization of syscall patterns
- CLI and basic GUI interfaces
- C API for easy integration with existing projects

## Building

### Prerequisites

- FASM (Flat Assembler) - version 1.73.30 or newer
- GCC (for Linux builds)
- MSVC (for Windows builds)

### Linux

```bash
cd build
./build_linux.sh
```

### Windows

```bash
cd build
build_windows.bat
```

## Usage

Check the examples directory for usage patterns in both C and assembly.

### C API Example

```c
#include "syscall_interceptor.h"

void custom_write_handler(void) {
    log_write("Write syscall intercepted");
    // Custom handling code
}

int main() {
    log_init();
    hook_init();
    hook_syscall(SYS_write, custom_write_handler);
    
    // Your code here
    
    unhook_syscall(SYS_write);
    unhook_all();
    log_close();
    return 0;
}
```

## License

MIT

## Author

REXIN (rexinscfu) 