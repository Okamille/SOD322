using ProgressBars
using SparseArrays


struct Graph
    transition_matrix::SparseMatrixCSC{Int64, Int64}
    nodes::Vector{Int64}
    edges::Vector{Tuple{Int64, Int64}}
    degree_out::Vector{Int64}
    degree_in::Vector{Int64}
    n::Int32
    function Graph(T, nodes, edges, degree_out, degree_in, n)
        new(T, nodes, edges, degree_out, degree_in, n)
    end
    function Graph(filename)
        # Read edges and nodes from filename
        io = open(filename)
        lines = readlines(io)
        
        edges = Vector{Tuple{Int64, Int64}}()

        I = Vector{Int64}()
        J = Vector{Int64}()        

        println("Loading graph in memory")
        maxI = 0
        maxJ = 0
        for (index, line) in ProgressBar(enumerate(lines))
            if !startswith(line, "#") && line != ""
                r = r"(\w+)[\t\s](\w+)"
                i1, i2 = match(r, line).captures
                i1 = parse(Int64, i1)
                i2 = parse(Int64, i2)
                push!(I, i1)
                push!(J, i2)

                push!(edges, (i1, i2))

                if i1 > maxI
                    maxI = i1
                end

                if i2 > maxJ
                    maxJ = i2
                end
            end
        end

        n = max(maxI, maxJ)

        nodes = Vector{Int64}(1:n)

        degree_out = zeros(n)
        degree_in = zeros(n)
        for i in 1:length(I)
            u = I[i]
            v = J[i]
            degree_out[u] += 1
            degree_in[v] += 1
        end

        V = ones(Int64, length(I))
        transition_matrix = sparse(I, J, V, n, n)
        new(transition_matrix, nodes, edges, degree_out, degree_in, n)
    end
    
end


function remove_node(graph::Graph, node::Int64)

end