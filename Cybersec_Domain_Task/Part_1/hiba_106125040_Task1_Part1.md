## Part 1: Foundations of Fuzzing (`xarinfo`)

### 1. Concept

Fuzzing is like hitting a program with lots of random stuff. A fuzzer makes random inputs. It puts them in the program. It does this many, many times. If the program breaks or crashes, the fuzzer tells you. I think of it as guessing until something breaks.

I used AFL++ (the `afl-fuzz` tool). I set it up. I am not perfect at setup. I did what I could by following a source.

### 2. Setting up the fuzzer

I ran commands to compile the program with special flags so the fuzzer can see paths. I used a command like `make asan CC=afl-clang-fast`. Then I started `afl-fuzz` with a seeds folder and an output folder, and it worked.

### 3. Seed selection

A seed is a starting input file. Good seed means the program runs more. Bad seed means it stops fast. Good seeds let the fuzzer reach more code. Bad seeds make it quit quick.

I tried small valid files as seeds. That seemed to help more than random big files.

### 4. What I saw

When i ran the fuzzer, I saw counters going up. But there were no crashes.

I learned that you can use a small dictionary or keep header bytes stable so the fuzzer can go deeper.

### 5. Important Commands I used

1. Checking the Environment

afl-fuzz -v

this verifies that AFL++ is correctly installed in WSL and checks its version so we know the testing environment is ready.

2. Compiling with AFL++ Instrumentation

afl-clang-fast source.c -o fuzzer_target

this compiles a basic C file using AFL++'s fast compiler. This injects hidden tracking sensors into the code blocks so the fuzzer can monitor which execution paths get triggered.

3. Running a Simple Campaign

afl-fuzz -i inputs/ -o findings_part1/ -- ./fuzzer_target

this launches the standard fuzzing loop, reading initial test inputs from the inputs folder and writing results to findings_part1.

### 6. My findings

I did not find big bugs here. I saw the fuzzer run many times. It reported zero crashes for a while. I think the parser's header check stopped it. Maybe if I made a better seed or used a dict it would find more.

---
