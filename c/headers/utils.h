#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>

typedef struct {
    unsigned long n;
    unsigned long m;
    double* values;
} matrix;

void debug(char* s, int debugState);

#endif