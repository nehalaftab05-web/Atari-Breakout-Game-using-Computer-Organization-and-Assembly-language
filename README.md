# Atari-Breakout-Game-using-Computer-Organization-and-Assembly-language
# 🕹️ Atari Breakout — x86 Assembly

> A fully playable recreation of the classic Atari Breakout arcade game, built entirely in x86 Assembly Language with real-time keyboard input, hardware interrupt-driven rendering, and a complete lives and scoring system.

**Course:** Computer Organization & Assembly Language (COAL) — Semester 3  
**University:** FAST-NUCES, CFD Campus  
**Instructor:** Ma'am Gul-e-Zehra  
**Team:** Nehal Aftab (24F-0518) · Minahil Younas (24F-0522)

---

## 🎮 Gameplay

Control a paddle at the bottom of the screen to keep the ball alive. Break all the bricks at the top to win — miss the ball and lose a life. Lose all lives and it's game over.

```
╔══════════════════════════════════╗
║  ██ ██ ██ ██ ██ ██ ██ ██ ██ ██  ║   ← Bricks (each worth 1 point)
║  ██ ██ ██ ██ ██ ██ ██ ██ ██ ██  ║
║                                  ║
║            ●                     ║   ← Ball
║                                  ║
║           ═════                  ║   ← Paddle (← → to move)
╚══════════════════════════════════╝
  Score: 12        Lives: ♥ ♥ ♥
```

---

## ✨ Features

| Feature | Details |
|---|---|
| **Real-time paddle control** | Left/right arrow keys via keyboard interrupt |
| **Physics-based ball** | Bounces off walls, paddle, and bricks with direction inversion |
| **Brick destruction** | Bricks disappear on hit; score increments immediately |
| **Lives system** | Ball falling past the paddle deducts one life |
| **Win condition** | All bricks destroyed → game complete |
| **Lose condition** | All lives exhausted → game over |
| **Screen rendering** | Full display drawn and updated via video interrupt |

---

## 🔧 Interrupt Reference

This project uses three DOS/BIOS interrupts for all hardware interaction — no libraries or abstractions.

### `INT 09h` — Keyboard Interrupt
Handles real-time keyboard scanning during gameplay. Detects left and right arrow key presses to move the paddle without blocking the game loop.

### `INT 10h` — Video (BIOS) Interrupt
Drives all screen output, including:
- Clearing the screen on startup and game reset
- Drawing and erasing the ball, paddle, and bricks each frame
- Updating the display in real time during gameplay

### `INT 21h` — DOS Services Interrupt
Handles program-level I/O:
- Displaying welcome, game over, and win messages
- Safe program termination on exit

---

## 🏗️ Architecture & Game Logic

### Initialization
```
Program Start
    └── Clear screen (INT 10h)
    └── Display welcome message (INT 21h)
    └── Draw bricks, paddle, ball
    └── Set initial ball direction, score = 0, lives = 3
```

### Main Game Loop
```
Game Loop (runs continuously)
    │
    ├── Read keyboard input (INT 09h)
    │       └── Move paddle left / right
    │
    ├── Move ball one step in current direction
    │
    ├── Collision detection
    │       ├── Wall hit      → invert horizontal direction
    │       ├── Ceiling hit   → invert vertical direction
    │       ├── Paddle hit    → invert vertical direction (ball goes up)
    │       └── Brick hit     → erase brick, score++, invert direction
    │
    ├── Bottom of screen reached?
    │       └── YES → lives--, reset ball position
    │
    ├── Lives == 0?     → Game Over (INT 21h message, exit)
    └── Bricks == 0?    → You Win! (INT 21h message, exit)
```

---

## 📐 Scoring & Lives

**Scoring**
- Each brick is worth **1 point**
- Score increments immediately on brick collision
- Final score = total bricks destroyed

**Lives**
- Player starts with **3 lives**
- One life is lost each time the ball passes the paddle and hits the bottom
- Game continues as long as at least 1 life remains

**End Conditions**

| Condition | Result |
|---|---|
| All bricks destroyed | 🏆 Victory screen |
| All lives lost | 💀 Game Over screen |

---

## 🖥️ Running the Game

### Requirements
- **DOSBox** (recommended) or any x86 DOS emulator
- **MASM** or **TASM** assembler

### Assemble & Link (MASM)

```bash
masm breakout.asm;
link breakout.obj;
breakout.exe
```

### Assemble & Link (TASM)

```bash
tasm breakout.asm
tlink breakout.obj
breakout.exe
```

### Running in DOSBox

```bash
# Mount your project directory
mount c C:\path\to\project
c:
breakout.exe
```

### Controls

| Key | Action |
|---|---|
| `←` Left Arrow | Move paddle left |
| `→` Right Arrow | Move paddle right |
| `Q` | Quit game |

---

## 📂 File Structure

```
atari-breakout-asm/
│
├── breakout.asm        # Main source file (all game logic)
├── breakout.obj        # Compiled object file (generated)
├── breakout.exe        # Executable (generated)
└── README.md
```

> The entire game — initialization, rendering, physics, input handling, and scoring — is contained in a single `.asm` source file.

---

## 🧠 Concepts Demonstrated

| COAL Concept | Implementation |
|---|---|
| **Hardware Interrupts** | INT 09h, INT 10h, INT 21h for I/O and display |
| **Registers** | AX, BX, CX, DX used for coordinates, counters, and parameters |
| **Conditional Jumps** | `JE`, `JNE`, `JL`, `JG` for collision and game-state checks |
| **Loops** | `LOOP` instruction for brick rendering and game cycle |
| **Memory Management** | Variables for ball position, direction, score, and lives |
| **Procedures** | Modular routines for drawing, collision, and input handling |
| **Screen Memory** | Direct character output via INT 10h for real-time rendering |

---

## 📝 Learning Outcomes

- Writing real-time interactive applications at the hardware level using interrupts
- Managing game state (ball position, direction, lives, score) entirely through registers and memory variables
- Implementing collision detection logic using conditional branching in assembly
- Structuring a non-trivial program in assembly using procedures and a main loop
- Understanding how high-level game concepts (physics, rendering, input) map to low-level instructions

---

## 📄 License

Academic project submitted for COAL, FAST-NUCES CFD, Semester 3.  
Not licensed for redistribution or commercial use.
