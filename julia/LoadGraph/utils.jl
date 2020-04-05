function one_indexing(edge_list::Array, new_type::Type=UInt32)
    nodes = unique(edge_list)
    node_map = Dict(zip(nodes, collect(new_type, 1:length(nodes))))
    new_edges = similar(edge_list, new_type)
    for (i, node) in enumerate(edge_list)
        new_edges[i] = node_map[node]
    end
    return new_edges
end

function one_indexing!(edge_list::Array{Int,2})
    dtype = eltype(edge_list)
    nodes = unique(edge_list)
    node_map = Dict(zip(nodes, collect(dtype, 1:length(nodes))))
    for (i, node) in enumerate(edge_list)
        edge_list[i] = node_map[node]
    end
end

function process_line(line, dtype::Type)
    n_s, n_t = split(line)
    return parse(dtype, n_s), parse(dtype, n_t)
end
