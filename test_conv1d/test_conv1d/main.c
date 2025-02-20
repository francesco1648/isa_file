#include <stdio.h>
#include "data.h"
#include <errno.h>
#include <inttypes.h>  // Includi la libreria necessaria per PRIx32

// Definizione corretta delle costanti
#define COLONNE_MEM 4
#define RIGHE_MEM 128
#define RIGHE_MEM_8 119
#define NUM_FILTERS 8  // Numero di filtri f0, f1, ..., f7
#define FILTER_SIZE 5   // Ogni filtro ha 5 colonne
#define ROWS 16
#define COLS 124

uint8_t mem[RIGHE_MEM][COLONNE_MEM] = { 0 };

/**
 * @brief Calculate the convolution in software with unsigned data and print the results in a file output_sw_unsigned.txt
 * @param 
 * @param 
 * @return 
 */
void conv1d_sw_u(); 

/**
 * @brief Calculate the convolution in software with signed data and print the results in a file output_sw_signed.txt
 * @param 
 * @param 
 * @return 
 */
void conv1d_sw_s();

/**
 * @brief Perform the replacement of samples based on the specified sample_block.
 * @param sample_block.
 * @param 
 * @return 
 */
void replace_sample(int sample_block); 

/**
 * @brief Perform the replacement of filters based on the specified filter_block.
 * @param a filter_block
 * @param  
 * @return
 */
void replace_filter(int filter_block); 

/**
 * @brief Somma due numeri interi.
 * @param a Il primo numero.
 * @param b Il secondo numero.
 * @return La somma di a e b.
 */
void print_out(uint8_t matrix[128][4], int rows, int cols);


/**
 * @brief Print the current state of memory to a file in decimal format.
 * @param mem[RIGHE_MEM][COLONNE_MEM].
 * @param filename.
 * @return 
 */
void print_mem_to_file(uint8_t mem[RIGHE_MEM][COLONNE_MEM], const char* filename);

/**
 * @brief Print the current state of memory to a file in hexadecimal format.
 * @param mem[RIGHE_MEM][COLONNE_MEM].
 * @param filename
 * @return 
 */
void print_hex_mem_to_file(uint8_t mem[RIGHE_MEM][COLONNE_MEM], const char* filename);

/**
 * @brief Print the current state of memory to a file in binary format.
 * @param mem[RIGHE_MEM][COLONNE_MEM].
 * @param filename
 * @return 
 */
void print_bin_mem_to_file(uint8_t mem[RIGHE_MEM][COLONNE_MEM], const char* filename);


/**
 * @brief Remove spaces from a filename1 and write the result to filename2.
 * @param filename1.
 * @param filename2.
 * @return 
 */
void remove_spaces(const char* filename1, const char* filename2); //

/**
 * @brief Convert decimal to binary.
 * @param num decimal
 * @param num binary.
 * @return 
 */
void decimalToBinary(int num, char* binaryStr);                        

int main() {
    int seq_filter = 0;
    int s=0, fg=0, m=0, j,z, i = 0;
    int inc = 0;  
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
    int flag_s0_f1=1;  //flag for write s0_f1 in a file 
    int flag_s1_f0 = 1;
    int flag_s1_f1 = 0;

    // Loop to copy data from matrix F to mem.
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


    //Loop to copy data from matrix A to mem.
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

    conv1d_sw_u(); //Calculate the convolution via software and save it in a file output_sw_unsigned.txt.

    conv1d_sw_s(); //Calculate the convolution via software and save it in a file output_sw_signed.txt.

    print_mem_to_file(mem, "mem_s0_f0_dec_spaces.txt");

    print_hex_mem_to_file(mem, "mem_s0_f0_hex_spaces.txt");

    print_bin_mem_to_file(mem, "mem_s0_f0_bin_spaces.txt");

    remove_spaces("mem_s0_f0_bin_spaces.txt", "mem_s0_f0.txt");


    //---------------------------------------------------------
     z=0;
     s = 0; fg = 0;

     m = 0; j = 0;
     i = 0;



     //Perform the convolution by executing the same algorithm that the hardware runs
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
            if (flag_s0_f1 == 1) {
                print_mem_to_file(mem, "mem_s0_f1_dec_spaces.txt");

                print_hex_mem_to_file(mem, "mem_s0_f1_hex_spaces.txt");

                print_bin_mem_to_file(mem, "mem_s0_f1_bin_spaces.txt");

                remove_spaces("mem_s0_f1_bin_spaces.txt", "mem_s0_f1.txt");
                flag_s0_f1 = 0;
            }
            if (flag_s1_f1 == 1) {
                print_mem_to_file(mem, "mem_s1_f1_dec_spaces.txt");

                print_hex_mem_to_file(mem, "mem_s1_f1_hex_spaces.txt");

                print_bin_mem_to_file(mem, "mem_s1_f1_bin_spaces.txt");

                remove_spaces("mem_s1_f1_bin_spaces.txt", "mem_s1_f1.txt");
          
                flag_s1_f1 = 0;
            }



        }
        done = 1;

        
            for (int riga = 0; riga < 8 ; riga++) {
                conv1d_calcolato[riga][col] = out_mat[riga];
            }
            col++;
       
    }
 

    replace_sample(z+1);
    if (flag_s1_f0 == 1) {
        print_mem_to_file(mem, "mem_s1_f0_dec_spaces.txt");

        print_hex_mem_to_file(mem, "mem_s1_f0_hex_spaces.txt");

        print_bin_mem_to_file(mem, "mem_s1_f0_bin_spaces.txt");

        remove_spaces("mem_s1_f0_bin_spaces.txt", "mem_s1_f0.txt");
        flag_s1_f0 = 0;
        flag_s1_f1 = 1;
    }

  
}
    



     
    
    //---------------------------------------------------------


    
   /* FILE* filePtr1;
    filePtr1 = fopen("output_hw_signed.txt", "w");  // Apre il file in modalità scrittura

    if (filePtr1 == NULL) {
        printf("Errore: impossibile aprire il file.\n");
        return 1;  // Esce con codice di errore
    }

    // Scrive la matrice nel file
    fprintf(filePtr1, "output_hw_signed:\n");
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 128; j++) {
            fprintf(filePtr1, "%d ", conv1d_calcolato[i][j]);
        }
        fprintf(filePtr1, "\n");
    }

    fclose(filePtr1);  // Chiude il file
  
  */
 

    return 0;
}




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

void conv1d_sw_s() {
int i = 0;

errno_t err;
int8_t sample[16][128] = { 0 };
int8_t f[16][16][5] = { 0 };
int32_t R[8][124] = { 0 };

int cnt = 0;
for (int j = 0; j < 16; j++) {
    for (int i = 0; i < 128; i++) {
        sample[j][i] = A[cnt];
        cnt++;
    }
}
 cnt = 0;
for (int n = 0; n < 16; n++) {
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 5; i++) {
            f[n][j][i] = F[cnt];
            cnt++;
        }
    }

}

for (int m = 0; m < 8; m++) { // Per ogni filtro
    for (int i = 0; i < 124; i++) { // Per ogni posizione di output
        int accumulated_output = 0;

        for (int n = 0; n < 16; n++) { // Per ogni canale
            for (int j = 0; j < 5; j++) { // Per ogni elemento del filtro
                accumulated_output += sample[n][i + j] * f[m][n][j];
            }
        }

        // Salva il risultato
        R[m][i] = accumulated_output;
    }
}

FILE* filePtr2 = fopen("output_sw_signed.txt", "w");

// Verifica se il file è stato aperto correttamente
if (filePtr2 == NULL) {
    printf("Errore nell'aprire il file.\n");
    return 1; // Uscita con errore
}

// Ciclo per scrivere i valori della matrice in esadecimale nel file
for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 124; j++) {
        // Scrive ogni valore in esadecimale nel file con il formato 0xXXXXXXXX
        fprintf(filePtr2, "R[%d][%d] = 0x%08" PRIx32 "\n", i, j, R[i][j]);
    }
}

// Chiudi il file
fclose(filePtr2);
}




void conv1d_sw_u() {
    int i=0;
    FILE* filePtr3;
    errno_t err;

    // Utilizza fopen_s per aprire il file in modalità scrittura
    err = fopen_s(&filePtr3, "output_sw_unsigned.txt", "w");

    if (err != 0) {
        // Se fopen_s fallisce, restituisce un errore
        printf("Impossibile aprire il file per la scrittura.\n");
        return; // Non restituire nulla, la funzione è di tipo void
    }
    int  pr_acc[16];
    int cnt = 0;
    uint32_t sample[16][128] = { 0 };
    uint32_t f0[16][5] = { 0 };
    uint32_t f1[16][5] = { 0 };
    uint32_t f2[16][5] = { 0 };
    uint32_t f3[16][5] = { 0 };
    uint32_t f4[16][5] = { 0 };
    uint32_t f5[16][5] = { 0 };
    uint32_t f6[16][5] = { 0 };
    uint32_t filters[8][16][5] = { 0 };
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
    for (int k = 0; k < 8; k++) {
        for (int j = 0; j < 16; j++) {
            for (int i = 0; i < 5; i++) {
                filters[k][j][i] = F[cnt];
                cnt++;
            }
        }
    }


    //---------------------------
    
//convoluzione
/*
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
    }*/

    {
        // Azzeriamo la matrice di output per evitare problemi
        for (int k = 0; k < NUM_FILTERS; k++) {
            for (int j = 0; j < COLS; j++) {
                out_matrix[k][j] = 0.0f;
            }
        }

        // Scorriamo tutti i filtri f0, f1, ..., f7
        for (int k = 0; k < NUM_FILTERS; k++) {
            for (int j = 0; j < COLS; j++) {
                for (int i = 0; i < ROWS; i++) {
                    for (int f = 0; f < FILTER_SIZE; f++) {
                        out_matrix[k][j] += filters[k][i][f] * sample[i][j + f];
                    }
                }
            }
        }
    }






    //----------------------------





  
    for (int i = 0; i < 8; i++) {  // Righe di out_matrix
        for (int j = 0; j < 128; j++) {  // Colonne di out_matrix
            fprintf(filePtr3, " 0x%08" PRIx32, out_matrix[i][j]);
           // fprintf(filePtr3, "%d ", out_matrix[i][j]);
        }
         fprintf(filePtr3, "\n");
    }

    // Chiude il file
    fclose(filePtr3);


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


void print_mem_to_file(uint8_t mem[RIGHE_MEM][COLONNE_MEM], const char* filename) {
    FILE* filePtr4;
    errno_t err;

    // Apri il file in modalità scrittura
    err = fopen_s(&filePtr4, filename, "w");

    if (err != 0) {
        // Se fopen_s fallisce, mostra un errore
        printf("Impossibile aprire il file per la scrittura. Errore %d\n", err);
        return;
    }

    // Scrivi i dati di mem nel file
    for (int i = 0; i < RIGHE_MEM_8; i++) {
        for (int j = 0; j < COLONNE_MEM; j++) {
            fprintf(filePtr4, "%4d ", mem[i][j]);  // Scrive ogni valore
        }
        fprintf(filePtr4, "\n");  // Nuova riga dopo ogni riga della matrice
    }

    // Chiudi il file
    fclose(filePtr4);
    printf("Matrice mem scritta correttamente nel file %s\n", filename);
}



void print_hex_mem_to_file(uint8_t mem[RIGHE_MEM][COLONNE_MEM], const char* filename) {
    FILE* filePtr5;
    errno_t err;

    // Apri il file in modalità scrittura
    err = fopen_s(&filePtr5, filename, "w");

    if (err != 0) {
        // Se fopen_s fallisce, mostra un errore
        printf("Impossibile aprire il file per la scrittura.\n");
        return;
    }

    // Scrivi i dati di mem nel file
    for (int i = 0; i < RIGHE_MEM_8; i++) {
        for (int j = 0; j < COLONNE_MEM ; j++) {
            fprintf(filePtr5, " 0x%02" PRIx32 , mem[i][j]);
           
        }
        fprintf(filePtr5, "\n");  // Nuova riga dopo ogni riga della matrice
    }

    // Chiudi il file
    fclose(filePtr5);
    printf("Matrice mem scritta correttamente nel file %s\n", filename);
}


/*
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
    
}*/


// Funzione per convertire un numero in formato binario (8 bit)
void decimalToBinary(int8_t num, char* binaryStr) {
    for (int i = 7; i >= 0; i--) {
        binaryStr[i] = ((num >> (7 - i)) & 1) + '0';
    }
    binaryStr[8] = '\0';
}

void print_bin_mem_to_file(uint8_t mem[RIGHE_MEM][COLONNE_MEM], const char* filename) {
    FILE* filePtr6;
    errno_t err;

    // Apri il file in modalità scrittura
    err = fopen_s(&filePtr6, filename, "w");

    if (err != 0 || filePtr6 == NULL) {
        printf("Impossibile aprire il file per la scrittura. Errore %d\n", err);
        return;
    }

    // Scrivi i dati di mem nel file in formato binario
    char binaryStr[9] = { 0 };
    for (int i = 0; i < RIGHE_MEM_8; i++) {
        for (int j = 0; j < COLONNE_MEM; j++) {
            decimalToBinary(mem[i][j], binaryStr); // Converte il numero in binario
            fprintf(filePtr6, "%s ", binaryStr);  // Scrive il valore binario
        }
        fprintf(filePtr6, "\n");  // Nuova riga dopo ogni riga della matrice
    }

    // Chiudi il file
    fclose(filePtr6);
    printf("Matrice mem scritta correttamente nel file %s\n", filename);
}




void remove_spaces(const char* filename1, const char* filename2) {
    FILE* filePtr11;
    FILE* filePtr22;
    errno_t err;
    char ch;

    // Apri il file di input
    err = fopen_s(&filePtr11, filename1, "r");
    if (err != 0 || filePtr11 == NULL) {
        printf("Errore: impossibile aprire il file di input '%s'.\n", filename1);
        return;
    }

    // Apri il file di output
    err = fopen_s(&filePtr22, filename2, "w");
    if (err != 0 || filePtr22 == NULL) {
        printf("Errore: impossibile aprire il file di output '%s'.\n", filename2);
        fclose(filePtr11); // Chiudi il file di input se il secondo fallisce
        return;
    }

    // Leggi ogni carattere dal file di input
    printf("Inizio la lettura del file '%s'...\n", filename1);
    while ((ch = fgetc(filePtr11)) != EOF) {
       

        // Se il carattere non è uno spazio, scrivilo nel file di output
        if (ch != ' ') {
            fputc(ch, filePtr22);
        }
    }

    if (feof(filePtr11)) {
        printf("Fine del file '%s' raggiunta.\n", filename1);
    }
    else {
        printf("Errore nella lettura del file '%s'.\n", filename1);
    }

    // Chiudi i file
    fclose(filePtr11);
    fclose(filePtr22);

    printf("Gli spazi sono stati rimossi dal file '%s' e scritti nel file '%s'.\n", filename1, filename2);
}