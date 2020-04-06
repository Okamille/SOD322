include("../LoadGraph/LoadGraph.jl")
using .LoadGraph

function main(dir_path="../../cleaned_data", dtype::Type=UInt32)
    for file in filter(x->endswith(x, ".txt"), readdir(dir_path))
        println(file[1:end-4])
        try
            @time load_adjacency_list("$dir_path/$file", dtype)
        catch OutOfMemoryError
            println("OOM")
        end
        try
            @time load_edge_list("$dir_path/$file", dtype)
        catch OutOfMemoryError
            println("OOM")
        end
        try
            @time load_adjacency_matrix("$dir_path/$file")
        catch OutOfMemoryError
            println("OOM")
        end
        println()
    end
end

main()
