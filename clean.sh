#!/bin/bash

for graph_name in email-Eu-core com-amazon.ungraph com-lj.ungraph com-orkut.ungraph com-friendster.ungraph
do
    awk '{if ($1<$2) print $1" "$2;else if ($2<$1) print $2" "$1}' data/$graph_name.txt | sort -n -k1,2 -u > cleaned_data/$graph_name.txt
done
