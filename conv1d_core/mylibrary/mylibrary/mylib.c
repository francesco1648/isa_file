#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mti.h> // Include l'API FLI

// Puntatori ai segnali in VHDL
mtiSignalIdT clk_signal;
mtiSignalIdT reset_signal;
mtiSignalIdT c_to_vhdl_signal;
mtiSignalIdT vhdl_to_c_signal;

// Callback per leggere il segnale da VHDL
void read_vhdl_signal(void) {
    char* vhdl_to_c_value = mti_GetSignalValue(vhdl_to_c_signal);
    printf("Ricevuto da VHDL: %s\n", vhdl_to_c_value);
}

// Scrive un valore in VHDL
void write_c_to_vhdl(char* value) {
    mti_SetSignalValue(c_to_vhdl_signal, value);
    printf("Inviato a VHDL: %s\n", value);
}

// Callback per il clock
void clock_callback(void) {
    static int toggle = 0;
    mti_SetSignalValue(clk_signal, toggle ? "1" : "0");
    toggle = !toggle;
}

// Funzione principale per la co-simulazione
void sim_main(void) {
    // Recupera i segnali dalla simulazione
    clk_signal = mti_FindSignal("signal_exchange/clk");
    reset_signal = mti_FindSignal("signal_exchange/reset");
    c_to_vhdl_signal = mti_FindSignal("signal_exchange/c_to_vhdl");
    vhdl_to_c_signal = mti_FindSignal("signal_exchange/vhdl_to_c");

    // Imposta il reset
    mti_SetSignalValue(reset_signal, "1");
    clock_callback(); // Toggle del clock
    mti_SetSignalValue(reset_signal, "0");

    // Loop di simulazione
    for (int i = 0; i < 10; i++) {
        char value[9];
        sprintf(value, "%08d", i); // Scrive un valore binario
        write_c_to_vhdl(value);

        // Legge il segnale di ritorno da VHDL
        read_vhdl_signal();

        // Attende un ciclo di clock
        clock_callback();
    }
}
