#include <stdio.h>
#include "headers/utils.h"
#include "headers/adjarray.h"

// We preprocess the data using the command :
// sed -i '/^#/d' filename

int main(int argc, char* argv[]){
    edgelist* g = readedgelist(argv[1]);
    printf("Number of nodes : %d\n", g->n);
    printf("Number of edges : %d\n", g->e);
}