#!/bin/bash

echo "Number of edges + 1 graph"
echo "Number of nodes + 2"
echo " "

for graph in email-Eu-core amazon lj orkut friendster
do
    wc -l cleaned_data/$graph.txt
    tr ' ' '\n' < cleaned_data/$graph.txt | sort | uniq -c | wc -l
    echo " "
done
