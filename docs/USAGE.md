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

### Common Functions

#### `log_init`

Initializes the logging system.

**Input:** None
**Output:** 0 on success, error code otherwise

#### `log_write`

Writes a message to the log.

**Input:** Pointer to null-terminated string
**Output:** 0 on success, error code otherwise

#### `log_close`

Closes the logging system.

**Input:** None
**Output:** 0 on success, error code otherwise

### Linux-specific Functions

#### `hook_init`

Initializes the syscall hooking system.

**Input:** None
**Output:** 0 on success, error code otherwise

#### `hook_syscall`

Hooks a syscall.

**Input:** 
- Syscall number
- New handler address

**Output:** 0 on success, error code otherwise

#### `unhook_syscall`

Unhooks a syscall.

**Input:** Syscall number
**Output:** 0 on success, error code otherwise

#### `unhook_all`

Unhooks all syscalls.

**Input:** None
**Output:** 0 on success, error code otherwise

### Windows-specific Functions

#### `hook_init`

Initializes the syscall hooking system.

**Input:** None
**Output:** 0 on success, error code otherwise

#### `hook_syscall`

Hooks a syscall.

**Input:** 
- Syscall name
- New handler address

**Output:** 0 on success, error code otherwise

#### `unhook_syscall`

Unhooks a syscall.

**Input:** Syscall name
**Output:** 0 on success, error code otherwise

#### `unhook_all`

Unhooks all syscalls.

**Input:** None
**Output:** 0 on success, error code otherwise

## Example Usage

See the `examples` directory for complete examples of using the library on both Linux and Windows.

### Basic Usage Pattern

1. Initialize the logging system
2. Initialize the syscall hooking system
3. Hook the desired syscalls
4. Use the system normally - your hooks will be called
5. Unhook syscalls when done
6. Close the logging system

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