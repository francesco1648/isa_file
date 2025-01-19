library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM is
    Generic (
        DATA_WIDTH : integer;  -- Larghezza dei dati (bit per parola)
        ADDR_WIDTH : integer   -- Larghezza dell'indirizzo (log2(numero parole))
    );
    Port (
        clk     : in  std_logic;                  -- Clock
        we      : in  std_logic;                  -- Write Enable (1 = scrittura, 0 = lettura)
        addr    : in  std_logic_vector(ADDR_WIDTH-1 downto 0); -- Indirizzo
        data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Dato in ingresso
        data_out: out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Dato in uscita
    );
end RAM;

architecture Behavioral of RAM is
    -- Dichiarazione della memoria come array
    type memory_array is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memory : memory_array := (others => (others => '0')); -- Inizializzata a 0
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                -- Scrittura nella memoria
                memory(to_integer(unsigned(addr))) <= data_in;
            end if;
            -- Lettura dalla memoria
            data_out <= memory(to_integer(unsigned(addr)));
        end if;
    end process;
end Behavioral;
