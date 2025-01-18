#include <stdio.h>
#include "data.h"

// Definizione corretta delle costanti
#define COLONNE_MEM 4
#define RIGHE_MEM 128

void conv1d_testa(); // Dichiarazione della funzione
void replace_sample();
void replace_filter();
void print_out(uint32_t matrix[8][124], int rows, int cols);

int main() {
    // con1d_testa();
    int s, fg, m, j,z, i = 0;
    int inc = 0;  // Indice per accedere a F
    int bk = 0;
    int w_c = 0;
    int w_r = 0;
    int acc[5];
    int R[16];
    int ACC[4];
    int app;
    int out_mat[8][4];

    // Dichiarazione della matrice mem con le dimensioni definite
    int mem[RIGHE_MEM][COLONNE_MEM] = { 0 };

    // Ciclo per copiare i dati dalla matrice F a mem
    for (int bk = 0; bk < 16; bk++) {
        for (int w_c = 0; w_c < 4; w_c++) {
            for (int w_r = 0; w_r < 5; w_r++) {

                mem[w_r + bk * 5][w_c] = F[inc];
                inc++;
            }
        }
    }
    inc = 0;
    bk = 0;
    w_c = 0;
    for (bk = 0; bk < 4; bk++) {
        for (w_c = 0; w_c < 4; w_c++) {
            inc = w_c * 128 + bk * 512;
            for (w_r = 80; w_r < 80 + 9; w_r++) {

                mem[w_r + bk * 9][w_c] = A[inc];
                inc++;
            }
        }

    }

    conv1d_testa();

    //---------------------------------------------------------
    // qui faccio la convoluzione
    for(z=0;z<1;z++){
    for (s = 0; s < 3; s++) {
        for (fg = 0; fg < 2; fg++) {
            for (m = 0; m < 3; m++) {
                for (j = 0; j - 5; j++) {
                    for (i = 0; i < 3; i++) {
                         R[0 + 4 * i] = mem[i * 5 + j + m * 20][0] * mem[80 + i * 9 + j + s][0] ;
                         R[1 + 4 * i] = mem[i * 5 + j + m * 20][1] * mem[80 + i * 9 + j + s][1] ;
                         R[2 + 4 * i] = mem[i * 5 + j + m * 20][2] * mem[80 + i * 9 + j + s][2] ;
                         R[3 + 4 * i] =  mem[i * 5 + j + m * 20][3] * mem[80 + i * 9 + j + s][3] ;
                        acc[i] = R[0 + 4 * i] + R[1 + 4 * i] + R[2 + 4 * i] + R[3 + 4 * i];
                    }
                    app = acc[0] + acc[1] + acc[2] + acc[3] + acc[4];
                    out_mat[m][s] += app;
                    i = 0;
                }
                j = 0;
                i = 0;
            }

            m = 0;

        }
        replace_filter();
       
    }
    replace_sample();
    print_out(out_mat, 8, 1);
}
    



     
    
    //---------------------------------------------------------


    // Stampa della matrice mem per vedere i dati copiati
    i = 0;
    printf("%d :  ", i);
    for (i = 0; i < RIGHE_MEM; i++) {
        for (j = 0; j < COLONNE_MEM; j++) {
            printf("%d ", mem[i][j]);  // Stampa ogni elemento
        }
        
        printf("\n");  // Nuova riga per ogni riga della matrice
        printf("%d :  ", i+1);
    }

    return 0;
}




void replace_filter() {
 
}

void replace_sample() {

}
void conv1d_testa() {
    FILE* filePtr;
    errno_t err;

    // Utilizza fopen_s per aprire il file in modalità scrittura
    err = fopen_s(&filePtr, "output.txt", "w");

    if (err != 0) {
        // Se fopen_s fallisce, restituisce un errore
        printf("Impossibile aprire il file per la scrittura.\n");
        return; // Non restituire nulla, la funzione è di tipo void
    }

    int cnt = 0;
    int sample[16][128] = { 0 };
    int f0[16][5] = { 0 };
    int f1[16][5] = { 0 };
    int f2[16][5] = { 0 };
    int f3[16][5] = { 0 };
    int f4[16][5] = { 0 };
    int f5[16][5] = { 0 };
    int f6[16][5] = { 0 };
    int f7[16][5] = { 0 };
    uint32_t out_matrix[8][124] = { 0 };
    


    // Riempie il campione con i dati da A
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 128; i++) {
            sample[j][i] = A[cnt];
            cnt++;
        }
    }
    cnt = 0;
    // Riempie il campione con i dati da A
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f0[j][i] = F[cnt];
            cnt++;
        }
    }
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f1[j][i] = F[cnt];
            cnt++;
        }
    }
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f2[j][i] = F[cnt];
            cnt++;
        }
    }
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f3[j][i] = F[cnt];
            cnt++;
        }
    }
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f4[j][i] = F[cnt];
            cnt++;
        }
    }
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f5[j][i] = F[cnt];
            cnt++;
        }
    }
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f6[j][i] = F[cnt];
            cnt++;
        }
    }
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f7[j][i] = F[cnt];
            cnt++;
        }
    }


    //---------------------------
    
//convoluzione
    for (int j = 0; j < 124; j++) {
        for (int i = 0; i < 15; i++) {
            out_matrix[0][j] += f0[i][0] * sample[i][0 + j] + f0[i][1] * sample[i][1 + j] + f0[i][2] * sample[i][2+j] + f0[i][3] * sample[i][3+j] + f0[0][4] * sample[i][4+j];
        }

        for (int i = 0; i < 15; i++) {
            out_matrix[1][j] += f1[i][0] * sample[i][0 + j] + f1[i][1] * sample[i][1 + j] + f1[i][2] * sample[i][2 + j] + f1[i][3] * sample[i][3 + j] + f1[0][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 15; i++) {
            out_matrix[2][j] += f2[i][0] * sample[i][0 + j] + f2[i][1] * sample[i][1 + j] + f2[i][2] * sample[i][2 + j] + f2[i][3] * sample[i][3 + j] + f2[0][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 15; i++) {
            out_matrix[3][j] += f3[i][0] * sample[i][0 + j] + f3[i][1] * sample[i][1 + j] + f3[i][2] * sample[i][2 + j] + f3[i][3] * sample[i][3 + j] + f3[0][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 15; i++) {
            out_matrix[4][j] += f4[i][0] * sample[i][0 + j] + f4[i][1] * sample[i][1 + j] + f4[i][2] * sample[i][2 + j] + f4[i][3] * sample[i][3 + j] + f4[0][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 15; i++) {
            out_matrix[5][j] += f5[i][0] * sample[i][0 + j] + f5[i][1] * sample[i][1 + j] + f5[i][2] * sample[i][2 + j] + f5[i][3] * sample[i][3 + j] + f5[0][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 15; i++) {
            out_matrix[6][j] += f6[i][0] * sample[i][0 + j] + f6[i][1] * sample[i][1 + j] + f6[i][2] * sample[i][2 + j] + f6[i][3] * sample[i][3 + j] + f6[0][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 15; i++) {
            out_matrix[7][j] += f7[i][0] * sample[i][0 + j] + f7[i][1] * sample[i][1 + j] + f7[i][2] * sample[i][2 + j] + f7[i][3] * sample[i][3 + j] + f7[0][4] * sample[i][4 + j];
        }


    }

    //----------------------------





  
    for (int i = 0; i < 8; i++) {  // Righe di out_matrix
        for (int j = 0; j < 128; j++) {  // Colonne di out_matrix
            fprintf(filePtr, "%d ", out_matrix[i][j]);
        }
        // Non c'è bisogno di fprintf(filePtr, "\n"); per scrivere una nuova riga nel formato binario
    }

    // Chiude il file
    fclose(filePtr);
    return;

}

// Funzione per stampare una matrice di tipo uint32_t
void print_out(uint32_t matrix[8][124], int rows, int cols) {
    // Ciclo sulle righe
    for (int i = 0; i < rows; i++) {
        // Ciclo sulle colonne
        for (int j = 0; j < cols; j++) {
            printf("%u ", matrix[i][j]);  // Stampa ogni elemento come unsigned int
        }
        printf("\n");  // A capo dopo ogni riga
    }
}