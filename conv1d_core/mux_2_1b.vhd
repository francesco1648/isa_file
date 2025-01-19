
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_2_1b is

  port (
    sel   : in  std_logic;          -- Segnale di selezione
    d0    : in  std_logic; -- Ingresso 0
    d1    : in  std_logic; -- Ingresso 1
    y     : out std_logic  -- Uscita del multiplexer
  );
end entity mux_2_1b;

architecture Behavioral of mux_2_1b is
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