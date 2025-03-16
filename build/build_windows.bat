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

REM Link everything
echo [+] Linking...
lib /OUT:"%BUILD_DIR%\syscall_interceptor.lib" "%BUILD_DIR%\logger.obj" "%BUILD_DIR%\hook.obj" "%BUILD_DIR%\syscall_table.obj"

echo [+] Build completed successfully!
echo Output: %BUILD_DIR%\syscall_interceptor.lib

endlocal 