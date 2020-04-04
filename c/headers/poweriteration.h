#ifndef POWERITERATION_H
#define POWERITERATION_H

#include "utils.h"

// Matrix vector product
matrix matvectprod(matrix a, matrix b);

// Power iteration definition
matrix poweriteration(matrix G, double alpha, unsigned long iter);
matrix matprod(double alpha, matrix* a);

#endif