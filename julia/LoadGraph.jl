module LoadGraph

using DelimitedFiles: readdlm

export load_adjacency_list, load_edge_list, load_adjacency_matrix

AdjacencyList{dtype} = Vector{Vector{dtype}}


function load_adjacency_list(path::String; dtype::Type=UInt32)
    open(path) do io
        first_line = readline(io)
        _, n_nodes, _ = split(first_line)
        adjacency_list = load_adjacency_list(io, parse(Int, n_nodes); dtype)
    end
    return adjacency_list
end

function load_adjacency_list(io::IO, n_nodes::Int; dtype::Type=UInt32)
    adjacency_list = [Vector{dtype}() for _ in 1:n_nodes]
    for line in eachline(io)
        n_s, n_t = split(line)
        push!(adjacency_list[parse(dtype, n_s)], parse(dtype, n_t))
    end
    return adjacency_list
end


function load_edge_list(path::String; dtype::Type=UInt32)
    open(path) do io
        first_line = readline(io)
        _, _, n_edges = split(first_line)
    end
    edges = load_edge_list(path, parse(Int, n_edges); dtype)
    return edges
end

function load_edge_list(path::String, n_edges::Int; dtype::Type=UInt32)
    edges = readdlm(path, dtype, dims=(n_edges, 2), comments=true)
    return edges
end


function load_adjacency_matrix(path::String)
    open(path) do io
        first_line = readline(io)
        _, n_nodes, _ = split(first_line)
        adj_matrix = load_adjacency_matrix(io, parse(Int, n_nodes))
    end
    return adj_matrix
end

function load_adjacency_matrix(io::IO, n_nodes::Int)
    adjacency_matrix = zeros(Bool, (n_nodes, n_nodes))
    for line in eachline(io)
        n_s, n_t = split(line)
        adjacency_matrix[parse(UInt32, n_s) + one(UInt32),
                         parse(UInt32, n_t) + one(UInt32)] = true
    end
    return adjacency_matrix
end

end
