@echo off
REM Build script for syscall_interceptor on Windows
REM REXIN, 2025

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set BUILD_DIR=%PROJECT_ROOT%\build\output
set SRC_DIR=%PROJECT_ROOT%\src

echo [*] Building syscall_interceptor for Windows...

REM Check for FASM
where fasm >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Error: FASM not found. Please install FASM (Flat Assembler).
    exit /b 1
)

REM Check for MSVC
where cl >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] Error: MSVC compiler not found. Please run from a Visual Studio command prompt.
    exit /b 1
)

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM Build common components
echo [+] Building common components...
fasm "%SRC_DIR%\common\logger.asm" "%BUILD_DIR%\logger.obj"
if %ERRORLEVEL% neq 0 (
    echo [!] Failed to build logger
    exit /b 1
)

REM Build Windows-specific components
echo [+] Building Windows components...
fasm "%SRC_DIR%\windows\hook.asm" "%BUILD_DIR%\hook.obj"
if %ERRORLEVEL% neq 0 (
    echo [!] Failed to build hook
    exit /b 1
)

fasm "%SRC_DIR%\windows\syscall_table.asm" "%BUILD_DIR%\syscall_table.obj"
if %ERRORLEVEL% neq 0 (
    echo [!] Failed to build syscall_table
    exit /b 1
)

REM Build C wrapper
echo [+] Building C wrapper...
cl /c /Fo"%BUILD_DIR%\wrapper.obj" "%SRC_DIR%\windows\wrapper.c"
if %ERRORLEVEL% neq 0 (
    echo [!] Failed to build C wrapper
    exit /b 1
)

REM Link everything
echo [+] Linking...
lib /OUT:"%BUILD_DIR%\syscall_interceptor.lib" "%BUILD_DIR%\logger.obj" "%BUILD_DIR%\hook.obj" "%BUILD_DIR%\syscall_table.obj" "%BUILD_DIR%\wrapper.obj"

REM Build examples
echo [+] Building examples...
cl /Fe"%BUILD_DIR%\windows_hook_example.exe" "%PROJECT_ROOT%\examples\windows_hook_example.c" "%BUILD_DIR%\syscall_interceptor.lib"
if %ERRORLEVEL% neq 0 (
    echo [!] Failed to build example
    exit /b 1
)

echo [+] Build completed successfully!
echo Output: %BUILD_DIR%\syscall_interceptor.lib
echo Example: %BUILD_DIR%\windows_hook_example.exe

endlocal 