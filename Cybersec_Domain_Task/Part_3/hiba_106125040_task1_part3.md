## Part 3: Real-World Open-Source Fuzzing - json-c`

### 1. Selecting open source software

I selected **`json-c`** because it is a widely used open-source C library for processing JSON data. It is small, clean, has zero complex external dependencies, and is incredibly responsive to a custom AFL++ harness.

**Why this library?** JSON is the foundational data transfer medium for modern web applications, configuration layers, and microservices.
Because parsing engines inherently handle heavily structured input strings from untrusted sources, they are highly prone to memory corruption bugs, making `json-c` an ideal security testing target for an evolutionary fuzzer.

### 2. Chosen Fuzzer

i chose AFL++ fuzzer because i used in in this project in part 2 and was fa,iliar with how it works . Moreover because it was recommended in the task document.

### 3. Custom Harness

Since `json-c` is distributed as a library rather than a executable with a command-line interface, I wrote a custom interface named `harness.c` to expose the library's internal components to AFL++.

**How the Harness Processes Inputs:** The harness I used works like a simple pipe. It captures the random, corrupted data streams that AFL++ generates and feeds them directly into a temporary storage space inside the computer's memory.

**Speeding Up with Persistent Mode (`__AFL_LOOP`):**
Normally, every single time a fuzzer tests a new mutation, the operating system has to completely start and stop the program from scratch (using a heavy process called `fork()`). This slows down the fuzzing to a crawl. To fix this, I used a special loop tool called `while (__AFL_LOOP(1000))` which i also used in part 2. This tricks the program into staying alive in the computer's memory for 1,000 test mutations at a time before resetting. It made our fuzzing campaign run incredibly fast because it cut out all that starting and stopping overhead.

**Looking into `json-c` and Cleaning Up:**
Inside that fast loop, the harness takes the raw test data, ensures it ends cleanly so it doesn't spill over, and passes it straight into the core function of the library: `json_tokener_parse()`. This is the exact function responsible for reading JSON text.

I also learned an important detail here: every time `json_tokener_parse()` successfully reads an input, it allocates a chunk of heap memory for it. If I left those chunks alone, the computer would run out of RAM within seconds of continuous fuzzing. To prevent this "out-of-memory" crash, I added `json_object_put()` right after it to instantly clean up and delete the temporary data before the next loop iteration started.

### 4. Problems I faced

When I first tried to compile my custom harness.c, it failed immediately with a major error: fatal error: json.h file not found. Even though the files were in my project folder, the compiler couldn't link them. Here is how I figured it out:

I learned that C libraries are highly sensitive to how their files are organized. The main file (json.h) needed to talk to a hidden setup file (json_config.h) inside the build folder.

Because my harness was sitting outside the library's native folder layout, I had accidentally broken their internal connection..

so I moved harness.c directly inside the main json-c library folder so it lived in the exact same environment as the source files.

I ran the build command inside that folder using include flags (-I . and -I build). This explicitly told the compiler: "Look right here in the current directory and inside the build folder to find the missing configuration pieces."

### 5. Important CLI Commands Used

I executed these three core steps in the terminal to set up the library, link my harness, and start fuzzing:

1. Preparing the Library

export CC=afl-clang-fast
cmake -DCMAKE_C_FLAGS="-fsanitize=address -g" ..
make

- this sets AFL++ as the compiler, turns on AddressSanitizer (ASan) to catch hidden memory bugs, and builds the internal json-c files.

2. Compiling the Harness

afl-clang-fast -g -fsanitize=address harness.c build/libjson-c.a -I . -I build -o ../fuzzer

- this links my custom harness.c code with the library's compiled static archive (libjson-c.a) and uses -I flags to point the compiler directly to the missing header paths.

3. Launching the Fuzzer

afl-fuzz -i inputs/ -o findings_part3/ -- ./fuzzer

- this starts the live tracking execution window. It reads initial JSON seeds from inputs/, feeds mutated variations into ./fuzzer at high speed, and stores all path metrics inside findings_part3/.
