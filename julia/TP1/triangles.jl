include("../LoadGraph/LoadGraph.jl")
using .LoadGraph: load_adjacency_list, AdjacencyList

function main(dir_path="../../cleaned_data", dtype::Type=Int32)
    for file in filter(x->endswith(x, ".txt"), readdir(dir_path))
        if file != "friendster.txt"
        println(file)
        graph = load_adjacency_list("$dir_path/$file", dtype)
        @time triangles = list_triangles(graph)
        println(length(triangles))
        println(length(unique(triangles)))
        println()
        end
    end
end

function main2()
    G = AdjacencyList{Int}(()->Vector{Int}())
    G[1] = [2, 3, 4]
    G[2] = [1, 3, 4]
    G[3] = [1, 2]
    G[4] = [1, 2]
    triangles = list_triangles(G,Int)
    println(triangles)
    println()
end

function list_triangles(graph::AdjacencyList, dtype::Type=UInt32)
    truncated = reindex_truncate(graph, dtype)
    triangles = find_triangles(truncated)
    return triangles
end

function reindex_truncate(graph::AdjacencyList, dtype::Type=UInt32)
    sorted_keys = sort(collect(keys(graph)),
                       by=k->length(graph[k]),
                       rev=true)
    new_keys = collect(dtype, 1:length(graph))
    key_map = Dict(zip(sorted_keys, new_keys))

    reindexed = [sort([key_map[key]
                       for key in graph[old_key]
                       if key_map[key] > new_key])
                 for (old_key, new_key) in zip(sorted_keys, new_keys)]
    return reindexed
end

function find_triangles(graph::Vector{Vector{T}}) where T<:Real
    triangles = Vector{Vector{T}}()
    for (node, neighbours) in enumerate(graph)
        for (i, neighbour) in enumerate(neighbours[1:end-1])
            for second_neighbour in intersect(neighbours[i+1:end], graph[neighbour])
                push!(triangles, [node, neighbour, second_neighbour])
            end
        end
    end
    return triangles
end

function degree(graph::AdjacencyList, node)
    return length(graph[node])
end

main2()
main()