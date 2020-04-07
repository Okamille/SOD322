using LightGraphs;
using Random;
using GraphPlot;
using Compose;

nb_nodes = 400
nb_clusters = 4
p = [0.1, 0.3, 0.5, 0.9]
q = 0.1

function generate_graph(p::Float64, q::Float64, nb_nodes::Int64, nb_clusters::Int64)

    clusters = Vector{Int64}()
    for j in 1:nb_clusters
        for i in 1:Int(floor(nb_nodes//nb_clusters))
            push!(clusters, j)
        end
    end

    edges = Vector{Tuple{Int64, Int64}}()
    for i1 in 1:nb_nodes
        for i2 in i1:nb_nodes
            r = rand()
            
            if clusters[i1]==clusters[i2]
                if r < p
                    push!(edges, (i1, i2))
                end
            else
                if r < q
                    push!(edges, (i1, i2))
                end
            end
        end
    end

    # Create networkx graph object
    g = SimpleGraph(nb_nodes)
    for edge in edges
        add_edge!(g, edge[1], edge[2])
    end

    return g, clusters
end

for p_i in p
    g, y = generate_graph(p_i, q, nb_nodes, nb_clusters)
    draw(PNG(string("../res/", p_i, "_clusters.png"), 16cm, 16cm), gplot(g))
end

