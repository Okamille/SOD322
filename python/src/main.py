import numpy as np
from random import randint
import matplotlib.pyplot as plt
import networkx as nx
from networkx.drawing.nx_pylab import draw
import time
from memory_profiler import memory_usage
import community #python-louvain package
import pandas as pd
from sklearn.metrics import normalized_mutual_info_score as NMI
from sklearn.metrics import adjusted_rand_score as ARS

from functions import graph_rand_edges, fy_shuffle, neighbour_label, label_propagation_step_three, label_propagation

resFold = '../res/'

print("exercice 1: simple benchmark")

nb_nodes = 400
nb_clusters = 4
p = [0.1, 0.3, 0.5, 0.9]
q = 0.1

for p_i in p:
    G, y = graph_rand_edges(p_i, q, nb_nodes, nb_clusters)
    fig = plt.figure()
    draw(G)
    fig.suptitle('P/Q='+str(p_i/q))
    fig.savefig(resFold+str(p_i)+'_'+str(q)+'_'+str(nb_clusters)+'clusters.png')


print("exercice 2: Label propagation")

nb_nodes = 400
nb_clusters = 4
p = [0.1, 0.3, 0.5, 0.9]
q = 0.1

for p_i in p:
    G, y = graph_rand_edges(p_i, q, nb_nodes, nb_clusters)
    
    #random init of labels
    y_init = np.arange(400)
    np.random.shuffle(y_init)
    
    y_propagation = label_propagation(G, y_init)
    
    fig = plt.figure()
    draw(G,node_color=y_propagation,cmap='jet')
    fig.suptitle('Communities, label propagation for p/q ='+str(p_i/q))
    fig.savefig(resFold+str(p_i)+'_'+str(q)+'_'+'label_prop.png')
    
    #true clusters
    fig = plt.figure()
    draw(G,node_color=y,cmap='jet')
    fig.suptitle('True clusters, p/q ='+str(p_i/q))
    fig.savefig(resFold+str(p_i)+'_'+str(q)+'_'+'true_clusters.png')


print("exercice 3: validation")
print("simple benchmark")
p = [0.1, 0.3, 0.5, 0.9]
q = 0.1
nb_nodes = [200,400,600,800]
nb_clusters = 4
df = pd.DataFrame(columns=['p', 'q', 'nb_nodes','time_propagation','memory_propagation','time_louvain','memory_louvain'])

for p_i in p:
    for N in nb_nodes :
        G, y = graph_rand_edges(p_i, q, N, nb_clusters)

        # Label propagation
        start_label_prop = time.time()

        init_labels = np.arange(N)
        np.random.shuffle(init_labels)
        label_prop_memory = np.mean(memory_usage((label_propagation, (G,init_labels))))

        end_label_prop = time.time()

        #Louvain 
        start_louvain = time.time()

        louvain_memory = np.mean(memory_usage((community.best_partition,(G,))))

        end_louvain = time.time()
        
        d = {'p': [p_i], 
             'q':[q],
             'nb_nodes':[N],
             'time_propagation' : [end_label_prop-start_label_prop],
             'memory_propagation': [label_prop_memory],
             'time_louvain' : [end_louvain-start_louvain],
             'memory_louvain': [louvain_memory]
            }
        
        df2 = pd.DataFrame(data = d)
        df = df.append(df2)

df.to_csv(resFold+"compare_algorithms_results.csv",index=False)

print("LFR benchmark")

## LFR Benchmark

!./lfr_package/binary_networks/benchmark -N 400 -k 5 -maxk 50 -mu 0.1


pathToData = "./"

# Process data
y = preprocess_communities(pathToData)
edgelist = preprocess_edges(pathToData)

nNodes = len(y)
nCommunities = max(y)

#Generate the graph
G = nx.Graph()
G.add_nodes_from(range(nNodes))
G.add_edges_from(edgelist)

fig = plt.figure()
draw(G,node_color=y,cmap='jet')
fig.suptitle('True clusters, LFR Benchmark")
fig.savefig(resFold+'lfr_benchmark.png')

# Label propagation 
y_init = [randint(0,nCommunities-1) for i in range(nNodes)]
y_label_propagation = label_propagation(G, y_init)

# Louvain
partition = community.best_partition(G)
y_louvain = list(partition.values())

print("Evaluate models\n")
print("NMI")
print('Label Propagation NMI: ' + str(NMI(y,y_label_propagation)))
print('Louvain NMI: ' + str(NMI(y,y_louvain)))

print("ARS")
print('Label Propagation ARS: ' + str(ARS(y,y_label_propagation)))
print('Louvain ARS: ' + str(ARS(y,y_louvain)))
