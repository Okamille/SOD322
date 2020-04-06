using DataStructures: Queue, enqueue!, dequeue!, isempty

include("../LoadGraph/LoadGraph.jl")
using .LoadGraph: load_adjacency_list, AdjacencyList

function main(dir_path="../../cleaned_data", dtype::Type=Int32)
    for file in filter(x->occursin(".txt", x), readdir(dir_path))
        println("===========",file,"===========")
        @time graph = load_adjacency_list("$dir_path/$file", dtype)
        @time cc = BFS(graph, one(dtype))
        @time all = all_connected_components(graph)
        @time diameter(graph)
    end
end

function BFS(graph::AdjacencyList{T}, node::T) where T
    fifo = Queue{T}()
    enqueue!(fifo, node)
    marks = Dict{T, Bool}([(node, true)])
    distances = Dict{T, Int}([(node, 0)])

    connected_components = Vector{T}()
    while ! isempty(fifo)
        u = dequeue!(fifo)
        push!(connected_components, u)
        for v in graph[u]
            if ! haskey(marks, v)
                enqueue!(fifo, v)
                marks[v] = true
                distances[v] = distances[u]+1
            end
        end
    end
    return [connected_components, distances]
end

function all_connected_components(graph::AdjacencyList{T}) where T<:Real
    println("all connected components of the graph")
    
    connected_components = []
    marks = Dict{T, Bool}()
    for key in keys(graph)
        if ! haskey(marks, key) #we check taht the node is not marked yet
            #we mark this new node
            marks[key] = true
            cc = BFS(graph, key)[1]
            
            #we mark the nodes that are in the connected component returned by BFS
            for node in cc
                marks[node] = true
            end
            
            push!(connected_components, cc)
            println(cc)
            println("of size = ", length(cc))
        end
    end
    println("franction of nodes in the largest connected component :\n", length(graph)/maximum([length(cc) for cc in components]))
    return connected_components
end


function diameter(graph::AdjacencyList{T}) where T<:Real
    
    sample = [k for k in keys(graph)]
    
    #choose random node
    node0 = sample[rand(1:length(sample))]
    
    #get the connected components of node0 and distances from node0
    cc_node0, dist_0 = BFS(graph, node0)
    node1 = cc_node0[end]#get the node that is more far away from node0
        
    #get the connected components of node1 and distances from node1
    cc_node1, dist_1 = BFS(graph, node1)
    node2 = cc_node1[end]#get the node that is more far away from node01
    
    diam = maximum(values(dist_1)) #maximal distance from node_1
    println("A lower bound of the diameter of the graph is : \n", diam)

end

main()