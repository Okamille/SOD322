cmake_minimum_required(VERSION 3.0)

project(ro)

set(SRCS
    src/utils.c
    src/adjarray.c
    src/adjmatrix.c
    src/edgelist.c
    )

set(HEADERS
    headers/utils.h
    headers/adjarray.h
    headers/adjmatrix.h
    headers/edgelist.h
    )

set(QUESTIONS q1 pagerank)

foreach(QUESTION IN LISTS QUESTIONS)
    message(STATUS "Creating ${QUESTION}")
    add_executable(${QUESTION} ${SRCS} ${QUESTION}.c ${HEADERS})
endforeach()