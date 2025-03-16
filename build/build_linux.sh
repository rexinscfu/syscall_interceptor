#!/bin/bash

# Build script for syscall_interceptor on Linux
# REXIN, 2025

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build/output"
SRC_DIR="$PROJECT_ROOT/src"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building syscall_interceptor for Linux...${NC}"

# Check for FASM
if ! command -v fasm &> /dev/null; then
    echo -e "${RED}Error: FASM not found. Please install FASM (Flat Assembler).${NC}"
    exit 1
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Build common components
echo -e "${GREEN}Building common components...${NC}"
fasm "$SRC_DIR/common/logger.asm" "$BUILD_DIR/logger.o" || { echo -e "${RED}Failed to build logger${NC}"; exit 1; }

# Build Linux-specific components
echo -e "${GREEN}Building Linux components...${NC}"
fasm "$SRC_DIR/linux/hook.asm" "$BUILD_DIR/hook.o" || { echo -e "${RED}Failed to build hook${NC}"; exit 1; }
fasm "$SRC_DIR/linux/syscall_table.asm" "$BUILD_DIR/syscall_table.o" || { echo -e "${RED}Failed to build syscall_table${NC}"; exit 1; }

# Link everything
echo -e "${GREEN}Linking...${NC}"
ld -r "$BUILD_DIR/logger.o" "$BUILD_DIR/hook.o" "$BUILD_DIR/syscall_table.o" -o "$BUILD_DIR/libsyscall_interceptor.o"

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "Output: $BUILD_DIR/libsyscall_interceptor.o" 