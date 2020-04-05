using DataStructures: Queue, enqueue!, dequeue!, isempty

include("../LoadGraph.jl")
using .LoadGraph: load

function BFS(graph::Array{Vector{T}}, node::T) where T <: Integer
    fifo = Queue{T}()
    enqueue!(fifo, node)
    marks = Dict([(node, true)])
    connected_components = Vector{T}
    while ! isempty(fifo)
        u = dequeue!(fifo)
        push!(connected_components, u)
        for v in graph[node]
            if ! marks[v]
                enqueue!(fifo, v)
                marks[v] = true
            end
        end
    end
    return connected_components
end
