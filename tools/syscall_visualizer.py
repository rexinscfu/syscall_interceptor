#!/usr/bin/env python3
# syscall_visualizer.py - Visualize syscall patterns from log files
# REXIN, 2025

import sys
import re
import matplotlib.pyplot as plt
from collections import Counter

def parse_log(log_file):
    """Parse the syscall interceptor log file."""
    syscalls = []
    pattern = re.compile(r'Syscall intercepted: (\w+)')
    
    try:
        with open(log_file, 'r') as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    syscalls.append(match.group(1))
    except FileNotFoundError:
        print(f"Error: Log file '{log_file}' not found.")
        sys.exit(1)
    
    return syscalls

def visualize_syscalls(syscalls):
    """Create visualizations of syscall patterns."""
    if not syscalls:
        print("No syscalls found in the log file.")
        return
    
    # Count syscall occurrences
    counter = Counter(syscalls)
    
    # Create bar chart
    plt.figure(figsize=(12, 6))
    plt.bar(counter.keys(), counter.values())
    plt.title('Syscall Frequency')
    plt.xlabel('Syscall')
    plt.ylabel('Count')
    plt.xticks(rotation=45)
    plt.tight_layout()
    
    # Save the chart
    plt.savefig('syscall_frequency.png')
    print("Visualization saved as 'syscall_frequency.png'")

def main():
    if len(sys.argv) != 2:
        print("Usage: syscall_visualizer.py <log_file>")
        sys.exit(1)
    
    log_file = sys.argv[1]
    syscalls = parse_log(log_file)
    visualize_syscalls(syscalls)

if __name__ == "__main__":
    main() 