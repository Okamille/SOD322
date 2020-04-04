#ifndef EDGELIST_H
#define EDGELIST_H

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define NLINKS 100000000

typedef struct {
	unsigned long s;
	unsigned long t;
} edge;

//edge list structure:
typedef struct {
	unsigned long n;//number of nodes
	unsigned long e;//number of edges
	edge *edges;//list of edges
} edgelist;

unsigned long max3(unsigned long a,unsigned long b,unsigned long c);
edgelist* readedgelist(char* input);
void free_edgelist(edgelist *g);

#endif