"""Loads an edge list file as an adjacency matrix."""
function load_adjacency_matrix(path::String)
    edge_list = load_edge_list(path)
    one_indexing!(edge_list)
    adj_matrix = load_adjacency_matrix(edge_list)
    return adj_matrix
end

function load_adjacency_matrix(edge_list::Array)
    n_nodes = size(edge_list, 1)
    adjacency_matrix = zeros(Bool, (n_nodes, n_nodes))
    for (ns, n_t) in eachrow(edge_list)
        adjacency_matrix[n_s, n_t] = true
    end
    return adjacency_matrix
end

function load_adjacency_matrix(io::IO, n_nodes::Int)
    adjacency_matrix = zeros(Bool, (n_nodes, n_nodes))
    for line in eachline(io)
        n_s, n_t = process_line(line, Int)
        adjacency_matrix[n_s + 1, n_t + 1] = true
    end
    return adjacency_matrix
end
