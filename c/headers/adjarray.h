#ifndef ADJ_ARRAY_H
#define ADJ_ARRAY_H

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include "edgelist.h"

typedef struct {
	unsigned long n;//number of nodes
	unsigned long e;//number of edges
	edge *edges;//list of edges
	unsigned long *cd;//cumulative degree cd[0]=0 length=n+1
	unsigned long *adj;//concatenated lists of neighbors of all nodes
} adjlist;

void mkadjlist(adjlist* g);
void free_adjlist(adjlist *g);

#endif