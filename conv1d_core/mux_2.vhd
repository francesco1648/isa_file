
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_2 is
  generic (
    n_bit : integer := 8  -- Numero di bit dei segnali in ingresso, valore di default 8
  );
  port (
    sel   : in  std_logic;          -- Segnale di selezione
    d0    : in  std_logic_vector(n_bit-1 downto 0); -- Ingresso 0
    d1    : in  std_logic_vector(n_bit-1 downto 0); -- Ingresso 1
    y     : out std_logic_vector(n_bit-1 downto 0)  -- Uscita del multiplexer
  );
end entity mux_2;

architecture Behavioral of mux_2 is
begin
  process(sel, d0, d1)
  begin
    if sel = '0' then
      y <= d0; -- Selezione ingresso 0
    else
      y <= d1; -- Selezione ingresso 1
    end if;
  end process;

end architecture Behavioral;
