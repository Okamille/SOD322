include("graph.jl")
using LinearAlgebra
using ProgressBars

function augmented_transition(graph)
    I = Vector{Int64}()
    J = Vector{Int64}()
    V = Vector{Float64}()

    n = graph.n

    println("Computing augmented transition matrix")
    println("Computing on the edges")
    edges = findall(!iszero, graph.transition_matrix)
    for edge in ProgressBar(edges)
        u = edge[1]
        v = edge[2]
        push!(I, v)
        push!(J, u)
        push!(V, 1/graph.degree_out[u])
    end
    """println("Computing dead ends")
    for u in ProgressBar(1:n)
        if graph.degree_out[u] == 0
            for v in 1:n
                push!(I, v)
                push!(J, u)
                push!(V, 1/n)
            end
        end
    end
    """
    return sparse(I, J, V, n, n)
end

function custom_normalize!(P::Array{Float64,1})
    P0 = norm(P, 1)
    for i in 1:length(P)
        P[i] += (1 - P0) / length(P)
    end
end

function poweriteration(graph::Graph, alpha::Float64, t::Int64)
    # Computing transition matrix of the graph
    T = augmented_transition(graph)
    n = graph.n
    P = 1/n * ones(n)
    for i in ProgressBar(1:t)
        P = T * P
        P = (1 - alpha) * P + alpha * ones(n)
        custom_normalize!(P)
    end

    return P
end

