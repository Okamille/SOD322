function one_indexing!(edge_list::Array)
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
