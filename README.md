# PIC12F675 Assembly Exercises

An annotated collection of embedded-systems exercises written in assembly for the **Microchip PIC12F675**. They were developed as part of an undergraduate microcontrollers course and are kept here as a compact portfolio of low-level programming work.

The repository emphasizes direct use of the device peripherals: GPIO, interrupts, timers, ADC, EEPROM, comparator, watchdog timer, and a software I²C bus.

## Highlights

- Interrupt-driven timing and state-based control
- ADC acquisition, averaging, and non-volatile EEPROM storage
- Software I²C master and slave communication
- Comparator-based voltage monitoring and PWM-style LED dimming
- Low-power operation using `SLEEP` and the watchdog timer
- Integer arithmetic implemented without a hardware divider

## Projects

| Source file | Demonstrates |
| --- | --- |
| `Semaforo.ASM` | Two-way traffic-light controller driven by timer interrupts |
| `Dimmer_comparador.ASM` | Comparator thresholds mapped to LED duty cycles |
| `ProtocoloI2C.ASM` | Bit-banged I²C protocol implementation |
| `EscravoDoBarramento.ASM` | Bus-slave behavior and voltage-threshold monitoring |
| `SistemaAntiFalhasVersion3648273.ASM` | Fault-monitoring logic using comparator, Timer1, EEPROM, and watchdog |
| `ConverADMediaEEPROM.ASM` | ADC sampling, averaging, and EEPROM persistence |
| `MedidorDeTau.ASM` | RC time-constant measurement workflow |
| `MedidorEconomico.ASM` | Low-power measurement experiment using `SLEEP` and WDT |
| `DivisaoPrecisao1casa.ASM` | Unsigned division with one decimal-place precision |
| `encontroMenorMaior.ASM` | Finding minimum and maximum values stored in EEPROM |

## Toolchain and target

- **MCU:** Microchip PIC12F675
- **Language:** PIC assembly (`.ASM`)
- **Assembler:** MPASM / MPLAB X IDE with the PIC12F675 device include files

Each file is an independent exercise, with its own reset vector, configuration word, and initialization routine. Select one source file at a time when creating an MPLAB project and program the resulting image onto a PIC12F675-compatible setup.

## Notes on the source

I kept the original file names and Portuguese comments from the course. The README is in English to make the project easier to browse for an international audience. Some files began with a template supplied in class; the exercises and peripheral-control routines were then developed as part of the coursework.

## Portfolio context

These are small, self-contained coursework projects rather than a single production firmware project. I am sharing them as a record of the low-level embedded work I did while learning the PIC12F675: configuring registers, working with tight memory limits, and handling interrupts and peripherals directly.

## License

No license is included. The repository contains coursework and class-provided starting material, so please contact the repository owner before reusing the source code.
