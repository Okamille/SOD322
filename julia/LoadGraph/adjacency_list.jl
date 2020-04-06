AdjacencyList{dtype} = DefaultDict{dtype, Vector{dtype}}

"""Loads an edge list file as an adjacency list.

Args:
    edge_list Union{IO, AbstractString}: I/O streams of edges or edge list file path
    dtype (Type)
"""
function load_adjacency_list(edge_list, dtype::Type=UInt32)
    adjacency_list = AdjacencyList{dtype}(() -> Vector{dtype}())
    for line in eachline(edge_list)
        n_s, n_t = process_line(line, dtype)
        update_adj_list!(adjacency_list, n_s, n_t)
    end
    return adjacency_list
end

function update_adj_list!(adjacency_list::AdjacencyList{T}, n_s::T, n_t::T) where T
    push!(adjacency_list[n_s], n_t)
    push!(adjacency_list[n_t], n_s)
end
