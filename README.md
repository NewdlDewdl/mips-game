# MIPS Binary Game

This project implements a console-based binary/decimal conversion game in MIPS assembly. The game spans ten levels, gradually increasing the number of simultaneous conversion puzzles. Players must answer all puzzles on the current level correctly to advance; a single mistake ends the run.

## Building and Running

The sources target the MARS/SPIM simulator environment.

1. Assemble all modules (order does not matter as long as the linker combines them):
   ```
   spim -file main.asm \
        -file random.asm \
        -file puzzle.asm \
        -file drawboard.asm \
        -file input.asm \
        -file validation.asm \
        -file score.asm \
        -file utils.asm
   ```
   Any MIPS toolchain capable of linking multiple assembly modules can be used. When using MARS, load every file into the IDE and assemble them together.

2. Run the program. A title message appears, followed by the interactive board display for level one. Input prompts indicate whether to enter decimal values or binary strings.

## Gameplay Flow

- Levels 1–10 increase the number of simultaneous puzzles (the current level number equals the count of active puzzles).
- Each puzzle is randomly selected to be either binary-to-decimal or decimal-to-binary.
- Enter decimal answers as integers in the range 0–255.
- Enter binary answers as eight-character strings containing only `0` and `1`.
- Correct answers award points; finishing a level grants a bonus proportional to the level.
- An incorrect response immediately ends the session and shows the correct solution.
- Finishing all ten levels displays the victory message and total score.
- After the game ends, you can choose to play again without restarting the simulator.

## Module Overview

- `main.asm` – Entry point and high-level game loop.
- `random.asm` – Linear congruential pseudo-random number generator.
- `puzzle.asm` – Puzzle storage, generation, and answer verification.
- `drawboard.asm` – ASCII board rendering and screen clearing helpers.
- `input.asm` – Prompt handling and validation-aware user input helpers.
- `validation.asm` – Numeric and binary string validation plus conversions.
- `score.asm` – Level scoring utilities and score accumulation.
- `utils.asm` – Common printing helpers, string utilities, and a simple delay routine.

Feel free to extend the visuals, scoring system, or add new puzzle types to expand the game.
