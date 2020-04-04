include("poweriteration.jl")

# This code generates a dictionnary where index -> page_name

function get_index_to_page(filename)    
    io = open(filename)
    lines = readlines(io)
    dictionnary = Dict()
    println("Construction index to page dictionnary")
    for line in ProgressBar(lines)
        if !startswith(line, "#") && line != ""
            index = ""
            page = ""
            is_index = true
            for element in line
                if element == '\t'
                    is_index = false
                else
                    if is_index
                        index = string(index, element)
                    else
                        page = string(page, element)
                    end
                end
            end
            dictionnary[index] = page
        end
    end

    return dictionnary
end