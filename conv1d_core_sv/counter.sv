module COUNTER #(
  parameter N = 8
) (
  // Numero di bit del contatore (default 8 bit)
  input  logic           clk,
  // Clock
  input  logic           reset,
  // Reset asincrono
  input  logic           enable,
  // Abilitazione contatore
  output logic           terminal_count,
  // Segnale terminal count (TC)
  output logic [N - 1:0] count
  // Contatore in uscita
);




  reg   [N - 1:0] counter;
  // Contatore interno
  logic [N - 1:0] max_count;
  // Valore massimo (terminal count) configurabile

  // Impostazione del valore massimo (Terminal Count)
  assign max_count = {(((N - 1)) - ((0)) + 1) {1'b1}};
  // Puoi cambiare questo valore come desiderato (es. "00000100" per 4)
  // Processo del contatore
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      counter = {(((N - 1)) - ((0)) + 1) {1'b0}};
      // Reset del contatore
      terminal_count = 1'b0;
      // TC a 0 durante il reset
    end else begin
      if (enable == 1'b1) begin
        if (counter == max_count) begin
          counter = {(((N - 1)) - ((0)) + 1) {1'b0}};
          // Reset del contatore quando raggiunge TC
          terminal_count = 1'b1;
          // Impostiamo TC a 1
        end else begin
          counter = counter + 1;
          // Incrementiamo il contatore
          terminal_count = 1'b0;
          // TC a 0 durante il conteggio
        end
      end
    end
  end

  // Uscita del contatore
  assign count = counter;

endmodule
