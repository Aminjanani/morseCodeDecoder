# Morse Code Decoder (VHDL)

## Project Overview
This project implements a **Morse Code Decoder** using **VHDL** on an FPGA. The system receives Morse code through a single digital input (push button), distinguishes between **dot** and **dash** based on press duration, builds a fixed-length binary pattern, and decodes it into **alphanumeric characters (A–Z, 0–9)** using a lookup table (LUT).

The project is primarily designed as an **educational digital design exercise**, demonstrating finite state machines (FSMs), timing analysis, and hardware-oriented coding practices in VHDL.

---

## Objectives
- Decode Morse code symbols from a single button input  
- Differentiate dot and dash using timing thresholds  
- Represent each character as an 8-bit pattern  
- Match patterns against a predefined LUT (36 entries)  
- Output the decoded character index  
- Provide LED-based debugging and state visualization  

---

## Why Morse Code?
Morse code is a compact and timing-based encoding scheme, making it ideal for:
- Demonstrating **time-based digital logic**
- Practicing **FSM-based control systems**
- Using counters, registers, and pattern matching
- Bridging human input with digital hardware

---

## System Architecture

### Main Components
- **Input Interface**: Push button (pressed / released)
- **Timer / Counter**: Measures press duration and idle time
- **Finite State Machine (FSM)**: Controls system behavior
- **Shift Register (8-bit)**: Stores dot/dash pattern
- **Lookup Table (LUT)**: Stores Morse patterns for A–Z and 0–9
- **Matcher Logic**: Compares input pattern with LUT entries
- **Output & Debug LEDs**: Visual feedback

---

## Morse Representation
- **Dot (.)** → short press → binary `0`
- **Dash (–)** → long press → binary `1`
- Each character is stored in an **8-bit pattern**
- Unused bits are treated as **don’t care**

Example:
```
A (.-)  → 01------
```

---

## Timing Parameters
(Example values based on a 100 MHz clock)

| Parameter   | Purpose                   | Value      |
|------------|---------------------------|------------|
| DOT_TIME   | Minimum dot duration      | 20 cycles  |
| DASH_TIME  | Minimum dash duration     | 40 cycles  |
| IDLE_TIME  | End-of-character gap      | 80 cycles  |

These thresholds allow the system to reliably distinguish dots, dashes, and character boundaries.

---

## Finite State Machine (FSM)

### States
1. **IDLE** – Waiting for button press or character timeout  
2. **PRESSED** – Button held, duration counter active  
3. **RELEASED** – Button released, dot/dash classification  
4. **PROCESSING** – Pattern matching and character decoding  

### State Encoding (for debugging)
| State        | Code |
|--------------|------|
| IDLE         | 00   |
| PRESSED     | 10   |
| RELEASED    | 01   |
| PROCESSING  | 11   |

---

## FSM Transitions
- `IDLE → PRESSED` when button is pressed
- `PRESSED → RELEASED` when button is released
- `RELEASED → IDLE` after storing dot/dash
- `IDLE → PROCESSING` when idle timeout expires
- `RELEASED → PROCESSING` when 8 bits are collected

---

## Pattern Construction
- An 8-bit shift register (`char_pattern`) is used
- A pointer (`char_index`) tracks the next bit position
- On each valid press:
  - Dot → write `0`
  - Dash → write `1`
- Pointer decrements after each symbol

---

## Lookup Table (LUT)
- Contains **36 entries**:
  - A–Z → indices 0–25
  - 0–9 → indices 26–35
- Each entry is an 8-bit Morse pattern
- Pattern matching allows **don’t-care bits** for unused positions

---

## Decoding Process
1. Receive button presses
2. Measure press duration
3. Classify dot or dash
4. Build 8-bit pattern
5. Detect character completion
6. Compare pattern against LUT
7. Output decoded character index

---

## Debug and Outputs
- **LED Indicators**:
  - Dot detected
  - Dash detected
  - Idle / separator
- **State Identifier LEDs**:
  - Visualize current FSM state

These outputs simplify testing and debugging on real hardware.

---

## VHDL Design Style
- **Behavioral modeling** for FSM and logic
- **Synchronous processes** for state and counters
- **Combinational processes** for next-state and outputs
- Clear separation of:
  - Timer logic
  - FSM and pattern building
  - Output/state indicators

---

## Educational Value
This project demonstrates:
- Practical FSM design
- Timing-based input decoding
- Clean VHDL coding style
- Hardware debugging techniques
- Mapping abstract protocols to digital logic

It serves as a strong foundation for more advanced designs such as UART decoders, audio-based Morse receivers, or display-integrated systems.

---

## Possible Extensions
- ASCII output instead of index
- 7-segment or LCD display
- Audio or optical Morse input
- Adjustable timing parameters
- Word-level decoding with character buffering

---

## Conclusion
The Morse Code Decoder project is a compact yet complete digital system that combines **timing analysis, FSM control, and pattern matching**. It is well-suited for FPGA-based learning and demonstrates core concepts required for real-world digital hardware design.