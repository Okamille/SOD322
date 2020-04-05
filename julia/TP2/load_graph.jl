using DelimitedFiles: readdlm

function load_adjacency_list(path::String, n_nodes::Int)
    # adjacency_list = Vector{Vector{UInt32}}(undef, n_nodes)
    adjacency_list = [Vector{UInt32}() for _ in 1:n_nodes]
    open(path) do io
        lines = eachline(io)
    end
    for line in eachline(path)
        if line[1] != '#'
            n_s, n_t = split(line)
            push!(adjacency_list[parse(UInt32, n_s)], parse(UInt32, n_t))
        end
    end
    return adjacency_list
end

function load_edge_list(path::String, n_edges::Int; delim::Char='\t')
    edges = readdlm(path, delim, UInt32, dims=(n_edges, 2), comments=true)
    return edges
end

function load_adjacency_matrix(path::String, n_nodes::Int)
    adjacency_matrix = zeros(Bool, (n_nodes, n_nodes))
    open(path) do io
        lines = eachline(io)
    end
    for line in eachline(path)
        n_s, n_t = split(line)
        adjacency_matrix[parse(UInt32, n_s) + one(UInt32), parse(UInt32, n_t) + one(UInt32)] = true
    end
    return adjacency_matrix
end


# m = load_adjacency_matrix("data/email-Eu-core.txt", 1005)
m = load_adjacency_list("data/com-amazon.ungraph.txt", 334_863)
println(m)