using DataStructures: Queue, enqueue!, dequeue!, isempty

include("../LoadGraph/LoadGraph.jl")
using .LoadGraph: load_adjacency_list, AdjacencyList

function main(dir_path="../../cleaned_data", dtype::Type=Int32)
    for file in filter(x->endswith(x, ".txt"), readdir(dir_path))
        if file != "friendster.txt"
        println("=========== ", file, " ===========")
        @time graph = load_adjacency_list("$dir_path/$file", dtype)
        # @time cc = BFS(graph, one(dtype))
        @time all_cc = all_connected_components(graph)
        println("Number of connected components: ", length(all_cc))
        fraction = maximum(length(cc) for cc in all_cc) / length(graph)
        println("Fraction of nodes in the largest CC: ",
                round(100*fraction, digits=2), "%")
        @time diam_lb = diameter_lb(graph)
        println("Diameter lower bound : ", diam_lb)
        println()
        end
    end
end

function BFS(graph::AdjacencyList{T}, node::T) where T
    fifo = Queue{T}()
    enqueue!(fifo, node)
    marks = Dict{T, Bool}([(node, true)])
    distances = Dict{T, Int}([(node, 0)])

    connected_component = Vector{T}()
    while ! isempty(fifo)
        u = dequeue!(fifo)
        push!(connected_component, u)
        for v in graph[u]
            if ! haskey(marks, v)
                enqueue!(fifo, v)
                marks[v] = true
                distances[v] = distances[u] + 1
            end
        end
    end
    return [connected_component, distances]
end

function all_connected_components(graph::AdjacencyList{T}) where T<:Real
    connected_components = Vector{T}[]
    marks = Dict{T, Bool}()
    for key in keys(graph)
        if length(marks) == length(graph)
            break
        elseif ! haskey(marks, key) # We check that the node is not marked yet
            # We mark this new node
            marks[key] = true
            cc = BFS(graph, key)[1]

            # We mark the nodes that are in the connected component returned by BFS
            for node in cc
                marks[node] = true
            end
            push!(connected_components, cc)
        end
    end

    return connected_components
end

"""Computes a lower bound of the diameter of a graph.

The distance is the number of edges between two nodes.
"""
function diameter_lb(graph::AdjacencyList)
    node0 = highest_degree_node(graph)
    node1, _ = furthest_node(graph, node0)
    _, dist = furthest_node(graph, node1)
    return maximum(values(dist))
end

function highest_degree_node(graph::AdjacencyList{T}) where T
    max_deg = 0
    arg_max_degree = collect(Iterators.take(keys(graph), 1))[1]
    for (node, neighbour) in graph
        if length(neighbour) > max_deg
            arg_max_degree = node
        end
    end
    return arg_max_degree
end

function furthest_node(graph::AdjacencyList{T}, node::T) where T
    #get the connected components of node and distances from node
    cc_node, dist = BFS(graph, node)
    furthest = cc_node[end]#get the node that is the furthest from node
    return furthest, dist
end

main()
