#include <stdio.h>
#include "data.h"
#include <errno.h>
#include <stdbool.h> // Necessario per utilizzare il tipo bool
unsigned int step_cnt = 0;
// Definizione corretta delle costanti
#define COLONNE_MEM 4
#define RIGHE_MEM 128
uint32_t obi_data = 0;
uint32_t obi_addr = 0;

void conv1d_testa(); // Dichiarazione della funzione
void replace_sample(int sample_block);
void replace_filter(int filter_block); // il blocco di filti puo essere o 0 o 1 nel caso in cui sto usando i primi 4 filtri o gli                                                                                                                       altri 4
unsigned int data_size = 0;
bool obi_accepted = 0;
int j = 0;
int i = 0;
int mem[128] = { 0};
//-------------------- PARAMETRI DA PASSARE ALLE DUE FUNZIONI
bool FILTER_BLOCK=0;
#define  SAMPLE_SET_VAL  0;
//---------------------- VARIABILI DA DICHIARARE
int index = 0;
int byte_mem = 4;                 // numero di byte che puo avere una riga della memoria
int filter_number = 0;
int N_SAMPLE_LOAD = 8;
int sample_number = 0;
//-----------------------


int main() {

            for (filter_number = 0; filter_number < INPUT_CH ; filter_number++) {
                for (int j = 0; j < KERNEL_LEN; j++) {
                    for (int i = 0; i < byte_mem; i++) {
                        // Calcoliamo l'indice nell'array F
                        index = i * KERNEL_LEN + j + filter_number * KERNEL_LEN * byte_mem + FILTER_BLOCK * KERNEL_LEN * INPUT_CH * byte_mem;
                        // Inseriamo l'elemento nel corretto offset di obi_data (un byte per ogni posizione)
                        obi_data |= (uint32_t)(F[index] & 0xFF) << (24 - (i * 8));

                    }
                    i = 0;
                    // TB_LOG(LOG_HIGH, "Writing '%x' to address '%x'", obi_data, obi_addr);     //todo_uncomment
                    // obi_req = genObiWriteReqTx(obi_addr, obi_data, 0xf);                   //todo_uncomment
                   mem[obi_addr/4] = obi_data; //da_togliere


                    obi_data = 0x00000000;
                    obi_addr += 0x4;
                    data_size += 0x4;
                }
                j = 0;
                obi_accepted = false;
                // Push expected data to the scoreboard checker queue
                // When a read request is performed, the expected data is compared with the read data
               // scb->scheduleObiCheck(obi_data);                                               //todo_uncomment
                // Prepare next data element

            }
        
        //obi_addr += 0x4;
        obi_data = 0x00000000;
        index = 0;
        for (int sample_number = 0; sample_number < INPUT_CH/4 ; sample_number++) {
            for (int j = 0; j < N_SAMPLE_LOAD; j++) {
                for (int i = 0; i < byte_mem; i++) {
                    // Calcoliamo l'indice nell'array F
                   index = i * INPUT_LEN + j + (N_SAMPLE_LOAD+1/ 2) * SAMPLE_SET_VAL + sample_number * INPUT_LEN * byte_mem;
                    // Inseriamo l'elemento nel corretto offset di obi_data (un byte per ogni posizione)
                    obi_data |= (uint32_t)(A[index] & 0xFF) << (24 - (i * 8));
                }

                // TB_LOG(LOG_HIGH, "Writing '%x' to address '%x'", obi_data, obi_addr);     //todo_uncomment
                // obi_req = genObiWriteReqTx(obi_addr, obi_data, 0xf);                   //todo_uncomment
                mem[obi_addr/4] = obi_data; //da_togliere
                obi_data = 0x00000000;
                obi_addr += 0x4;
                data_size += 0x4;
            }

            obi_accepted = false;
            // Push expected data to the scoreboard checker queue
            // When a read request is performed, the expected data is compared with the read data
           // scb->scheduleObiCheck(obi_data);                                               //todo_uncomment
            // Prepare next data element

        }

        obi_data = 0x00000000;

  
        return 0;
};



//faccio scambio i filtri
void replace_filter(int filter_block) {
    int inc = 0;
    if (filter_block == 0) {
        for (int bk = 0; bk < 16; bk++) {
            for (int w_c = 0; w_c < 4; w_c++) {
                for (int w_r = 0; w_r < 5; w_r++) {

                   // mem[w_r + bk * 5][w_c] = F[inc];
                    inc++;
                }
            }
        }
    }
    if (filter_block == 1) {
        for (int bk = 0; bk < 16; bk++) {
            for (int w_c = 0; w_c < 4; w_c++) {
                for (int w_r = 0; w_r < 5; w_r++) {

                    //mem[w_r + bk * 5][w_c] = F[inc+320];
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
            for (int w_r = 80; w_r < 80 + 9; w_r++) {

               // mem[w_r + bk * 9][w_c] = A[inc];
                inc++;
            }
        }

    }
}












