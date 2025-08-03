# Ltmz

8-bit CP/M Text Adventure Compiler

Also MS-DOS Text Adventure Compiler

This project is an exploration of what it would take to create a program for an 8-bit computer from scratch. Specifically, the goal is to design a custom programming language and create a compiler that transforms source code written in this language into a binary executable that can run on a CP/M based 8-bit computer.

The final binary can be executed on many CP/M systems with a Z80 processor. This project also includes a text adventure games written using the custom programming language as examples.

Update: Only for CP/M initially, now the project has been extended with a compiler outputting MS-DOS binaries too.

## Features

* Custom Programming Language: A simple programming language designed specifically for this project. The language provides enough functionality to create simple text adventure games.

* Compiler: A program that runs on a modern PC and compiles source code written in the custom language into a binary executable. The CP/M executable can run on an 8-bit CP/M system with a Z80 processor. The MS-DOS executable can run on a system with an i8088 processor.

* Text Adventure Examples: Sample games are provided to demonstrate the capabilities of the language.

## Limitations

* The CP/M compiler is limited to generating code that runs on CP/M with a Z80 processor. It does not support CP/M on other CPUs.

* The generated CP/M binary uses Z80 instruction Rst30h. The binary is incompatible with systems that already use the same instruction for other purposes.

* The project focuses on creating a basic text adventure game. The language is not designed for building general-purpose applications.

* The language and compiler only support a subset of features that would be necessary to create a simple game. Complex functionalities are beyond the scope of this project.

* The compiler implementation is minimal and does not perform error checking. If the compiled code contains errors, the compiler will exit with an internal error, and the user may not be able to identify the issue.

* There is no documentation other than this Readme file. The language is defined implicitly by the compiler's source code.

## Project structure

* Ltmz.tcl - Contains the code for the compiler that transforms the source code into a CP/M binary executable.

* Ltmz-dos.tcl - Contains the code for the compiler that transforms the source code into an MS-DOS binary executable.

* game_jhcon.txt - Contains the source code of a sample text adventure game written in the custom language. The game is in Czech, with text output and command inputs expected in Czech. It was created by dex and is not covered by the same license as the rest of this repository.

* game_tencave.txt - Contains the source code for a sample text adventure game in English. Originally released as Tenliner Cave Adventure (2016) by Einar Saukas for ZX81, it was modified by me for the custom language. The game source is not covered by the same license as the rest of this repository.

* LICENSE - The license for this project (MIT License), covering the files written by the repository author.

* Readme.md - This document.

## Getting started

### Prerequisites

To compile programs with this tool, you need a Tcl installed, version 8.6 or newer. Tcl (Tool Command Language) is a versatile and cross-platform scripting laguage supported on a wide array of operating systems.

You need also a CP/M-compatible 8-bit system with a Z80 processor (or an emulator) to run the game. The example games were tested on the Sharp MZ-800 computer, the same binaries may work on other systems too.

### Example Usage

An example of a text adventure game written in the custom language is provided in file game_jhcon.txt. To compile this game on Windows:

```
cd ltmz
tclsh Ltmz.tcl game_jhcon.txt JHCON.COM
```

The resulting binary can be loaded onto a CP/M system to play the game.

## License

The files in this repository are licensed under the MIT License, except for `game_jhcon.txt` (created by user "dex") and `game_tencave.txt` (based on work by Einar Saukas), which are not covered by this license.

## Acknowledgements

* Special thanks to the CP/M community for their documentation and the emulators they have made available for retro computing.

* The example text adventure game Jhcon was originally created by "dex" and shared as open [source](https://oldcomp.cz/viewtopic.php?t=12389). It is included here to demonstrate the capabilities of the compiler.

* The example game [Tenliner Cave Adventure](https://spectrumcomputing.co.uk/index.php?cat=96&id=30392) was originally created by Einar Saukas.
