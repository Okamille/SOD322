#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <strings.h>
#include <time.h>//to estimate the runing time
#include <limits.h> 

#define NLINKS 100000000 //maximum number of edges for memory allocation, will increase if needed


//Adajcency array structure

// Define a struct to store adjacency array
typedef struct {
	unsigned long n;//number of nodes
	unsigned long e;//number of edges
	unsigned long *cumulDegree;//cumulative degree cd[0]=0 length=n+1
	unsigned long *adjList;//lists of neighbors for all nodes. Lenght = cd[n]
                           // Neighbours of node i start at cd[i] 
} adjarray;


/// USEFULL FUNCTIONS
// compute the maximum of two unsigned long 
unsigned long max(unsigned long a,unsigned long b){
	return (a>b) ? a : b;
}
//compute the maximum of three unsigned long
unsigned long max3(unsigned long a,unsigned long b,unsigned long c){
	a=(a>b) ? a : b;
	return (a>c) ? a : c;
}

// compute the min of two unsigned long 
unsigned long min(unsigned long a,unsigned long b){
	return (a<b) ? a : b;
}


unsigned long number_of_edges(char* input){
    // Compute number of edges from a file containing edges of undirected graph
    FILE *file=fopen(input,"r");

    int e = 0;
    unsigned long node1;
    unsigned long node2;

    while(fscanf(file,"%lu %lu", &node1, &node2)==2){
        e++;
    }
    fclose(file);
    
    return e;
}

unsigned long number_of_nodes(char* input){
    // Compute number of nodes from a file containing edges
    // Assuming all nodes are in an edge and they are labeled from 0 to n-1
    FILE *file=fopen(input,"r");
    
    unsigned int n = 1;
    unsigned long node1;
    unsigned long node2;

    while(fscanf(file,"%lu %lu", &node1, &node2)==2){
        n = max3(n,node1,node2);
    }
    fclose(file);

    n++;

    return n;
}

///   Compute degrees ///
void node_degree(char*input_cleaned, char*output){
    // Get number of nodes in the file
    unsigned long nb_nodes = number_of_nodes(input_cleaned);
    // Create an array
    unsigned long *  degrees = malloc ( sizeof(unsigned long) * nb_nodes );

    for (unsigned long i=0;i<nb_nodes;i++) {
    degrees[i] = 0;
    }	
    
    // read the file and compute the degree of each node 
    FILE *file=fopen(input_cleaned,"r");
    
    unsigned long node1;
    unsigned long node2;
    
    while(fscanf(file,"%lu %lu",&node1,&node2)==2){
        degrees[node1]++;
        degrees[node2]++;
    }
    fclose(file);
    
    // write in the file
    
    FILE *f = fopen(output, "w");

    for (unsigned long i=0;i<nb_nodes;i++){    
        fprintf(f,"%lu %lu\n",i,degrees[i]);	
    } 
    fclose(f);
}


void printcore(char* output,unsigned long n, unsigned long* core){
    FILE *file=fopen(output,"w");
	for (unsigned long i=0;i<n;i++){
		fprintf(file,"%lu %10lu\n",i,core[i]);
	}
    fclose(file);
}


//ADJACENCY ARRAY FUNCTIONS
adjarray* make_adjarray(char *input, char* degfile){
	adjarray* g = malloc(sizeof(adjarray));
	g->n=number_of_nodes(input);
	g->e=number_of_edges(input);
	
	unsigned long i; 
	unsigned long * degrees = malloc (sizeof(unsigned long)*(g->n));
    memset( degrees , 0, sizeof(unsigned long)*(g->n) );
	//Read the degrees
	FILE *file=fopen(degfile,"r");
	unsigned long node;
	unsigned long deg;
	while (fscanf(file,"%lu %lu", &node, &deg)==2) {
		degrees[node]=deg;
	}
	fclose(file);

	g->cumulDegree=malloc((g->n+1)*sizeof(unsigned long));
    memset( g->cumulDegree , 0, sizeof(unsigned long)*((g->n)+1) );
	g->cumulDegree[0]=0;
	for (i=1;i<g->n+1;i++) {
		g->cumulDegree[i]=g->cumulDegree[i-1]+degrees[i-1];
		degrees[i-1]=0;
	}

	g->adjList=malloc(2*g->e*sizeof(unsigned long));

	file=fopen(input,"r");
	unsigned long node1, node2;
	while (fscanf(file,"%lu %lu", &node1, &node2)==2) {
		g->adjList[ g->cumulDegree[node1] + degrees[node1] ]=node2;
        degrees[node1]++;
		g->adjList[ g->cumulDegree[node2] + degrees[node2] ]=node1;
        degrees[node2]++;
	}
	fclose(file);

	free(degrees);

	return g; 
}


//freeing memory
void free_adjarray(adjarray *g){
	//free(g->edges);
	free(g->cumulDegree);
	free(g->adjList);
	free(g);
}

void permute(unsigned long* list, unsigned long i1, unsigned long i2){
    unsigned long temp=list[i1];
    list[i1]=list[i2];
    list[i2]=temp;
}



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

///////////////           MAKING K_CORE DECOMPOSITION           ////////////////


void core_decomposition(adjarray* ADJ, char* degfile, unsigned long n_nodes, unsigned long n_edges, char* output, char* eta_output){
    unsigned long c=0;
    unsigned long ordered_node_cursor =0;// To know if we have visited all the nodes of the graph that is to say if V(G)=empty set

    // Store the degrees
    unsigned long *  degrees = malloc ( sizeof(unsigned long) * n_nodes ); // Allocate an array to get the degrees
    FILE *degrees_file=fopen(degfile,"r");
    unsigned long node, deg;
    unsigned long max_degree=0;
    while(fscanf(degrees_file,"%lu %lu",&node,&deg)==2){
        degrees[node]=deg;
        max_degree=max(deg, max_degree);
    }
    fclose(degrees_file);
    max_degree+=1;
    //Order the nodes by increasing degree
        // ordered_nodes represent the orderet list of nodes
        // end_index[d] represent the last_index in ordered_nodes that contains a node of degree d
    unsigned long *ARRAY=malloc(sizeof(unsigned long)*max_degree*n_nodes);
    unsigned long *set_size= malloc ( sizeof(unsigned long) * max_degree );
    memset(set_size, 0, sizeof(unsigned long)*max_degree );
    for (unsigned long i=0;i<n_nodes;i++){
        unsigned long d=degrees[i];
        ARRAY[d*n_nodes+set_size[d]]=i;
        set_size[d]=set_size[d]+1;
    }
    printf("ARRAY stored\n");

    

    unsigned long *ordered_nodes=malloc(sizeof(unsigned long)*n_nodes);
    unsigned long* end_index=malloc(sizeof(unsigned long)*max_degree);
    unsigned long* node_index=malloc(sizeof(unsigned long)*n_nodes);
    unsigned long i=0;
    for (unsigned long d=0;d<max_degree;d++){
        for (unsigned long j=0;j<set_size[d];j++){
            ordered_nodes[i]=ARRAY[d*n_nodes+j];
            node_index[ARRAY[d*n_nodes +j]]=i;
            i++;
        }
        end_index[d]=i-1;
    }

    free(ARRAY);
    free(set_size);

    printf("The nodes are oredered \n");
    //Allocate an array to get the core value of each node
    unsigned long * core=malloc(sizeof(unsigned long)*n_nodes);
    memset(core , 0, sizeof(unsigned long)*n_nodes);

    // Allocate memory to get the order in which the nodes were removed
    unsigned long * eta=malloc(sizeof(unsigned long)*n_nodes);
    memset(eta, 0, sizeof(unsigned long)*n_nodes );
    unsigned long v,deg_v;
    while(ordered_node_cursor<n_nodes){
        // v in the node with minimum degree in G -> remove it from G
        v=ordered_nodes[ordered_node_cursor];
        eta[v]=n_nodes-ordered_node_cursor;
        deg_v=degrees[v];
        c=max(c, deg_v);

        // V(G)<- V(G) -{v}
        degrees[v]=ULONG_MAX;
        
        for (unsigned long j=0; j<deg_v;j++){
            unsigned long voisin_name= ADJ->adjList[ADJ->cumulDegree[v]+j];
            if (degrees[voisin_name]==ULONG_MAX){continue;}
            degrees[voisin_name]--;
            unsigned long previous_pos=node_index[voisin_name];
            unsigned long k=0;
            unsigned long new_pos;
            if (ordered_node_cursor<end_index[degrees[voisin_name]]){
                new_pos=end_index[degrees[voisin_name]]+1;
            }
            else{
                new_pos=ordered_node_cursor+1+k;
                k++;
            }
            //unsigned long new_pos=max(ordered_node_cursor+1,end_index[degrees[voisin_name]]+1);
            //if(new_pos==ordered_node_cursor+1){printf("Placé au début pour le noeud %lu \n", v);}
            permute(ordered_nodes, previous_pos, new_pos);
            permute(node_index,voisin_name, ordered_nodes[previous_pos]);
            end_index[degrees[voisin_name]]=new_pos;
            
        }

        ordered_node_cursor++;
        core[v]=c;

    }
    printf("ordered_nodes cursor %lu", ordered_node_cursor);
    printcore(output, n_nodes,core);
    printcore(eta_output, n_nodes, eta);
    free_adjarray(ADJ);
    free(degrees);
    free(core);

}


int main(int argc,char** argv){
	time_t t1,t2;
	t1=time(NULL);
    
    // If the degfile wasn't created before
    printf("Computing degree file...\n");
    node_degree(argv[1],argv[3]); 

    printf("Computing the number of nodes and edges of the graph\n");
	unsigned long n_nodes = number_of_nodes(argv[1]);
    printf("Number of nodes %lu \n", n_nodes);
    unsigned long n_edges = number_of_edges(argv[1]);
    printf("Number of edges %lu \n", n_edges);

    printf("Creating an adjarray to store the neigbours of all nodes\n");
    // Create a edgelist* to store the graph in the input file
    //edgelist * g=readedgelist(argv[1]);
    adjarray* ADJ =make_adjarray(argv[1], argv[3]);

    printf("Making the core_decomposition\n");
	core_decomposition(ADJ, argv[3], n_nodes, n_edges, argv[2], argv[4]);

	t2=time(NULL);

	printf("- Overall time = %ldh%ldm%lds\n",(t2-t1)/3600,((t2-t1)%3600)/60,((t2-t1)%60));

	return 0;
}
