#ifndef ADJ_MATRIX_H
#define ADJ_MATRIX_H

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>

#include "edgelist.h"

typedef struct {
	unsigned long n;//number of nodes
	unsigned long e;//number of edges
	edge *edges;//list of edges
	bool *mat;//adjacency matrix
} adjmatrix;

void mkmatrix(adjmatrix* g);
void free_adjmatrix(adjmatrix *g);

#endif