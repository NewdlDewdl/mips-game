# MIPS Binary Game

This repository contains a modular MIPS assembly implementation of a progressive binary/decimal conversion puzzle game. The game is divided into eight source modules located in `src/`:

| Module | Purpose |
| --- | --- |
| `main.asm` | Entry point, game orchestration, and shared data. |
| `random.asm` | Linear congruential pseudo-random number generator and helpers. |
| `puzzle.asm` | Puzzle generation, storage, and answer evaluation. |
| `drawboard.asm` | ASCII board rendering and screen utilities. |
| `input.asm` | Player input routines with validation and prompting. |
| `validation.asm` | Conversion helpers between binary strings and integers. |
| `score.asm` | Score calculation and output helpers. |
| `utils.asm` | Low-level printing and utility routines. |

## Gameplay Summary

* Ten levels, each containing as many simultaneous puzzles as the current level number.
* Puzzle types alternate between binary-to-decimal and decimal-to-binary conversions.
* Any incorrect answer ends the run; solving every puzzle across all levels wins the game.
* Scores are calculated with a level-based multiplier (50 points per puzzle, plus a level bonus).

The display routines output a board similar to the specification, including puzzle status indicators.

## Building and Running

Assemble all modules together using your preferred MIPS toolchain (e.g., [SPIM](https://spimsimulator.sourceforge.net/) or [QtSpim](http://spimsimulator.sourceforge.net/)). For QtSpim, load every file from the `src/` directory into the same session so that shared labels resolve correctly.

Example QtSpim workflow:

1. Open QtSpim and choose **File → Open** for each file in `src/`.
2. Press **F5** (or click **Run**) to assemble and launch the program.
3. Interact with the console following the prompts.

> **Tip:** The project uses ANSI escape sequences to clear the console. If your simulator does not support them, you can comment out calls to `clear_screen` in `main.asm` and `drawboard.asm` without affecting gameplay.

## Testing Checklist

* Random puzzles vary between runs after seeding with syscall 30.
* Binary and decimal conversions are validated for the 0–255 range.
* The ASCII board updates after each answer and clearly indicates status.
* Score output follows the described formula and is displayed at the end of the run.
