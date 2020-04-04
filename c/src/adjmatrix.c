/*
Maximilien Danisch
September 2017
http://bit.ly/danisch
maximilien.danisch@gmail.com

Info:
Feel free to use these lines as you wish. This program loads an unweighetd graph in main memory as an adjacency matrix.

To compile:
"gcc adjmatrix.c -O9 -o adjmatrix".

To execute:
"./adjmatrix edgelist.txt".
"edgelist.txt" should contain the graph: one edge on each line (two unsigned long (nodes' ID)) separated by a space.
The prograph will load the graph in main memory and then terminate.

Note:
If the graph is directed (and weighted) with selfloops and you want to make it undirected unweighted without selfloops, use the following linux command line.
awk '{if ($1<$2) print $1" "$2;else if ($2<$1) print $2" "$1}' net.txt | sort -n -k1,2 -u > net2.txt

Performence:
Up to 200.000 nodes on my laptop with 8G of RAM.
Takes more or less 4G of RAM and 10 seconds (I have an SSD hardrive) for 100.000 nodes.
*/

#include "../headers/adjmatrix.h"

//building the adjacency matrix
void mkmatrix(adjmatrix* g){
	unsigned long i,u,v;
	g->mat=calloc(g->n*g->n,sizeof(bool));
	for (i=0;i<g->e;i++){
		u=g->edges[i].s;
		v=g->edges[i].t;
		g->mat[u+g->n*v]=1;
		g->mat[v+g->n*u]=1;
	}
}


void free_adjmatrix(adjmatrix *g){
	free(g->edges);
	free(g->mat);
	free(g);
}

