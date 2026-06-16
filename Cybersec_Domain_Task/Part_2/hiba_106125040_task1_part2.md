## Part 2: The Fuzzing Harness (`license.c`)

### 1. What is a harness

A harness is helper code. It is like a tiny program that feeds data to library functions. If the target is not a full program, you need this helper so the fuzzer can call the functions.

### 2. My harness problems

The harness I had was broken at first. I did not understand why. The code would not accept inputs. It crashed or just returned.

### 3. How I tried to fix it

I added a simple read of the input buffer and passed it to the function.

I added `__AFL_LOOP` to try persistent mode because it was mentioned in examples. I did not fully understand the loop, but it made fuzzing faster.

I changed compile flags to `afl-clang-fast` and added ASan so crashes show up more clearly.

But I am still learning how the harness should work.

### 4. My Errors

I saw the program crash once and it looked like the code read past the buffer sometimes. So the program crashed when I gave weird input. I am not fully sure if it is a real vulnerability. I think it might be.

---

### 5. The main commands i used

1. Compiling with AddressSanitizer (ASan)

afl-clang-fast -fsanitize=address -g license.c -o fuzzer

this compiles the harness with AddressSanitizer (ASan) enabled. This adds strict defensive tracking to the program's memory allocation, forcing the program to loudly crash if a mutated input causes a hidden buffer overflow or memory corruption.

2. Forcing a Local Test Run

./fuzzer < inputs/seed.txt

this manually pipes a sample text seed into the harness without the fuzzer running. This allowed me to test if my data reading loops and the \_\_AFL_LOOP structure worked properly before starting the automated engine.

3. Launching the High-Speed Campaign

afl-fuzz -i inputs/ -o findings_part2/ -- ./fuzzer

this starts the main fuzzing tracker for the harness. Because \_\_AFL_LOOP was written inside license.c, AFL++ automatically recognized Persistent Mode, allowing it to fuzz the target function thousands of times per second without constantly restarting the program.
