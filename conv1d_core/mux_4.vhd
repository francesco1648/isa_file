
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux_4 is
    generic (
        N : integer := 8  -- Numero di bit per gli ingressi
    );
    port (
        sel : in STD_LOGIC_VECTOR(1 downto 0);  -- Selettore a 2 bit
        in0   : in STD_LOGIC_VECTOR(N-1 downto 0); -- Ingresso 0
        in1   : in STD_LOGIC_VECTOR(N-1 downto 0); -- Ingresso 1
        in2   : in STD_LOGIC_VECTOR(N-1 downto 0); -- Ingresso 2
        in3   : in STD_LOGIC_VECTOR(N-1 downto 0); -- Ingresso 3
        Y   : out STD_LOGIC_VECTOR(N-1 downto 0) -- Uscita
    );
end mux_4;

architecture Behavioral of mux_4 is
begin
    process(sel, in0, in1, in2, in3)
    begin
        case sel is
            when "00" => Y <= in0;  -- Selettore 00, uscita A
            when "01" => Y <= in1;  -- Selettore 01, uscita B
            when "10" => Y <= in2;  -- Selettore 10, uscita C
            when "11" => Y <= in3;  -- Selettore 11, uscita D
            when others => Y <= (others => '0');  -- Gestione caso non definito
        end case;
    end process;
end Behavioral;
