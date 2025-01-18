library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_conv is
-- Entità vuota per il testbench
end tb_conv;

architecture Behavioral of tb_conv is
    -- Costanti per definire larghezza dati e indirizzi
    constant DATA_WIDTH : integer := 8;
    constant ADDR_WIDTH : integer := 4;

    -- Segnali per collegarsi alla RAM
    signal clk     : std_logic := '0';
    signal we      : std_logic := '0';
    signal addr    : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal data_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out: std_logic_vector(DATA_WIDTH-1 downto 0);

signal start_conv : std_logic :='0';

    -- Componente RAM
    component RAM
        Generic (
            DATA_WIDTH : integer;
            ADDR_WIDTH : integer
        );
        Port (
            clk     : in  std_logic;
            we      : in  std_logic;
            addr    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out: out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

begin
    -- Instanza della RAM
    RAM1: RAM
        Generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        Port map (
            clk => clk,
            we => we,
            addr => addr,
            data_in => data_in,
            data_out => data_out
        );

    -- Processo per generare il clock
    clock_gen: process
    begin
        while true loop
            clk <= not clk;
            wait for 10 ns; -- Periodo del clock di 20 ns
        end loop;
    end process;

    -- Processo per scrivere la RAM
    w_RAM: process
    begin
        -- Scrittura di dati nella RAM
        for i in 0 to 2**ADDR_WIDTH-1 loop
            addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
            data_in <= std_logic_vector(to_unsigned(i*2, DATA_WIDTH)); -- Dati da caricare
            we <= '1';
            wait for 20 ns; -- Attesa per scrittura
        end loop;
	start_conv<='1';
        wait;
    end process;

convolution : process(clk)
begin 
if clk'EVENT and clk='1' then
	if start_conv='1' then



	end if;
end if;
end process;


end Behavioral;

