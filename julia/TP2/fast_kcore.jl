using SparseArrays
using DelimitedFiles: readdlm
using ProgressBars

function fast_kcore(nodes::Vector{Int64}, edges::Matrix{Int64})
    println("Computing adjacency list")
    adjacency_list = Dict{Int64, Vector{Int64}}()
    for i in 1:n
        adjacency_list[i] = Vector{Int64}()
    end
    for edge in eachrow(edges)
         neighbors = get!(Vector{Int64}, adjacency_list, edge[1])
         push!(neighbors, edge[2])
         neighbors = get!(Vector{Int64}, adjacency_list, edge[2])
         push!(neighbors, edge[1])
    end

    degrees = zeros(Int64, n)

    for edge in eachrow(edges)
        degrees[edge[1]] += 1
        degrees[edge[2]] += 1
    end

    max_degree = maximum(degrees)
    eta = Dict{Int64, Int64}()
    c = 0
    for i in ProgressBar(1:n)
        v = argmin(degrees)
        c = max(c, degrees[v])
        eta[v] = c
        degrees[v] = max_degree + 1
        for neighbor in adjacency_list[v]
            degrees[neighbor] -= 1
        end
    end

    return eta
end

filename = "com-amazon.ungraph.txt"
edges = readdlm(filename, '\t', Int, comments=true)
nodes = Vector(1:maximum(edges))
core_numbers = fast_kcore(nodes, edges)