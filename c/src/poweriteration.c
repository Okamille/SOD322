#include "../headers/poweriteration.h"

matrix matvectprod(matrix M, matrix a){

    unsigned long n = M.n;
    unsigned long m = M.m;
    matrix b;
    b.m = 1;
    b.n = n;
    for(unsigned long i = 0; i<n; i++){
        b.values[i] = 0;
    }

    for(unsigned long i = 0; i<n; i++){
        for(unsigned long j = 0; j<m; j++){
            if(M.values[i*n + j] != 0){
                b.values[i] += M.values[i*n + j] * a.values[j];
            }
        }
    }

    return b;
}

matrix matprod(double alpha, matrix* a){
    matrix b;
    b.m = a->m;
    b.n = a->n;
    for(unsigned long i = 0; i<b.n;i++){
        for(unsigned long j = 0;j<b.m;j++){
            b.values[i*b.n + j] = alpha * a->values[i * b.n + j];
        }
    }

    return b;
}

matrix matsum(matrix* a, matrix* b) {
    matrix c;
    c.m = a->m;
    c.n = a->n;
    for(unsigned long i = 0; i<c.n;i++){
        for(unsigned long j = 0;j<c.m;j++){
            c.values[i*c.n + j] = a->values[i * c.n + j] + b->values[i * c.n + j];
        }
    }

    return c;
}

// Power iteration algorithm, T is the transition matrix
matrix poweriteration(matrix T, double alpha, unsigned long iter){
    unsigned long n = T.n;
    unsigned long m = T.m;
    matrix P; P.n = n; P.m = 1;
    // P = 1/n * Id
    for(unsigned long i = 0; i<n; i++){
        P.values[i] = 1;
    }

    for(int t = 0; t < iter; t++){
        P = matvectprod(T, P);
        P = matsum(matprod((1 - alpha), &P), alpha * I);
    }
}