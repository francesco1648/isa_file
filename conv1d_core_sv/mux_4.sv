module MUX_4 #(
  parameter N = 8
) (
  // Numero di bit per gli ingressi
  input  logic [    1:0] sel,
  // Selettore a 2 bit
  input  logic [N - 1:0] in0,
  // Ingresso 0
  input  logic [N - 1:0] in1,
  // Ingresso 1
  input  logic [N - 1:0] in2,
  // Ingresso 2
  input  logic [N - 1:0] in3,
  // Ingresso 3
  output logic [N - 1:0] y
  // Uscita
);



  always @(sel or in0 or in1 or in2 or in3) begin
    case (sel)
      2'b00: begin
        y = in0;
        // Selettore 00, uscita A
      end
      2'b01: begin
        y = in1;
        // Selettore 01, uscita B
      end
      2'b10: begin
        y = in2;
        // Selettore 10, uscita C
      end
      2'b11: begin
        y = in3;
        // Selettore 11, uscita D
      end
      default: begin
        y = {(((N - 1)) - ((0)) + 1) {1'b0}};
        // Gestione caso non definito
      end
    endcase
  end


endmodule
