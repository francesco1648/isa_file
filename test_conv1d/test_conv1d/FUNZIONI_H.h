
#ifndef FUNZIONI_H
#define FUNZIONI_H

#include <stdint.h>  // Per uint32_t
#define COLONNE_OUT 4
#define RIGHE_OUT 128

#define COLONNE_MEM 4
#define RIGHE_MEM 128

void conv1d_testa();  // Dichiarazione della funzione
void replace_sample();
void replace_filter();
void print_out(uint32_t matrix[8][124], int rows, int cols); 




#endif