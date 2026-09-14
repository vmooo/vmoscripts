#!/usr/bin/env python3
"""
Random ticket trainer.

Reads lines from a file given as a command-line argument.
Prints one random line each time the user presses Enter,
until all lines have been shown.
"""

import sys
import random
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file_path>", file=sys.stderr)
        return 1

    file_path = Path(sys.argv[1])

    if not file_path.is_file():
        print(f"Error: file not found: {file_path}", file=sys.stderr)
        return 1

    try:
        with file_path.open("r", encoding="utf-8") as f:
            lines = [line.rstrip("\n") for line in f if line.strip()]
    except OSError as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        return 1

    if not lines:
        print("Error: the file is empty.", file=sys.stderr)
        return 1

    random.shuffle(lines)

    total = len(lines)
    print(f"Loaded {total} lines. ")
    print("Press Enter to show the next one (Ctrl+C to quit).\n")

    try:
        for i, line in enumerate(lines, start=1):
            input(f"[{i}/{total}] Press Enter... ")
            print(f"\n>>> {line}\n")
    except (KeyboardInterrupt, EOFError):
        print("\nInterrupted by user.")

    print("All lines have been shown.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
