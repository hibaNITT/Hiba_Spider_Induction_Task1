#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include "json.h"

int main() {
    // using the mode optimization from Part 2
    while (__AFL_LOOP(1000)) {
        char buffer[4096];
        ssize_t bytes_read = read(STDIN_FILENO, buffer, sizeof(buffer) - 1);
        
        if (bytes_read > 0) {
            // Ensuring the input is a valid null-terminated string for the JSON parser
            buffer[bytes_read] = '\0';
            
            // Feed the fuzzer bytes into the real open-source library function
            struct json_object *obj = json_tokener_parse(buffer);
            
            // Cleaning up memory to avoid false positive memory leaks
            if (obj) {
                json_object_put(obj);
            }
        }
    }
    return 0;
}
