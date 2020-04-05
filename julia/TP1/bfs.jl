using DataStructures: Queue, enqueue!, dequeue!, isempty

include("../LoadGraph/LoadGraph.jl")
using .LoadGraph: load_adjacency_list, AdjacencyList

function main(dir_path="../../cleaned_data", dtype::Type=Int32)
    for file in filter(x->occursin(".txt", x), readdir(dir_path))
        println(file)
        @time graph = load_adjacency_list("$dir_path/$file", dtype)
        @time cc = BFS(graph, one(dtype))
        println()
    end
end

function BFS(graph::AdjacencyList{T}, node::T) where T
    fifo = Queue{T}()
    enqueue!(fifo, node)
    marks = Dict{T, Bool}([(node, true)])
    connected_components = Vector{T}()
    while ! isempty(fifo)
        u = dequeue!(fifo)
        push!(connected_components, u)
        for v in graph[node]
            if ! haskey(marks, v)
                enqueue!(fifo, v)
                marks[v] = true
            end
        end
    end
    return connected_components
end

main()
