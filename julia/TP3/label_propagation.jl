module LabelPropagation

using Random: randperm
using StatsBase: countmap

export label_propagation!

AdjacencyList{T} = Vector{Vector{T}}

function label_propagation!(graph::AdjacencyList{UInt})
    labelled_graph = label_graph(graph)
    labels = collect(1:length(graph))
    stable_labels = false
    while ! stable_labels
        shuffle!(graph, labels)
        stable_labels = reassign_labels!(graph, labels)
    end
    return graph, labels
end

function reassign_labels!(graph, labels)
    new_labels = Array{Int}(undef, 0, 2)
    for ((node, node_neighbours), label) in zip(graph, labels)
        neighbours_labels = countmap(labels[neighbour]
                                     for neighbour in node_neighbours)
        most_frequent_label, _ = findmax(neighbours_labels)
        if most_frequent_label != label
            push!(new_labels, [node, most_frequent_label])
        end
    end
    for (node, label) in new_labels
        labels[node] = label
    end
    return length(new_labels) == 0
end

function label_graph(graph::AdjacencyList{UInt})
    labels = collect(1:length(graph))
    labelled_graph = zip(labels, graph)
    return labelled_graph
end

function shuffle!(graph::AdjacencyList{UInt}, labels::Vector{})
    permutation = randperm(length(labels))
    permute!(graph, permutation)
    permute!(graph, labels)
end

end