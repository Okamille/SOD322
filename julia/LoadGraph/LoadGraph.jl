module LoadGraph

using DataStructures: DefaultDict
using DelimitedFiles: readdlm

export load_adjacency_matrix,
       load_edge_list,
       load_undirected_adjacency_list,
       load_directed_adjacency_list,
       AdjacencyList

include("adjacency_matrix.jl")
include("edge_list.jl")
include("adjacency_list.jl")
include("utils.jl")

end
