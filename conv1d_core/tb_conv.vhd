library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use std.STANDARD.all;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;


entity tb_conv is
end entity;

architecture Behavioral of tb_conv is


    -- Clock period


    -- Segnali per il DUT (Device Under Test)
    signal clk              : std_logic := '0';
    signal RST_n            : std_logic := '0';

    signal ext_mem_gnt       : std_logic;
    signal req_i             : std_logic;
    signal  we_i             : std_logic;

    signal be                : std_logic_vector(3 downto 0);
    signal add_i             : std_logic_vector(31 downto 0);
    signal wdata             : std_logic_vector(31 downto 0);
    signal wdata_CONV1D             : std_logic_vector(31 downto 0);
--    signal data            : std_logic_vector(31 downto 0);

    signal start             : std_logic := '0';
    signal done_tot          : std_logic;
    signal done_OUT_SAMPLE          : std_logic;

    	signal accepted_OUT_sample :  std_logic;
	signal replaced_IN_sample  :  std_logic;
	signal REPLACE_FILTER :   STD_LOGIC_VECTOR(0 DOWNTO 0);
	 signal REPLACED_FILTER :  STD_LOGIC;
	signal REPLACE_INPUT:  STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL SEL_MUX_DATA : STD_LOGIC;
	SIGNAL SEL_MUX_ADD : STD_LOGIC;
	SIGNAL SEL_MUX_we_i,we_i_conv1d,we_i_process: STD_LOGIC;
	SIGNAL add_i_CONV1D ,add_i_PROCESS : STD_LOGIC_VECTOR(31 DOWNTO 0 );
	signal wdata_PROCESS: STD_LOGIC_VECTOR(31 DOWNTO 0 );
		SIGNAL REPLACE_FILTER_REQ :  STD_LOGIC;
    -- Segnali per la RAM
    signal ram_data_out      : std_logic_vector(31 downto 0);

------------------------------------------------------------------------------
COMPONENT RAM IS
port(
     data_in_RAM: IN std_logic_vector(31 downto 0);
     address_RAM : IN std_logic_vector(31 downto 0);
      clock,WE: IN std_logic;
     data_out_RAM: OUT std_logic_vector(31 downto 0)
 );
END COMPONENT;

-------------------------------------------------------------------------
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
	REPLACE_FILTER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	REPLACED_FILTER : IN STD_LOGIC;
	REPLACE_FILTER_REQ : OUT STD_LOGIC;
	REPLACE_INPUT: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    end component;
--------------------------------------------------------------------
component mux_2_1b is

  port (
    sel   : in  std_logic;          -- Segnale di selezione
    d0    : in  std_logic; -- Ingresso 0
    d1    : in  std_logic; -- Ingresso 1
    y     : out std_logic  -- Uscita del multiplexer
  );
end component;
-----------------------------------------------------------------------------------

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
    
-- Dichiarazione della variabile per memorizzare i dati letti dal file
FILE C_FILE_NAME : TEXT  ;
FILE C_FILE_NAME1 : TEXT  ;


begin

------------------------------------------------------------
mux_DATA : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_MUX_DATA,D0=>wdata_CONV1D,D1=>wdata_PROCESS, Y=> wdata  );
mux_ADD : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_MUX_ADD,D0=>add_i_CONV1D,D1=>add_i_PROCESS, Y=> ADD_I  );
mux_we_i : MUX_2_1b GENERIC MAP (n_bit => 1 ) PORT MAP (SEL=>SEL_MUX_we_i,D0=>we_i_conv1d,D1=>we_i_PROCESS, Y=> we_i  );

---------------------------------------------------------------
    -- Processo di scrittura in RAM dal file

  WriteData_proc: process
	variable var_data3     :std_logic_vector(31 downto 0);
   	variable fstatus       :file_open_status;
   	variable file_line     :line;
	VARIABLE CARICAMENTO : INTEGER :=0;
 begin
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f0.txt", READ_mode); -- mettere il punto dove si trova il file
	---------------------
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
-----------------------------------
    	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 350 ns;
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	start<='1';
replaced_IN_sample<='0';
wait until REPLACE_FILTER_REQ='1';

	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f1.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
wait for 500 ns;
REPLACED_FILTER<='0';


wait until REPLACE_FILTER_REQ='1';
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f0.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
		
wait for 500 ns;
REPLACED_FILTER<='0';

wait until REPLACE_FILTER_REQ='1';
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f1.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
wait for 500 ns;
REPLACED_FILTER<='0';
wait until REPLACE_FILTER_REQ='1';
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f0.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
		
wait for 500 ns;
REPLACED_FILTER<='0';

wait until REPLACE_FILTER_REQ='1';
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f1.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
wait for 500 ns;
REPLACED_FILTER<='0';

wait until REPLACE_FILTER_REQ='1';
--replace_input="00001";
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f0.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
		
wait for 500 ns;
REPLACED_FILTER<='0';

wait until REPLACE_FILTER_REQ='1';

	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s0_f1.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
	
wait for 500 ns;
REPLACED_FILTER<='0';


wait until REPLACE_FILTER_REQ='1';


	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
	
wait for 500 ns;
REPLACED_FILTER<='0';



wait FOR 5000 NS;
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
CARICAMENTO:=0;
------------------------------------------------
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s1_f0.txt", READ_mode); -- mettere il punto dove si trova il file
	---------------------
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
-----------------------------------
    	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 350 ns;
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	start<='1';
replaced_IN_sample<='1';
WAIT FOR 200 NS;
replaced_IN_sample<='0';

wait until REPLACE_FILTER_REQ='1';
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';

CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s1_f1.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
wait for 500 ns;
REPLACED_FILTER<='0';


	wait until REPLACE_FILTER_REQ='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
CARICAMENTO:=0;
------------------------------------------------
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s1_f0.txt", READ_mode); -- mettere il punto dove si trova il file
	---------------------
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';
-----------------------------------
    	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 350 ns;
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	start<='1';
replaced_FILTER<='1';
WAIT FOR 200 NS;
replaced_FILTER<='0';

wait until REPLACE_FILTER_REQ='1';
	SEL_MUX_DATA<='1';
	SEL_MUX_ADD<='1';
	SEL_MUX_we_i<='1';

CARICAMENTO:=0;
file_open(C_FILE_NAME, "C:\Users\Titania\Desktop\ms\lab3\test_conv1d\test_conv1d\mem_s1_f1.txt", READ_mode); -- mettere il punto dove si trova il file
	we_i_PROCESS<='1';
	WHILE NOT ENDFILE(C_FILE_NAME) LOOP
  
 	READLINE(C_FILE_NAME, file_line);
	READ(file_line, var_data3);
   	add_i_PROCESS<=std_logic_vector(to_unsigned(CARICAMENTO, 32));
	wdata_PROCESS<=var_data3;
	
	wait for 20 ns;
	CARICAMENTO := CARICAMENTO +1;
	
	END LOOP;
	FILE_CLOSE(C_FILE_NAME);
wait for 200 ns;
	REPLACED_FILTER<='1';
	SEL_MUX_DATA<='0';
	SEL_MUX_ADD<='0';
	SEL_MUX_we_i<='0';
	
wait for 500 ns;
REPLACED_FILTER<='0';




	
-----------------------------------------------

WAIT ;

END PROCESS;
---------------------------------------------------------------
      



--------------------------------------------------------------
-- Clock generation

process
   
begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
end process;

---------------------------------------------------------
R1: RAM port MAP(
     data_in_RAM=> wdata,
     address_RAM =>add_i,
      clock=> clk,
	WE=> we_i,
     data_out_RAM=>ram_data_out
 );

    
-----------------------------------------------------
conv1d_uut: conv1d_core     port map (
            clk              =>clk,
            RST_n            =>RST_n,

            ext_mem_gnt       =>ext_mem_gnt,
            req_i             =>req_i,
            we_i              =>we_i_conv1d,
            be                =>be,
            add_i             =>add_i_conv1d,
            wdata             =>wdata_CONV1D,
            data              =>ram_data_out,


	start	=>start,
	done_tot=>done_tot,
	done_OUT_SAMPLE=> done_OUT_SAMPLE,
	
	accepted_OUT_sample =>accepted_OUT_sample,
	replaced_IN_sample  =>replaced_IN_sample,
	REPLACE_FILTER=>REPLACE_FILTER,
	REPLACED_FILTER =>REPLACED_FILTER,
	REPLACE_FILTER_REQ=>REPLACE_FILTER_REQ,
	REPLACE_INPUT=>REPLACE_INPUT
        );

-----------------------------------------------------
 

    -- Stimolo della testbench

--SEL_MUX_DATA<='1', '0' AFTER 2800 NS,'1' AFTER 17500 NS, '0' AFTER 23270 NS,'1' AFTER 40000 NS, '0' AFTER 40100 NS;
--SEL_MUX_ADD<='1', '0' AFTER 2800 NS,'1' AFTER 17500 NS, '0' AFTER 23270 NS,'1' AFTER 40000 NS, '0' AFTER 40100 NS;
--SEL_MUX_we_i<='1', '0' AFTER 2800 NS,'1' AFTER 17500 NS, '0' AFTER 23270 NS,'1' AFTER 40000 NS, '0' AFTER 40100 NS;

accepted_OUT_sample<='1';
end Behavioral;