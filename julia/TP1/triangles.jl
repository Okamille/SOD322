include("../LoadGraph/LoadGraph.jl")
using .LoadGraph: load_adjacency_list, AdjacencyList

function main(dir_path="../../cleaned_data", dtype::Type=Int32)
    for file in filter(x->occursin(".txt", x), readdir(dir_path))
        println(file)
        @time graph = load_adjacency_list("$dir_path/$file", dtype)
        @time triangles = list_triangles(graph)
        println(length(triangles))
        println()
    end
end

function list_triangles(graph::AdjacencyList)
    truncated = truncate_graph(graph)
    triangles = find_triangles(truncated)
    return triangles
end

function truncate_graph(graph::AdjacencyList{T}) where T<:Real
    truncated = Dict{T, Vector{T}}()
    for (node, neighbours) in graph
        truncated[node] = sort([neighbour
                                for neighbour in neighbours
                                if neighbour < node])
        println(length(truncated[node]))
    end
    return truncated
end

function find_triangles(graph)
    triangles = Vector{Vector{eltype(graph)}}()
    for (node, neighbours) in graph
        for neighbour in neighbours
            if length(intersect(neighbours, graph[neighbour])) >= 1
                println(intersect(neighbours, graph[neighbour]))
            end
            for second_neighbour in intersect(neighbours, graph[neighbour])
                push!(triangles, [node, neighbour, second_neighbour])
            end
        end
    end
    return triangles
end


main()
