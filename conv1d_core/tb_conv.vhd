library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;  -- Libreria per leggere i file

entity tb_conv is
end entity;

architecture Behavioral of tb_conv is

    -- Parametri per la RAM
    constant DATA_WIDTH : integer := 32;  -- Larghezza dati
    constant ADDR_WIDTH : integer := 8;   -- Larghezza indirizzi

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

    -- Segnali per il DUT (Device Under Test)
    signal clk              : std_logic := '0';
    signal RST_n            : std_logic := '0';

    signal ext_mem_gnt       : std_logic;
    signal req_i             : std_logic;
    signal we_i              : std_logic;
    signal be                : std_logic_vector(3 downto 0);
    signal add_i             : std_logic_vector(31 downto 0);
    signal wdata             : std_logic_vector(31 downto 0);
    signal data              : std_logic_vector(31 downto 0);

    signal start             : std_logic := '0';
    signal done_tot          : std_logic;
    signal done_OUT_SAMPLE          : std_logic;

    signal accepted_OUT_sample :  std_logic;
signal replaced_IN_sample  :  std_logic;
	signal REPLACE_FILTER :  STD_LOGIC;
	 signal REPLACED_FILTER :  STD_LOGIC;
	signal REPLACE_INPUT:  STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Segnali per la RAM
    signal ram_data_out      : std_logic_vector(31 downto 0);

    -- Istanza della RAM
    COMPONENT RAM is
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

    -- Istanza di conv1d_core
    component conv1d_core is
        port (
            clk              : in std_logic;
            RST_n            : in std_logic;

            ext_mem_gnt       : out std_logic;
            req_i             : out std_logic;
            we_i              : out std_logic;
            be                : out std_logic_vector(3 downto 0);
            add_i             : out std_logic_vector(31 downto 0);
            wdata             : out std_logic_vector(31 downto 0);
            data              : in  std_logic_vector(31 downto 0);


	start	: in std_logic;
	done_tot: out std_logic;
	done_OUT_SAMPLE : out std_logic;
	
	accepted_OUT_sample : in std_logic;
	replaced_IN_sample  : in std_logic;
	REPLACE_FILTER : OUT STD_LOGIC;
	REPLACED_FILTER : IN STD_LOGIC;
	REPLACE_INPUT: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    end component;

begin
---------------------------------------------------------------
    -- Processo di scrittura in RAM dal file





----------------------------------------------------------------
    LOAD_MATRIX : process
        -- Dichiarazione per leggere il file
        file input_file : text open read_mode is "matrix_.txt";  -- Nome del file da cui leggere
        variable line_buffer : line;  -- Buffer per leggere una riga
        variable matrix_value : integer;  -- Valore letto dalla matrice
        variable addr_counter : integer := 0;  -- Indirizzo corrente nella RAM
    begin
        wait for 20 ns;  -- Attendere l'inizializzazione

        -- Imposta il reset
        RST_n <= '0';
        wait for 20 ns;
        RST_n <= '1';
        wait for 20 ns;

        -- Lettura del file e scrittura in RAM
        while not endfile(input_file) loop
            readline(input_file, line_buffer);  -- Leggi una riga del file
            -- Per ogni valore della matrice (34 colonne)
            for i in 0 to 33 loop
                read(line_buffer, matrix_value);  -- Leggi un valore della matrice
                -- Scrivi nella RAM
                add_i <= std_logic_vector(to_unsigned(addr_counter, ADDR_WIDTH));  -- Imposta l'indirizzo
                wdata <= std_logic_vector(to_unsigned(matrix_value, DATA_WIDTH));  -- Imposta il dato
                we_i <= '1';  -- Abilita la scrittura
                wait for CLK_PERIOD;  -- Aspetta un ciclo di clock
                addr_counter := addr_counter + 1;  -- Incrementa l'indirizzo
            end loop;
        end loop;

        -- Termina la simulazione dopo aver scritto tutti i dati
        wait for 100 ns;
        assert false report "Testbench completed!" severity failure;
    end process;

---------------------------------------------------------------
    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Istanza della RAM
    ram_inst : RAM
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk     => clk,
            we      => we_i,
            addr    => add_i(ADDR_WIDTH-1 downto 0),
            data_in => wdata,
            data_out=> ram_data_out
        );

    -- Istanza di conv1d_core
    conv1d_core_inst : conv1d_core
        port map (
            clk              => clk,
            RST_n            => RST_n,

            ext_mem_gnt       => ext_mem_gnt,
            req_i             => req_i,
            we_i              => we_i,
            be                => be,
            add_i             => add_i,
            wdata             => wdata,
            data              => ram_data_out,

            start             => start,
            done_tot          => done_tot,
            done_OUT_SAMPLE          => done_OUT_SAMPLE,
	
	accepted_OUT_sample=>accepted_OUT_sample,
	replaced_IN_sample  =>replaced_IN_sample,
	REPLACE_FILTER=>REPLACE_FILTER,
	REPLACED_FILTER=> REPLACED_FILTER,
	REPLACE_INPUT=>REPLACE_INPUT
        );

    -- Stimolo della testbench


end Behavioral;

