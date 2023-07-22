# Eight-Ball-Pool

## Description & Remarks
An eight-ball pool game written in x86 assembly.

Note: I made this project back in early 2022, and I used a different file for every version instead of using Git. I was not going to convert everything to branches, so I just made a folder for every version and put the files there.

## Instructions
In order to run the finished game, execute the following commands (preferably in a DOSBox emulator):
```
mount c: c:\
c:
cd tasm
cycles = max
tasm /zi nbprem.asm
tlink /v nbprem.obj
nbprem
```

Note that you need to have the contents of the `src` folder (`nbprem.asm` and the BMP images), the *tasm* assembler files and the *tlink* linker files all in `c:\tasm`.
