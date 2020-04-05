"""Loads an edge list file."""
function load_edge_list(path::String, dtype::Type=UInt32)
    edges = readdlm(path, dtype, comments=true)
    return edges
end

function load_edge_list(path::String, n_edges::Int, dtype::Type=UInt32)
    edges = readdlm(path, dtype, dims=(n_edges, 2), comments=true)
    return edges
end
