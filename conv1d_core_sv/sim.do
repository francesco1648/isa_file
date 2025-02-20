# Avvia la simulazione
vsim -batch work.tb_conv1d


# Aggiungi la RAM alla finestra List
add list sim:/tb_conv1d/R1/mem  ;# Assicurati che il percorso sia corretto

# Esegui fino a ns
run 340 us

# Apri un file per scrivere
set fileId [open ram_contents1.txt w]

# Cicla sugli indirizzi della RAM e scrivi il contenuto
for {set addr 120} {$addr < 128} {incr addr} {
    # Ottieni il valore della RAM all'indirizzo
    set data [examine sim:/tb_conv1d/R1/mem($addr)]
    
    # Scrivi l'indirizzo e il valore in esadecimale nel file
    puts $fileId "[format 0x%08X $addr] [format 0x%08X $data]"
}

# Chiudi il file
close $fileId

# Ferma la simulazione
quit -sim
