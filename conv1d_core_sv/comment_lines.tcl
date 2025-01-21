proc comment_lines {} {
    # Ottieni il numero di righe selezionate
    set line_count [vlib -count]
    
    # Per ogni riga selezionata, aggiungi un commento all'inizio
    for {set i 0} {$i < $line_count} {incr i} {
        # Ottieni la riga corrente
        set line [lindex [vlib] $i]
        
        # Aggiungi il commento (per VHDL o SystemVerilog, usa '--' o '//')
        set commented_line "-- $line"
        
        # Sostituisci la riga nel buffer
        vset $i $commented_line
    }
}
