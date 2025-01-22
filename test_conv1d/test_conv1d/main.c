#include <stdio.h>
#include "data.h"
#include <errno.h>

// Definizione corretta delle costanti
#define COLONNE_MEM 4
#define RIGHE_MEM 128

int mem[RIGHE_MEM][COLONNE_MEM] = { 0 };

void conv1d_testa(); // Dichiarazione della funzione
void replace_sample(int sample_block);
void replace_filter(int filter_block); // il blocco di filti puo essere o 0 o 1 nel caso in cui sto usando i primi 4 filtri o gli                                                                                                                       altri 4
void print_out(uint32_t matrix[8][124], int rows, int cols);
void print_mem_to_file(int mem[RIGHE_MEM][COLONNE_MEM], const char* filename);
void print_bin_mem_to_file(int mem[RIGHE_MEM][COLONNE_MEM], const char* filename);
void remove_spaces(const char* filename1, const char* filename2);
void decimalToBinary(int num, char* binaryStr);

int main() {
    int seq_filter = 0;
    int s=0, fg=0, m=0, j,z, i = 0;
    int inc = 0;  // Indice per accedere a F
    int bk = 0;
    int w_c = 0;
    int w_r = 0;
    int acc[4];
    int R[16];
    int done = 0;
   
    int app;
    int out_mat[8] = { 0 };
    int conv1d_calcolato[8][128];
    int col = 0;
    // Dichiarazione della matrice mem con le dimensioni definite
  

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
            for (w_r = 80; w_r < 80 + 8; w_r++) {

                mem[w_r + bk * 8][w_c] = A[inc];
                inc++;
            }
        }

    }
    j = 0;
    i = 0;
    conv1d_testa(); // calcolo via sw la convoluzione e la salvo in un file outpiut.txt
    //print_mem_to_file(mem, "mem.txt");

    //print_bin_mem_to_file(mem, "mem_bin.txt");

    //remove_spaces("mem_bin.txt", "mem_bin2_SETF2.txt");


    //---------------------------------------------------------
    // qui faccio la convoluzione
    for(z=0;z<16;z++){
    for (s = 0; s < 4; s++) {
        out_mat[0] =  0 ;
        out_mat[1] =  0 ;
        out_mat[2] =  0 ;
        out_mat[3] =  0 ;
        out_mat[4] =  0 ;
        out_mat[5] =  0 ;
        out_mat[6] =  0 ;
        out_mat[7] =  0 ;
        done = 0;
        for (fg = 0; fg < 2; fg++) {
         
            for (m = 0; m < 4; m++) {
                for (j = 0; j < 5; j++) {
                    for (i = 0; i < 4; i++) {
                         R[0 + 4 * i] = mem[i * 5 + j + m * 20][0] * mem[80 + i * 8 + j + s][0] ;
                         R[1 + 4 * i] = mem[i * 5 + j + m * 20][1] * mem[80 + i * 8 + j + s][1] ;
                         R[2 + 4 * i] = mem[i * 5 + j + m * 20][2] * mem[80 + i * 8 + j + s][2] ;
                         R[3 + 4 * i] =  mem[i * 5 + j + m * 20][3] * mem[80 + i * 8 + j + s][3] ;
                        acc[i] = R[0 + 4 * i] + R[1 + 4 * i] + R[2 + 4 * i] + R[3 + 4 * i];
                    }
                    app = acc[0] + acc[1] + acc[2] + acc[3];
                    out_mat[m+fg*4] = out_mat[m + fg * 4]+ app;
                    i = 0;
                }
                j = 0;
                i = 0;
            }
            if (seq_filter == 0) {
                seq_filter = 1;
            }
            else {
                seq_filter = 0;
            }
            replace_filter(seq_filter);

            m = 0;
            print_mem_to_file(mem, "mem.txt");

            print_bin_mem_to_file(mem, "mem_bin.txt");

            remove_spaces("mem_bin.txt", "mem_bin2_SETF2.txt");
          


        }
        done = 1;

        
            for (int riga = 0; riga < 8 ; riga++) {
                conv1d_calcolato[riga][col] = out_mat[riga];
            }
            col++;
       
    }
 

    replace_sample(z+1);

  
}
    



     
    
    //---------------------------------------------------------


    /*
    FILE* filePtr;
    filePtr = fopen("matrice_risultante.txt", "w");  // Apre il file in modalità scrittura

    if (filePtr == NULL) {
        printf("Errore: impossibile aprire il file.\n");
        return 1;  // Esce con codice di errore
    }

    // Scrive la matrice nel file
    fprintf(filePtr, "Matrice risultante:\n");
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 128; j++) {
            fprintf(filePtr, "%d ", conv1d_calcolato[i][j]);
        }
        fprintf(filePtr, "\n");
    }

    fclose(filePtr);  // Chiude il file
    */

 

    return 0;
}



//faccio scambio i filtri
void replace_filter(int filter_block) {
    int inc = 0;
    if (filter_block == 0) {
        for (int bk = 0; bk < 16; bk++) {
            for (int w_c = 0; w_c < 4; w_c++) {
                for (int w_r = 0; w_r < 5; w_r++) {

                    mem[w_r + bk * 5][w_c] = F[inc];
                    inc++;
                }
            }
        }
    }
    if (filter_block == 1) {
        for (int bk = 0; bk < 16; bk++) {
            for (int w_c = 0; w_c < 4; w_c++) {
                for (int w_r = 0; w_r < 5; w_r++) {

                    mem[w_r + bk * 5][w_c] = F[inc+320];
                    inc++;
                }
            }
        }
    }
}
//scambio i sample
void replace_sample(int sample_block) {
    int inc=0;
    for (int bk = 0; bk < 4; bk++) {
        for (int w_c = 0; w_c < 4; w_c++) {
            inc = w_c * 128 + bk * 512 + sample_block * 4;
            for (int w_r = 80; w_r < 80 + 8; w_r++) {

                mem[w_r + bk * 8][w_c] = A[inc];
                inc++;
            }
        }

    }
}


//stampa nel file output.txt il risultato della convoluzione calcolato via sw
void conv1d_testa() {
    int i=0;
    FILE* filePtr5;
    errno_t err;

    // Utilizza fopen_s per aprire il file in modalità scrittura
    err = fopen_s(&filePtr5, "output.txt", "w");

    if (err != 0) {
        // Se fopen_s fallisce, restituisce un errore
        printf("Impossibile aprire il file per la scrittura.\n");
        return; // Non restituire nulla, la funzione è di tipo void
    }
    int  pr_acc[16];
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
    
    int cm1, cm2, cm3, cm4, cm5;

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
        for (int i = 0; i < 16; i++) {
            cm1 = f0[i][0] * sample[i][0 + j];
            cm2 = f0[i][1] * sample[i][1 + j];
            cm3 = f0[i][2] * sample[i][2 + j];
            cm4 = f0[i][3] * sample[i][3 + j];
            cm5 = f0[i][4] * sample[i][4 + j];
            pr_acc[i] = cm1 + cm2 + cm3 + cm4 + cm5;
            out_matrix[0][j] += f0[i][0] * sample[i][0 + j] + f0[i][1] * sample[i][1 + j] + f0[i][2] * sample[i][2 + j] + f0[i][3] * sample[i][3 + j] + f0[i][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 16; i++) {
            out_matrix[1][j] += f1[i][0] * sample[i][0 + j] + f1[i][1] * sample[i][1 + j] + f1[i][2] * sample[i][2 + j] + f1[i][3] * sample[i][3 + j] + f1[i][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 16; i++) {
            
            out_matrix[2][j] += f2[i][0] * sample[i][0 + j] + f2[i][1] * sample[i][1 + j] + f2[i][2] * sample[i][2 + j] + f2[i][3] * sample[i][3 + j] + f2[i][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 16; i++) {
        
            out_matrix[3][j] += f3[i][0] * sample[i][0 + j] + f3[i][1] * sample[i][1 + j] + f3[i][2] * sample[i][2 + j] + f3[i][3] * sample[i][3 + j] + f3[i][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 16; i++) {
            out_matrix[4][j] += f4[i][0] * sample[i][0 + j] + f4[i][1] * sample[i][1 + j] + f4[i][2] * sample[i][2 + j] + f4[i][3] * sample[i][3 + j] + f4[i][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 16; i++) {
            out_matrix[5][j] += f5[i][0] * sample[i][0 + j] + f5[i][1] * sample[i][1 + j] + f5[i][2] * sample[i][2 + j] + f5[i][3] * sample[i][3 + j] + f5[i][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 16; i++) {
            out_matrix[6][j] += f6[i][0] * sample[i][0 + j] + f6[i][1] * sample[i][1 + j] + f6[i][2] * sample[i][2 + j] + f6[i][3] * sample[i][3 + j] + f6[i][4] * sample[i][4 + j];
        }

        for (int i = 0; i < 16; i++) {
            out_matrix[7][j] += f7[i][0] * sample[i][0 + j] + f7[i][1] * sample[i][1 + j] + f7[i][2] * sample[i][2 + j] + f7[i][3] * sample[i][3 + j] + f7[i][4] * sample[i][4 + j];
        }

        i = 0;
    }

    //----------------------------





  
    for (int i = 0; i < 8; i++) {  // Righe di out_matrix
        for (int j = 0; j < 128; j++) {  // Colonne di out_matrix
            fprintf(filePtr5, "%d ", out_matrix[i][j]);
        }
        // Non c'è bisogno di fprintf(filePtr, "\n"); per scrivere una nuova riga nel formato binario
    }

    // Chiude il file
    fclose(filePtr5);


}

// stampo a schermo la matrice
void print_out(uint32_t matrix[8][124], int rows, int cols) {
    // Ciclo sulle righe
    for (int i = 0; i < rows; i++) {
        // Ciclo sulle colonne
        for (int j = 0; j < cols; j++) {
            printf("%u ", matrix[i][j]);  
        }
        printf("\n");  // A capo dopo ogni riga
    }
}


//scrivo la matrice in un file.txt; mi serve per, attraverso matlab, scrivo l'excel che mi mostra come è organizzata attualmente 
//la memoria del mio conv1d
void print_mem_to_file(int mem[RIGHE_MEM][COLONNE_MEM], const char* filename) {
    FILE* filePtr;
    errno_t err;

    // Apri il file in modalità scrittura
    err = fopen_s(&filePtr, filename, "w");

    if (err != 0) {
        // Se fopen_s fallisce, mostra un errore
        printf("Impossibile aprire il file per la scrittura.\n");
        return;
    }

    // Scrivi i dati di mem nel file
    for (int i = 0; i < RIGHE_MEM; i++) {
        for (int j = 0; j < COLONNE_MEM; j++) {
            fprintf(filePtr, "%d ", mem[i][j]);  // Scrive ogni valore
        }
        fprintf(filePtr, "\n");  // Nuova riga dopo ogni riga della matrice
    }

    // Chiudi il file
    fclose(filePtr);
    printf("Matrice mem scritta correttamente nel file %s\n", filename);
}



void decimalToBinary(int num, char* binaryStr) {
    // Conversione di un numero in binario e memorizzazione in una stringa
    binaryStr[8] = '\0'; // Aggiunge il terminatore di stringa
    for (int i = 7; i >= 0; i--) {
        binaryStr[7 - i] = (num % 2) + '0';
        num /= 2;
    }
    int len = 8;
    for (int i = 0; i < len / 2; i++) {
        // Scambia gli elementi agli estremi opposti
        char temp = binaryStr[i];
        binaryStr[i] = binaryStr[len - i - 1];
        binaryStr[len - i - 1] = temp;
    }
    
}

void print_bin_mem_to_file(int mem[RIGHE_MEM][COLONNE_MEM], const char* filename) {
    FILE* filePtr;
    errno_t err;

    // Apri il file in modalità scrittura
    err = fopen_s(&filePtr, filename, "w");

    if (err != 0) {
        // Se fopen_s fallisce, mostra un errore
        printf("Impossibile aprire il file per la scrittura.\n");
        return;
    }

    // Scrivi i dati di mem nel file in formato binario
    char binaryStr[9] = { 0 };
    for (int i = 0; i < RIGHE_MEM; i++) {
        for (int j = 0; j < COLONNE_MEM; j++) {
            decimalToBinary(mem[i][j], binaryStr); // Converte il numero in binario
            fprintf(filePtr, "%s ", binaryStr);  // Scrive il valore binario
        }
        fprintf(filePtr, "\n");  // Nuova riga dopo ogni riga della matrice
    }

    // Chiudi il file
    fclose(filePtr);
    printf("Matrice mem scritta correttamente nel file %s\n", filename);
   
}
void remove_spaces(const char* filename1, const char* filename2) {
   
    char ch;
    FILE* filePtr1;
    FILE* filePtr2;
    errno_t err;

    // Apri il primo file in modalità lettura
    err = fopen_s(&filePtr1, filename1, "r");
    if (err != 0) {
        // Se fopen_s fallisce, mostra un errore
        printf("Impossibile aprire il file di input.\n");
        return;
    }

    // Apri il secondo file in modalità scrittura
    err = fopen_s(&filePtr2, filename2, "w");
    if (err != 0) {
        // Se fopen_s fallisce, mostra un errore
        printf("Impossibile aprire il file di output.\n");
        fclose(filePtr1); // Chiudi il primo file se il secondo fallisce
        return;
    }
  
    // Leggi ogni carattere dal file di input
    while (fscanf_s(filePtr1, "%c", &ch) != EOF) {
        //printf("Lettura carattere: %c\n", ch);  // Debug: stampa ogni carattere letto
        if (ch != ' ') {
            // Scrivi il carattere nel file di output se non è uno spazio
            fprintf(filePtr2, "%c", ch);
        }
    }

    // Controllo se il file di output contiene qualcosa
    fflush(filePtr2);  // Assicurati che tutti i dati siano scritti nel file
    printf("Scrittura completata.\n");

    // Chiudi entrambi i file
    fclose(filePtr1);
    fclose(filePtr2);
}