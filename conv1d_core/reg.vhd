library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg is
  generic (
    n_bit : integer := 8  -- Numero di bit del registro, valore di default 8
  );
  port (
    clk   : in  std_logic;          -- Segnale di clock
    rst_n : in  std_logic;          -- Segnale di reset asincrono
    load  : in  std_logic;          -- Segnale di abilitazione del caricamento
    d_in  : in  std_logic_vector(n_bit-1 downto 0); -- Dato di input
    q_out : out std_logic_vector(n_bit-1 downto 0)  -- Dato di output
  );
end entity reg;

architecture Behavioral of reg is
  signal reg : std_logic_vector(n_bit-1 downto 0) := (others => '0'); -- Registro interno
begin

  process(clk, rst_n)
  begin
    if rst_n = '1' then
      reg <= (others => '0');  -- Reset asincrono del registro
    elsif rising_edge(clk) then
      if load = '1' then
        reg <= d_in;          -- Caricamento del valore di input
      end if;
    end if;
  end process;

  q_out <= reg; -- Output del registro

end architecture Behavioral;
