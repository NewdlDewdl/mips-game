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

## Getting Started

### Prerequisites
- MIPS simulator: **MARS** (recommended) or **QtSPIM**
- Download MARS: http://courses.missouristate.edu/kenvollmar/mars/

### Installation & Setup

#### Using MARS (Recommended)
1. Download and launch MARS.jar
2. Navigate to `Settings → Memory Configuration` and ensure you have sufficient memory allocated
3. Open all `.asm` files in the project:
   - `File → Open` → Select all 8 `.asm` files
   - Or drag and drop all files into MARS
4. Verify all files are loaded in the left panel

#### Using QtSPIM
1. Launch QtSPIM
2. Load each `.asm` file individually using `File → Load File`
3. Files must be loaded in dependency order (start with `main.asm`)

### Running the Game

1. **Assemble the program**:
   - MARS: Click the wrench icon (🔧) or press F3
   - QtSPIM: Files auto-assemble on load
2. **Start execution**:
   - MARS: Click the play button (▶️) or press F5
   - QtSPIM: `Simulator → Run`
3. The game will start at the `main` label (default entry point)
4. Follow the on-screen prompts to solve each puzzle
5. Input validation will re-prompt on invalid entries

## Gameplay Walkthrough

### Objective
Convert numbers between binary and decimal across 10 progressively challenging levels. Each correct answer earns points!

### How to Play
1. **Level Start**: You'll see a puzzle board showing your progress (10 puzzles per game)
2. **Puzzle Types**:
   - **Binary → Decimal**: Convert an 8-bit binary number to decimal (e.g., `10110011` → `179`)
   - **Decimal → Binary**: Convert a decimal number to 8-bit binary (e.g., `179` → `10110011`)
3. **Input Format**:
   - Decimal answers: Enter the number directly (e.g., `179`)
   - Binary answers: Enter 8 digits without spaces (e.g., `10110011`)
4. **Feedback**:
   - ✓ = Correct answer
   - ✗ = Incorrect answer
5. **Scoring**: Cumulative points displayed after each level
6. **Replay**: After completing all 10 levels, choose to play again or quit

## Troubleshooting

### Common Issues

**Problem**: "Label not found" errors during assembly
- **Solution**: Ensure all 8 `.asm` files are loaded before assembling
- In MARS, verify all files appear in the left panel

**Problem**: Unicode glyphs (✓/✗) not displaying correctly
- **Solution**: Update the message strings in `main.asm` and `drawboard.asm` to use ASCII alternatives (e.g., `[X]` and `[O]`)

**Problem**: Game doesn't start or crashes immediately
- **Solution**: Check that execution starts at the `main` label
- Verify memory configuration has sufficient space allocated

**Problem**: Random numbers seem non-random
- **Solution**: The PRNG uses syscall 30 for seeding; if your emulator doesn't support it, the game uses a default seed. This is expected behavior.

**Problem**: Console output is garbled
- **Solution**: The `clear_screen` function prints newlines to simulate clearing. If this causes issues, modify the newline count in `drawboard.asm`

## Technical Notes

- The renderer uses ASCII characters and Unicode glyphs (✓/✗). If your terminal emulator does not support these glyphs you can update the message strings in `main.asm` and `drawboard.asm`.
- `clear_screen` prints a sequence of newline characters to simulate clearing the console.
- Random seed initialization uses syscall 30; emulators that do not implement it will fall back to a default seed.
- Puzzle data is stored in an 8-byte structure per entry and updates as the player progresses.

## Contributing

Found a bug or have a feature idea? Open an issue on GitHub!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
