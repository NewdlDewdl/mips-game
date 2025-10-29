# MIPS Binary Game

This project implements a console-based binary conversion puzzle game in MIPS assembly. Players progress through 10 levels of mixed binary→decimal and decimal→binary challenges, earning points for every completed level.

## Features

- Random puzzle generation with an LCG-based PRNG
- Full-screen board rendering that tracks puzzle progress
- Input validation for decimal and 8-bit binary answers
- Level-based scoring with cumulative totals
- Replay support without restarting the emulator

## Project Structure

| File | Description |
| --- | --- |
| `main.asm` | Entry point, game loop, replay handling, and global data |
| `random.asm` | Linear congruential generator for repeatable randomness |
| `puzzle.asm` | Puzzle storage helpers and generation routines |
| `drawboard.asm` | Text-mode board renderer and screen clearing |
| `input.asm` | Player prompt and input validation logic |
| `validation.asm` | Conversion helpers and puzzle answer checking |
| `score.asm` | Score calculation utilities |
| `utils.asm` | Basic I/O helpers used throughout the game |

The game keeps puzzle data in an 8-byte structure per entry and updates puzzle status as the player progresses through each level.

## Running the Game

1. Open the project in a MIPS simulator such as **MARS** or **QtSPIM**.
2. Load all `.asm` files into the simulator. In MARS you can use `File → Open` and select multiple files, or use the `Assemble` button after adding them to the current project.
3. Assemble the program to resolve all cross-module labels.
4. Start execution at the `main` label (the default entry point).
5. Follow the on-screen prompts to solve each puzzle. Input validation will re-prompt on invalid entries.

## Notes

- The renderer uses ASCII characters and Unicode glyphs (✓/✗). If your terminal emulator does not support these glyphs you can update the message strings in `main.asm` and `drawboard.asm`.
- `clear_screen` prints a sequence of newline characters to simulate clearing the console.
- Random seed initialization uses syscall 30; emulators that do not implement it will fall back to a default seed.
