#include <stdio.h>
#include "data.h"
#include <errno.h>
#include <inttypes.h>  // Includi la libreria necessaria per PRIx32

// Definizione corretta delle costanti
#define COLONNE_MEM 4
#define RIGHE_MEM 128
int LOCAL_BUFFER_WORDS = 128;
int BYTES_PER_WORD = 4;
output_ch = 8;
input_ch = 16;
KERNEL_LEN = 5;
input_len = 128;
int8_t local_buffer[512] = {0}; // 128 word x 4 byte
uint32_t tmp_data = 0;

int main() {

    int filter_block = 0;
    int sample_block = 0;
    //size_t iterations = 0;

    // precarica di kernel e input iniziali (non mi piace, sappilo)
    for (size_t k = 0; k < output_ch / 2; k++) {
        for (size_t j = 0; j < input_ch; j++) {
            for (size_t i = 0; i < KERNEL_LEN; i++) {
                local_buffer[j/4*20+((i * BYTES_PER_WORD) + j%4) + (input_ch * KERNEL_LEN) * k] = F[(i + j * 5) + (input_ch * KERNEL_LEN) * k + filter_block * ((input_ch * KERNEL_LEN) * (output_ch / 2))];
            }
        }
    }


    size_t OFF_K = (input_ch * KERNEL_LEN) * (output_ch / 2); // offset dei kernel per sapere da dove partono i canali input in memoria

    for (size_t j = 0; j < input_ch; j++) {
        for (size_t i = 0; i < 8; i++) {
                local_buffer[j / 4 * 32+((i * BYTES_PER_WORD) + j%4) + OFF_K] = A[(i + 4 * sample_block) + input_len * j];
        }
    }
    


    for (size_t k = 0; k < input_ch;k++) {
        for (size_t j = 0; j < KERNEL_LEN;j++) {
            for (size_t i = 0; i < 4;i++) {
                tmp_data=F[i * KERNEL_LEN + j + k * KERNEL_LEN * 4];
            }
        }
    }









	return 0;
}