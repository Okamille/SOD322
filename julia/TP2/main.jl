include("graph.jl")
include("poweriteration.jl")
include("utils.jl")

using PyPlot;

filename = "../data/alr21--dirLinks--enwiki-20071018.txt"
index_filename = "../data/alr21--pageNum2Name--enwiki-20071018.txt"
data_path = "../res/"

graph = Graph(filename)

alphas = [0.15, 0.1, 0.2, 0.5, 0.9]

P = Dict()

for alpha in alphas
    P[string(alpha)] = poweriteration(graph, alpha, 100)
end

# X = P[alpha=0.15] / Y = degree_in
figure()
scatter(x=P["0.15"], y=graph.degree_in, s=0.2)
title("X : P alpha = 0.15 / Y = In-degrees")
savefig(string(data_path, "015in.png"))

# X = P[alpha=0.15] / Y = degree_out
figure()
scatter(x=P["0.15"], y=graph.degree_out, s=0.2)
title("X : P alpha = 0.15 / Y = Out-degrees")
savefig(string(data_path, "015out.png"))

# X = P[alpha = 0.15] / Y = P[alpha = 0.1]
figure()
scatter(x=P["0.15"], y=P["0.1"], s=0.2)
title("X = P[alpha = 0.15] / Y = P[alpha = 0.1]")
savefig(string(data_path, "01501.png"))

# X = P[alpha = 0.15] / Y = P[alpha = 0.2]
figure()
scatter(x=P["0.15"], y=P["0.2"], s=0.2)
title("X = P[alpha = 0.15] / Y = P[alpha = 0.2]")
savefig(string(data_path, "01502.png"))

# X = P[alpha = 0.15] / Y = P[alpha = 0.5]
figure()
scatter(x=P["0.15"], y=P["0.5"], s=0.2)
title("X = P[alpha = 0.15] / Y = P[alpha = 0.5]")
savefig(string(data_path, "01505.png"))

# X = P[alpha = 0.15] / Y = P[alpha = 0.9]
figure()
scatter(x=P["0.15"], y=P["0.9"], s=0.2)
title("X = P[alpha = 0.15] / Y = P[alpha = 0.9]")
savefig(string(data_path, "01509.png"))