# syscall_interceptor

A low-level system call interception library written in FASM.

## Overview

This project provides a framework for intercepting, monitoring, and modifying system calls on both Linux and Windows platforms. It's designed for security researchers, performance analysts, and developers who need to understand or modify application behavior at the system call level.

## Features (Planned)

- Transparent system call hooking
- Configurable filtering and modification of syscall parameters
- Memory-efficient logging system
- Performance analysis tools
- Visualization of syscall patterns
- CLI and basic GUI interfaces

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

Check the examples directory for usage patterns.

## License

MIT

## Author

rexinscfu (REXIN) 