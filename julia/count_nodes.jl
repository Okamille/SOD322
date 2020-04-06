"""Script for counting nodes and edges."""

function main(dir_path="../cleaned_data")
    for file in filter(x->occursin(".txt", x), readdir(dir_path))
        println(file[1:end-4], '\t', "Number of nodes : ", count_nodes("$dir_path/$file"))
        println('\t', "Number of edges : ",count_edges("$dir_path/$file"))
    end
end

function count_nodes(path::String)
    nodes = Dict{String, Bool}()
    open(path) do io
        readline(io)
        for line in eachline(io)
            n_s, n_t = split(line)
            nodes[n_s] = true
            nodes[n_t] = true
        end
    end
    return length(nodes)
end

function count_edges(path::String)
    return countlines(path)
end


main()
