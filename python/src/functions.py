import numpy as np
from math import floor
from random import uniform
from random import randint
import networkx as nx

#exercice 1
def graph_rand_edges(p,q,nb_nodes=400,nb_clusters=4):

    # p,  proba of linking 2 nodes in the same cluster
    #  q,  proba of linking 2 nodes in different clusters
    # nb_nodes,  number of nodes 
    # nb_clusters,  number of clusters
    
    # Define clusters
    true_comm = []
    for j in range(nb_clusters):
        true_comm +=[j for i in range(int(np.floor(nb_nodes/nb_clusters)))]
      
    # Create random edges
    # with probability p if nodes in the same community
    # with probabitliy q otherwise
    edges = []
    for node_1 in range(nb_nodes):
        for node_2 in range(node_1+1,nb_nodes):
            r = uniform(0.0,1.0) #random value, uniform between 0 and 1
            
            # If nodes are in the same cluster link them with probability p
            if true_comm[node_1]==true_comm[node_2]: 
                if r < p:   
                    edges.append((node_1,node_2))

            else : #if nodes in different clusters link them with probability q
                if r < q:
                    edges.append((node_1,node_2))
    
    # Create networkx graph object
    Gr= nx.Graph()
    Gr.add_nodes_from(range(nb_nodes))
    Gr.add_edges_from(edges)
    
    return Gr,true_comm


#exercice 2

def fy_shuffle(tab):
    #Fisher-Yates shuffle
    list_range = range(0, len(tab))
    for i in list_range:
        j = randint(list_range[0], list_range[-1])
        tab[i], tab[j] = tab[j], tab[i]
    return tab

def neighbour_label(graph, node, labels):
    #find label occurring with the highest frequency among neighbours of node in graph
    unique_labels = list(set(labels))
    scores = dict(zip(unique_labels,[0 for i in range(len(unique_labels))]))
    
    for neighb in graph.neighbors(node):
        neighb_label = labels[neighb]
        scores[neighb_label] += 1
    
    argmax = max(scores, key=scores.get)
    
    return argmax

def label_propagation_step_three(graph,labels):

    new_labels =[-1 for i in range(len(labels))]
    
    shuffled_nodes = fy_shuffle(list(graph.nodes))

    #for each node in the network (in this random order)
    # set its label to a label occurring with the highest frequency among its neighbours
    for node in shuffled_nodes : 
        new_labels[node] = neighbour_label(graph,node,labels)
    return new_labels


def label_propagation(graph, init_labels, max_iter=1000):

    test = True #bool that indicates if the we keep iterating the algorithm
    n_iter = 0
    labels = init_labels
    
    while test :
        #step three: label propagation
        labels = label_propagation_step_three(graph,labels)
        
        #stoping criteria
        test = False
        for node in graph.nodes :
            # Check if one node doesn't belong to the same communities than the majority of its neighbors
            if labels[node] != neighbour_label(graph,node,labels):
                test = True# If one node doesn't satisfy the condition, we need to continue
        if n_iter > max_iter :
            test = False
            
        n_iter+=1
    
    return labels

#exercice 3
def preprocess_communities(pathToData):
    '''
    Convert the community.dat file in a list of the membership of the nodes
    
    Reindex also communities from 0 to nb_communities-1 instead of 0 to nb_communities
    -----------------------------------------------------------
    Inputs:
    :str,  pathToData,  the path to the file containing community.dat
    
    Outputs:
    :list of ints, a list where element i is the community (listed from 0 to n-1) to which node[i] belongs
    '''
    return [int(line.replace('\t',' ').replace('\n',' ').split()[1])-1 for line in open(pathToData+"community.dat").readlines()]

def preprocess_edges(pathToData):
    '''
    Convert the network.dat file in a list of edges
    Also reindex nodes from 0 to nNodes-1 instead of 1 nNodes
    -----------------------------------------------------------
    Inputs:
    :str,  pathToData,  the path to the file containing network.dat
    
    Outputs:
    :list of tuples, a list where element i is an edge of the graph
    '''
    # Reformat the string
    temp = [line.replace('\t',' ').replace('\n',' ').split() for line in open(pathToData+"network.dat").readlines()] 
    # Convert to tuples of integers and return
    return [(int(a)-1,int(b)-1) for a,b in temp]