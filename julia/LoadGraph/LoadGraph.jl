module LoadGraph

using DelimitedFiles: readdlm

export load_adjacency_matrix,
       load_edge_list,
       load_adjacency_list,
       AdjacencyList

include("adjacency_matrix.jl")
include("edge_list.jl")
include("adjacency_list.jl")

end
