/*
 * AFL++ fuzzing harness — license validation library
 *
 * Build:  make fuzzer
 * Run:    afl-fuzz -i corpus/ -o findings/ -- ./fuzzer @@
 *
 * AFL++ is launching, the binary runs, but the fuzzer makes no progress.
 * Something is wrong. Find the issues and fix them.
 */

#include "license.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    // FIX - Heavy setup framework run once at startup
    // We initialize the heavy system infrastructure 
    // EXACTLY ONCE before entering the high-speed fuzzing loop.
    if (!init_license_system()) {
        fprintf(stderr, "Error: Failed to initialize license system.\n");
        return 1; 
    }

    // Every single time AFL++ tests a mutated input, this program executes from top to bottom.
    // It hits init_license_system(), initializes global variables, sets up configuration memory, and then runs validate_license(). 
    // Then the program terminates.

    // . It is incredibly slow. AFL++ wants to execute your function thousands of times per second. If init_license_system() takes even a millisecond
    //  to set up tracking structures or allocate memory, your fuzzing speed drops to a crawl.

//     By default, if you don't give AFL++ specific instructions, it has to use a Linux system call called fork() to clone a completely fresh operating system process for every single test case.

// Why this is bad: Creating a process requires the Linux kernel to allocate memory maps, handle permissions, and clear registers. Doing this millions of times consumes massive amounts of CPU power 
// just for operating system maintenance, rather than actual fuzzing.
// // WHY THIS IS HERE: This loop tells AFL++ to use Persistent Mode.
//     // It keeps the process running in memory for 1,000 test cases at a time,
//     // avoiding the massive overhead of creating a fresh Linux process every single run.

    while (__AFL_LOOP(1000)) {
        FILE *f = fopen(argv[1], "rb");
        if (!f)
            continue; // Skip if the fuzzer hasn't written the file yet

        uint8_t buf[65536];
        size_t len = fread(buf, 1, sizeof(buf), f);
        fclose(f);

        // Execute the target library function with our mutated data
        validate_license(buf, len);
    }

    return 0;
}
