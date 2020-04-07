using SparseArrays
using DelimitedFiles: readdlm
using ProgressBars
using PyPlot

function fast_kcore(nodes::Vector{Int64}, edges::Matrix{Int64})
    n = length(nodes)
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
@time core_numbers = fast_kcore(nodes, edges)
println("Core value for ", filename, " = ", maximum(values(core_numbers)))

filename = "com-lj.ungraph.txt"
edges = readdlm(filename, '\t', Int, comments=true)
edges = edges .+ 1
nodes = Vector(1:maximum(edges))
@time core_numbers = fast_kcore(nodes, edges)
println("Core value for ", filename, " = ", maximum(values(core_numbers)))

filename = "scholar/net.txt"
edges = readdlm(filename, '\t', Int, comments=true)
edges = edges .+ 1
nodes = Vector(1:maximum(edges))
@time core_numbers = fast_kcore(nodes, edges)

n = length(nodes)
degrees = zeros(Int64, n)
for edge in eachrow(edges)
    degrees[edge[1]] += 1
    degrees[edge[2]] += 1
end

coreness = zeros(Int64, n)
for key in keys(core_numbers)
    coreness[key] = core_numbers[key]
end

density = zeros(Int64, maximum(degrees), maximum(coreness))
for i in 1:n
    density_matrix[degrees[i], coreness[i]] += 1
end

a = Vector()
b = Vector()
c = Vector()

for element in findall(!iszero, density)
    push!(a, element[1])
    push!(b, element[2])
    push!(c, density[element])
end

figure()
title("Google scholar dataset")
scatter(x=a, y=b, c=c, s = c/maximum(c) * 2000)
xscale("log")
xlabel("Degree")
ylabel("Coreness")
colorbar()
plot(1:14, 1:14, c="black")