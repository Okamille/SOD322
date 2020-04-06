include("../LoadGraph/LoadGraph.jl")
using .LoadGraph: load_adjacency_list, AdjacencyList

function main(dir_path="../../data", dtype::Type=Int32)
    # for file in filter(x->occursin(".txt", x), readdir(dir_path))
    for file in ["email-Eu-core.txt", "amazon.txt"]
        println(file)
        @time graph = load_adjacency_list("$dir_path/$file", dtype)
        @time triangles = list_triangles(graph)
        println(length(triangles))
        println()
    end
end

function main2()
    G = AdjacencyList{Int}(()->Vector{Int}())
    G[1] = [2, 3, 4]
    G[2] = [1, 3, 4]
    G[3] = [1, 2]
    G[4] = [1, 2]
    triangles = list_triangles(G)
    println(triangles)
    println()
    println()
end

function list_triangles(graph::AdjacencyList{T}) where T<:Real
    truncated = truncate_graph(graph)
    triangles = find_triangles(truncated)
    return triangles
end

function truncate_graph(graph::AdjacencyList{T}) where T<:Real
    truncated = Dict{T, Vector{T}}()
    for (node, neighbours) in graph
        truncated[node] = sort(
            [neighbour
             for neighbour in neighbours
             if degree(graph, node) >= degree(graph, neighbour)
            ],
            by=neigh->degree(graph, neigh),
            rev=true)
    end
    return truncated
end

function find_triangles(graph::Dict{T, Vector{T}}) where T<:Real
    triangles = Vector{Vector{T}}()
    for (node, neighbours) in graph
        for neighbour in neighbours
            for second_neighbour in intersect(neighbours, graph[neighbour])
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