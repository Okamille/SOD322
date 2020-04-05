AdjacencyList{dtype} = DefaultDict{dtype, Vector{dtype}}

"""Loads an edge list file as an adjacency list."""
function load_adjacency_list(path::String, dtype::Type=UInt32)
    io = open(path)
    first_line = readline(io)
    adjacency_list = load_adjacency_list(io, dtype)
    close(io)
    return adjacency_list
end

function load_adjacency_list(io::IO, dtype::Type=UInt32)
    adjacency_list = AdjacencyList{dtype}(() -> Vector{dtype}())
    for line in eachline(io)
        n_s, n_t = process_line(line, dtype)
        push!(adjacency_list[n_s], n_t)
        push!(adjacency_list[n_t], n_s)
    end
    return adjacency_list
end
