# Binary Game for MIPS Assembly

This project implements a 10-level binary-to-decimal conversion game written in MIPS assembly. Players alternate between translating binary numbers to decimal and decimal numbers to 8-bit binary strings. Answer every puzzle on a level correctly to advance—one mistake ends the run.

## Features

- Procedural puzzle generation with a linear congruential PRNG.
- Text-based board renderer that displays each puzzle line, status indicators, and the current score.
- Robust input validation for 0–255 decimal values and fixed-width 8-bit binary strings.
- Modular architecture with separate files for random generation, puzzle management, drawing, input, validation, scoring, and utilities.
- Replay loop that lets players immediately try again after a game over.

## File Layout

```
src/
  main.asm         # Entry point and game orchestration
  random.asm       # Pseudo-random number generator
  puzzle.asm       # Puzzle storage and access helpers
  drawboard.asm    # Board rendering helpers
  input.asm        # User input and validation prompts
  validation.asm   # Shared validation routines
  score.asm        # Score calculation and display
  utils.asm        # Common print/string helpers and delay
```

## Running the Game

1. Open the project in an emulator such as [MARS](http://courses.missouristate.edu/kenvollmar/mars/) or [QtSPIM](https://sourceforge.net/projects/spimsimulator/).
2. Assemble **all** files in the `src/` directory. In MARS you can use `Run → Assemble and Run` after adding every file to the project.
3. Run the program. Follow the on-screen prompts to enter decimal or binary answers depending on the puzzle type.
4. After finishing (or losing) a game, choose whether to play again when prompted.

> **Tip:** The `delay` helper uses a simple busy-wait loop; if you find the level transition pause too short or too long, adjust the constant inside `delay_level_transition` in `main.asm`.

## License

This project is provided for educational purposes.
