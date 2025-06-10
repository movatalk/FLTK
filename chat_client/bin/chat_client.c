/*
 * Audio-Visual Chat Client - Mock Binary
 * Author: Tom Sapletta
 * License: Apache-2.0
 * Copyright 2025 Tom Sapletta
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    printf("Audio-Visual Chat Client v1.0.0\n");
    printf("Author: Tom Sapletta\n");
    printf("License: Apache-2.0\n\n");
    
    printf("This is a mock binary for testing AppImage packaging.\n");
    printf("In a real build, this would be the actual FLTK chat application.\n\n");
    
    // Check for --version flag
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--version") == 0) {
            printf("Version: 1.0.0\n");
            return 0;
        }
    }
    
    printf("Audio devices detected (mock):\n");
    printf("  - Default input: Microphone\n");
    printf("  - Default output: Speakers\n\n");
    
    printf("Ready for audio communication.\n");
    
    return 0;
}
