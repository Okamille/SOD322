#!/bin/bash

for graph in amazon lj orkut friendster
do
    graph_file=com-$graph.ungraph.txt
    awk '{if ($1 ~ /^[0-9]+$/) {if ($1<$2) print $1" "$2;else if ($2<$1) print $2" "$1}}' data/$graph_file | uniq > cleaned_data/$graph.txt
done

graph_file=email-Eu-core.txt
awk '{if ($1 ~ /^[0-9]+$/) {if ($1<$2) print $1" "$2;else if ($2<$1) print $2" "$1}}' data/$graph_file | uniq > cleaned_data/$graph_file
