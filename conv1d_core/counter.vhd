
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
    generic (
        N : integer := 8  -- Numero di bit del contatore (default 8 bit)
    );
    port (
        clk       : in STD_LOGIC;                         -- Clock
        reset     : in STD_LOGIC;                         -- Reset asincrono
        enable    : in STD_LOGIC;                         -- Abilitazione contatore
        terminal_count : out STD_LOGIC;                    -- Segnale terminal count (TC)
        count     : out STD_LOGIC_VECTOR(N-1 downto 0)    -- Contatore in uscita
    );
end counter;

architecture Behavioral of counter is
    signal counter : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');  -- Contatore interno
    signal max_count : STD_LOGIC_VECTOR(N-1 downto 0);  -- Valore massimo (terminal count) configurabile
begin

    -- Impostazione del valore massimo (Terminal Count)
    max_count <= (others => '1');  -- Puoi cambiare questo valore come desiderato (es. "00000100" per 4)

    -- Processo del contatore
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');  -- Reset del contatore
            terminal_count <= '0';       -- TC a 0 durante il reset
        elsif rising_edge(clk) then
            if enable = '1' then
                if counter = max_count then
                    counter <= (others => '0');  -- Reset del contatore quando raggiunge TC
                    terminal_count <= '1';       -- Impostiamo TC a 1
                else
                    counter <= counter + 1;     -- Incrementiamo il contatore
                    terminal_count <= '0';       -- TC a 0 durante il conteggio
                end if;
            end if;
        end if;
    end process;

    -- Uscita del contatore
    count <= counter;

end Behavioral;
