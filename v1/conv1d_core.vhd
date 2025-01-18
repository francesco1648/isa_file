
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;
entity conv1d_core is
generic (
	kernel_size : integer;
in_channel : integer
 );
port (
	clk     : in std_logic;
	RST_n   : in std_logic;
	
		 
	ext_mem_gnt : out std_logic;
	--int_mem_req
	req_i : out std_logic;
	we_i : out std_logic;
	be : out std_logic_vector(3 downto 0);
	add_i : out std_logic_vector(31 downto 0);
	wdata : out std_logic_vector(31 downto 0);
 	--mem_rsp
	data : in std_logic_vector(31 downto 0);

----------------------------------------------------------segnali da aggiungere
	start	: in std_logic;
	done_tot: out std_logic;
	done_row : out std_logic;
	
	accepted_sample : in std_logic;
	replaced_sample  : in std_logic


----------------------------------------------------------
 

);
end entity;

architecture beh of conv1d_core is

------------------------------------------------------------------------------------
component reg is
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
end component reg;
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
component counter is
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
end component;
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

component mux_4 is
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
end component;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
component mux_2 is
  generic (
    n_bit : integer := 8  -- Numero di bit dei segnali in ingresso, valore di default 8
  );
  port (
    sel   : in  std_logic;          -- Segnale di selezione
    d0    : in  std_logic_vector(n_bit-1 downto 0); -- Ingresso 0
    d1    : in  std_logic_vector(n_bit-1 downto 0); -- Ingresso 1
    y     : out std_logic_vector(n_bit-1 downto 0)  -- Uscita del multiplexer
  );
end component mux_2;
--------------------------------------------------------------------------------------


signal M0_A,M0_B,M1_A,M1_B,M2_A,M2_B,M3_A,M3_B : std_logic_vector(15 downto 0);
signal M0_O,M1_O,M2_O,M3_O : std_logic_vector(31 downto 0);

signal ADD0_A,ADD0_B,ADD1_A,ADD1_B,ADD2_A,ADD2_B,ADD3_A,ADD3_B,ADD4_A,ADD4_B : std_logic_vector(31 downto 0);
signal ADD0_O,ADD1_O,ADD2_O,ADD3_O,ADD4_O : std_logic_vector(31 downto 0);


begin
-----------------------------------------------------------------------------------DP




-----------------------------------------------------------------------------------



end architecture;

