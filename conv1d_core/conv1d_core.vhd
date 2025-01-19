
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;
entity conv1d_core is

port (
	clk     : in std_logic;
	RST_n   : in std_logic;
	
		 
	ext_mem_gnt : out std_logic;
	--int_mem_req
	req_i : out std_logic;
	we_i : out std_logic;
	be : out std_logic_vector(3 downto 0);
	add_i : out std_logic_vector(31 downto 0);
	wdata : out std_logic_vector(31 downto 0);  --  SCRIVERE SU MEMORIA
 	--mem_rsp
	data : in std_logic_vector(31 downto 0); --  LEGGERE DALLA MEMORIA

----------------------------------------------------------segnali da aggiungere
	start	: in std_logic;
	done_tot: out std_logic;
	done_OUT_SAMPLE : out std_logic;
	
	accepted_OUT_sample : in std_logic;
	replaced_IN_sample  : in std_logic;
	REPLACE_FILTER : OUT STD_LOGIC;
	REPLACED_FILTER : IN STD_LOGIC;
	REPLACE_INPUT: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	


----------------------------------------------------------
 

);
end entity;

architecture beh of conv1d_core is
type statetype is (s0,s1,s2,s3,s4 );
signal p_state,n_state : statetype;
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


signal M0_A,M0_B,M1_A,M1_B,M2_A,M2_B,M3_A,M3_B : std_logic_vector(7 downto 0);
signal M0_O,M1_O,M2_O,M3_O : std_logic_vector(31 downto 0);
SIGNAL M0_O_SHORT,M1_O_SHORT,M2_O_SHORT,M3_O_SHORT :STD_LOGIC_VECTOR(15 downto 0  );


signal ADD0_A,ADD0_B,ADD1_A,ADD1_B,ADD2_A,ADD2_B,ADD3_A,ADD3_B,ADD4_A,ADD4_B : std_logic_vector(31 downto 0);
signal ADD0_O,ADD1_O,ADD2_O,ADD3_O,ADD4_O : std_logic_vector(31 downto 0);

signal LR_ADD_CH,LR_ADD_FIL,LR_FILTER,LR_APP : std_logic;
signal LR_ACC_0,LR_ACC_1,LR_ACC_2,LR_ACC_3,LR_ADD_M_O,LR_OUT_MAT : std_logic;

signal REG_ADD_CH,REG_ADD_FIL,REG_FILTER,REG_APP_O,REG_OUT_MAT,REG_ACC_O: std_logic_vector(31 downto 0);
signal REG_ACC_0,REG_ACC_1,REG_ACC_2,REG_ACC_3,REG_ADD_M_O,REG_OUT_MEM : std_logic_vector(31 downto 0);

SIGNAL SEL_ADD0_A,SEL_ADD0_B,SEL_ADD1_B,SEL_ADD1_A ,SEL_ADD3_A,SEL_ADD3_B,SEL_ADD4_B,SEL_ADD4_A: STD_LOGIC;
SIGNAL SEL_ADD2_A,SEL_ADD2_B :STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL SEL_M0_A,SEL_M0_B,SEL_M1_A,SEL_M1_B,SEL_M2_A,SEL_M2_B,SEL_M3_A,SEL_M3_B : STD_LOGIC;



SIGNAL RESET_CNT_I ,EN_CNT_I,TC_I: STD_LOGIC;
SIGNAL CNT_I :STD_LOGIC_VECTOR ( 1 DOWNTO 0 );
SIGNAL CNT_I_8  :STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_J ,EN_CNT_J,TC_J: STD_LOGIC;
SIGNAL CNT_J :STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
signal CNT_J_32 :STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_M ,EN_CNT_M,TC_M: STD_LOGIC;
SIGNAL CNT_M :STD_LOGIC_VECTOR ( 1 DOWNTO 0 );
SIGNAL CNT_M_32 :STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
SIGNAL CNT_M_8 :STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_S ,EN_CNT_S,TC_S: STD_LOGIC;
SIGNAL CNT_S :STD_LOGIC_VECTOR ( 1 DOWNTO 0 );
SIGNAL CNT_S_32 :STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_FG ,EN_CNT_FG,TC_FG: STD_LOGIC;
SIGNAL CNT_FG :STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL CNT_FG_SHIFT : STD_LOGIC_VECTOR(31 downto 0);

---------------------------------------------------

begin
-----------------------------------------------------------------------------------DP
-- Processo per ADD0
adder0: process(ADD0_A, ADD0_B)
begin
    ADD0_O <= ADD0_A + ADD0_B;
end process;

-- Processo per ADD1
adder1: process(ADD1_A, ADD1_B)
begin
    ADD1_O <= ADD1_A + ADD1_B;
end process;

-- Processo per ADD2
adder2: process(ADD2_A, ADD2_B)
begin
    ADD2_O <= ADD2_A + ADD2_B;
end process;

-- Processo per ADD3
adder3: process(ADD3_A, ADD3_B)
begin
    ADD3_O <= ADD3_A + ADD3_B;
end process;

-- Processo per ADD4
adder4: process(ADD4_A, ADD4_B)
begin
    ADD4_O <= ADD4_A + ADD4_B;
end process;

-- Processo per M0
multy0: process(M0_A, M0_B)
begin
    M0_O_SHORT <= M0_A * M0_B;
end process;

-- Processo per M1
multy1: process(M1_A, M1_B)
begin
    M1_O_SHORT <= M1_A * M1_B;
end process;

-- Processo per M2
multy2: process(M2_A, M2_B)
begin
    M2_O_SHORT <= M2_A * M2_B;
end process;

-- Processo per M3
multy3: process(M3_A, M3_B)
begin
    M3_O_SHORT <= M3_A * M3_B;
end process;


M0_O<=("0000000000000000")&M0_O_SHORT;
M1_O<=("0000000000000000")&M1_O_SHORT;
M2_O<=("0000000000000000")&M2_O_SHORT;
M3_O<=("0000000000000000")&M3_O_SHORT;

R_ADD_CH : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_add_ch,d_in=>add1_o,q_out=>REG_ADD_CH);

R_ADD_FIL : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_ADD_FIL,d_in=>add3_o,q_out=>REG_ADD_FIL);

R_FILTER : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_FILTER,d_in=>DATA,q_out=>REG_FILTER);

REGISTER_ACC_0 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_0,d_in=>ADD4_O,q_out=>REG_ACC_0);

REGISTER_ACC_1 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_1,d_in=>ADD4_O,q_out=>REG_ACC_1);

REGISTER_ACC_2 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_2,d_in=>ADD4_O,q_out=>REG_ACC_2);

REGISTER_ACC_3 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_3,d_in=>ADD4_O,q_out=>REG_ACC_3);

R_APP : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_APP,d_in=>ADD4_O,q_out=>REG_APP_O);

R_ADD_M_O : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_ADD_M_O,d_in=>ADD4_O,q_out=>REG_ADD_M_O);

R_OUT_MAT : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_OUT_MAT,d_in=>DATA,q_out=>REG_OUT_MAT);


MUX0 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD0_A,D0=>M0_O,D1=>REG_APP_O, Y=> ADD0_A  );

MUX1 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD0_B,D0=>M1_O,D1=>REG_OUT_MAT, Y=> ADD0_B  );

MUX2 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD1_A,D0=>ADD0_O,D1=>M2_O, Y=> ADD1_A  );

MUX3 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD1_B,D0=>CNT_J_32,D1=>M3_O, Y=> ADD1_B  );

MUX4 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD2_A,IN0=>M2_O,IN1=>REG_ACC_O,IN2=>CNT_M_32,IN3=>(OTHERS=>'0'), Y=> ADD2_A  );

MUX5 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD2_B,IN0=>"00000000000000000000000001010000",IN1=>REG_ACC_1,IN2=> CNT_FG_SHIFT ,IN3=>(OTHERS=>'0'), Y=> ADD2_B  );

MUX6 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD3_A,D0=>ADD2_O,D1=>REG_ACC_2, Y=> ADD3_A  );

MUX7 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD3_B,D0=>CNT_S_32 , D1=>REG_ACC_3, Y=> ADD3_B  );

MUX8 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD4_A,D0=>ADD0_O,D1=>ADD2_O, Y=> ADD4_A  );

MUX9 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD4_B,D0=>ADD1_O,D1=>ADD3_O, Y=> ADD4_B  );

MUX10 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M0_A,D0=>CNT_I_8,D1=>DATA(31 DOWNTO 24), Y=> M0_A  );

MUX11 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M0_B,D0=>"00000101",D1=>REG_FILTER(31 DOWNTO 24), Y=> M0_B  );

MUX12 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M1_A,D0=>CNT_M_8,D1=>DATA(23 DOWNTO 16), Y=> M1_A  );

MUX13 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M1_B,D0=>"00010100",D1=>REG_FILTER(23 DOWNTO 16), Y=> M1_B  );

MUX14 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M2_A,D0=>CNT_I_8,D1=>DATA(15 DOWNTO 8), Y=> M2_A  );

MUX15 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M2_B,D0=>"00001001",D1=>REG_FILTER(15 DOWNTO 8), Y=> M2_B  );

M3_A	<=	DATA( 7 DOWNTO 0 );
M3_B	<=	REG_FILTER(7 DOWNTO 0);



COUNTER_I : COUNTER GENERIC MAP ( N=>2) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_I, ENABLE=>EN_CNT_I,terminal_count=>TC_I,COUNT=>CNT_I  );

COUNTER_J : COUNTER GENERIC MAP ( N=>3) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_J, ENABLE=>EN_CNT_J,terminal_count=>TC_J,COUNT=>CNT_J  );

COUNTER_M : COUNTER GENERIC MAP ( N=>2) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_M, ENABLE=>EN_CNT_M,terminal_count=>TC_M,COUNT=>CNT_M  );

COUNTER_S : COUNTER GENERIC MAP ( N=>2) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_S, ENABLE=>EN_CNT_S,terminal_count=>TC_S,COUNT=>CNT_S  );

COUNTER_FG : COUNTER GENERIC MAP ( N=>1) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_FG , ENABLE=>EN_CNT_FG ,terminal_count=>TC_FG ,COUNT=>CNT_FG   );


 

CNT_FG_SHIFT<= ("00000000000000000000000000000") &CNT_FG(0) & "00";
CNT_I_8<=("000000") & CNT_I;
CNT_J_32<=("00000000000000000000000000000") & CNT_J;
CNT_M_32<=("000000000000000000000000000000") & CNT_M;
CNT_M_8<=("000000") & CNT_M;
CNT_S_32 <=("000000000000000000000000000000") & CNT_S;
-----------------------------------------------------------------------------------



end architecture;

