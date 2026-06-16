# Cybersec Domain Task

This project is my Spider Club induction task.

I am still learning fuzzing and secure coding, The repo has 3 parts and each part shows a different step in the fuzzing work.

## What is inside

- Part 1 is about fuzzing a file parser called `xarinfo`.
- Part 2 is about making a small fuzzing harness for `license.c`.
- Part 3 is about fuzzing the `json-c` library with my own harness.

## Project Demo Videos

- [Part 1](https://drive.google.com/file/d/11PRKsg3e7Qcd28QigoTsL4zWnowtGUv_/view?usp=sharing)
- [Part 2](https://drive.google.com/file/d/1qtxzqRlpYK2VTNFNm2D1ECfT_g2p-878/view?usp=sharing)
- [Part 3](https://drive.google.com/file/d/1WHQ2V1vjBTwAd1C6WGoL3OizRrxHmHkZ/view?usp=sharing)

## Part 1 - `xarinfo`

This part is about a command line program that reads `.xar` files and prints information about them.

I used AFL++ to send lots of random inputs to the program and see if it crashes.

### Files

- `Part_1/main.c` - the main program
- `Part_1/parser.c` - the parser code I tested
- `Part_1/parser.h` - parser data structures
- `Part_1/utils.c` and `Part_1/utils.h` - helper functions

### Basic build and run

```bash
cd Cybersec_Domain_Task/Part_1
make clean
make CC=afl-clang-fast
afl-fuzz -v
afl-fuzz -i inputs/ -o findings_part1/ -- ./xarinfo
```

### My note

I did not find a huge crash here, but I learned how seed files and sanitizers help when fuzzing.

## Part 2 - `license.c`

This part was about writing a small harness so AFL++ can test the code better.

At first my harness was not working well, but I changed it and tried persistent mode with `__AFL_LOOP`.

### Files

- `Part_2/license.c` - the target code
- `Part_2/afl_harness.c` - the harness I used
- `Part_2/test_license.c` - a test file

### Basic build and run

```bash
cd ../part_2
afl-clang-fast -fsanitize=address -g afl_harness.c license.c -o fuzzer
./fuzzer corpus/seed01.bin
afl-fuzz -i corpus/ -o findings/ -- ./fuzzer @@
```

### My note

This part helped me understand what a harness does and why fuzzing works better when the input loop is set up properly.

## Part 3 - `json-c`

This part uses the open source `json-c` library.

I made a custom harness for it and used AFL++ again because I was already more familiar with it from Part 2.

### Files

- `Part_3/json-c/` - the library source
- `Part_3/json-c/harness.c` - the custom fuzzing harness
- `Part_3/inputs/` - seed JSON files
- `Part_3/findings_part3/` - fuzzing output

### Basic build and run

```bash
cd ../Part_3
afl-clang-fast -fsanitize=address -g json-c/harness.c json-c/build/libjson-c.a -I json-c/ -I json-c/build/ -o ./fuzzer_part3
./fuzzer_part3 < inputs/seed1.json
afl-fuzz -i inputs/ -o findings_part3/ -- ./fuzzer_part3
ls -la findings_part3/default/
```

### My note

I learned that library projects need a harness and that cleanup matters when the fuzzer keeps running many times.

## What I learned

- AFL++ can find problems by testing many strange inputs.
- Seed files are important because they help the fuzzer start properly.
- AddressSanitizer makes memory bugs easier to see.
- A good harness makes fuzzing libraries much easier.

## Simple summary

This project is my first real try at fuzzing a few different programs and libraries. It is not perfect, but it shows my process and what I learned while doing the Spider Club induction task.
