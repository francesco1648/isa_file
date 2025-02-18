
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
	ACCEPTED_DONE_TOT : IN STD_LOGIC;
	accepted_OUT_sample : in std_logic;
	replaced_IN_sample  : in std_logic;
	REPLACE_FILTER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	REPLACE_FILTER_REQ : OUT STD_LOGIC;
	REPLACED_FILTER : IN STD_LOGIC;
	REPLACE_INPUT_REQ : OUT STD_LOGIC;
	REPLACE_INPUT: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	


----------------------------------------------------------
 

);
end entity;

architecture beh of conv1d_core is
type statetype is (IDLE,s0,s1,s2,s3,s4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18,S19,S20,S21,S22,S23,S24,S25,S26,S27,S28,s29 );
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
SIGNAL LR_BLK_FILTER : STD_LOGIC;  
SIGNAL BLK_FILTER : std_logic_vector(0 downto 0);
SIGNAL RESET_BLK_FILTER : STD_LOGIC;

signal M0_A,M0_B,M1_A,M1_B,M2_A,M2_B,M3_A,M3_B : std_logic_vector(7 downto 0);
signal M0_O,M1_O,M2_O,M3_O : std_logic_vector(31 downto 0);
SIGNAL M0_O_SHORT,M1_O_SHORT,M2_O_SHORT,M3_O_SHORT :STD_LOGIC_VECTOR(15 downto 0  );


signal ADD0_A,ADD0_B,ADD1_A,ADD1_B,ADD2_A,ADD2_B,ADD3_A,ADD3_B,ADD4_A,ADD4_B : std_logic_vector(31 downto 0);
signal ADD0_O,ADD1_O,ADD2_O,ADD3_O,ADD4_O : std_logic_vector(31 downto 0);

signal LR_ADD_CH,LR_ADD_FIL,LR_FILTER,LR_APP,LR_R0,LR_R1,LR_R2,LR_R3 : std_logic;
signal LR_ACC_0,LR_ACC_1,LR_ACC_2,LR_ACC_3,LR_ADD_M_O,LR_OUT_MAT : std_logic;

signal REG_ADD_CH,REG_ADD_FIL,REG_FILTER,REG_APP_O,REG_OUT_MAT,REG_ACC_O: std_logic_vector(31 downto 0);
signal REG_ACC_0,REG_ACC_1,REG_ACC_2,REG_ACC_3,REG_ADD_M_O,REG_OUT_MEM: std_logic_vector(31 downto 0);
SIGNAL REG_R0_O,REG_R1_O,REG_R2_O,REG_R3_O : STD_LOGIC_VECTOR(31 downto 0);

SIGNAL SEL_ADD4_A: STD_LOGIC;
SIGNAL SEL_ADD1_B,SEL_ADD1_A ,SEL_ADD2_A,SEL_ADD2_B,SEL_ADD3_A,SEL_ADD3_B,SEL_ADD0_A,SEL_ADD0_B,SEL_ADD4_B:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL SEL_M0_A,SEL_M0_B,SEL_M1_A,SEL_M1_B,SEL_M2_A,SEL_M2_B,SEL_M3_A,SEL_M3_B : STD_LOGIC;



SIGNAL RESET_CNT_I ,EN_CNT_I,TC_I: STD_LOGIC;
SIGNAL CNT_I :STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
SIGNAL CNT_I_8  :STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_J ,EN_CNT_J,TC_J: STD_LOGIC;
SIGNAL CNT_J :STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
signal CNT_J_32 :STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_M ,EN_CNT_M,TC_M: STD_LOGIC;
SIGNAL CNT_M :STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
SIGNAL CNT_M_32 :STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
SIGNAL CNT_M_8 :STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_S ,EN_CNT_S,TC_S: STD_LOGIC;
SIGNAL CNT_S :STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
SIGNAL CNT_S_32 :STD_LOGIC_VECTOR ( 31 DOWNTO 0 );
--------------------------------------------------
SIGNAL RESET_CNT_FG ,EN_CNT_FG,TC_FG: STD_LOGIC;
SIGNAL CNT_FG :STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL CNT_FG_SHIFT : STD_LOGIC_VECTOR(31 downto 0);

---------------------------------------------------
SIGNAL RESET_CNT_Z ,EN_CNT_Z,TC_Z: STD_LOGIC;
SIGNAL CNT_Z :STD_LOGIC_VECTOR ( 4 DOWNTO 0 );
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

R_ADD_CH : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_add_ch,d_in=>add4_o,q_out=>REG_ADD_CH);

R_ADD_FIL : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_ADD_FIL,d_in=>add1_o,q_out=>REG_ADD_FIL);

R_FILTER : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_FILTER,d_in=>DATA,q_out=>REG_FILTER);

REGISTER_ACC_0 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_0,d_in=>ADD4_O,q_out=>REG_ACC_0);

REGISTER_ACC_1 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_1,d_in=>REG_ACC_0,q_out=>REG_ACC_1);

REGISTER_ACC_2 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_2,d_in=>REG_ACC_1,q_out=>REG_ACC_2);

REGISTER_ACC_3 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>lr_ACC_3,d_in=>REG_ACC_2,q_out=>REG_ACC_3);

R_APP : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_APP,d_in=>ADD4_O,q_out=>REG_APP_O);

R_ADD_M_O : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_ADD_M_O,d_in=>ADD1_O,q_out=>REG_ADD_M_O);

R_OUT_MAT : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_OUT_MAT,d_in=>DATA,q_out=>REG_OUT_MAT);

R_BLK_FILTER : REG generic map(n_bit=>1 ) port map (clk=>clk, rst_n=>RESET_BLK_FILTER,load=>LR_BLK_FILTER,d_in=>"1",q_out=>BLK_FILTER);

R_R0 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_R0,d_in=>M0_O,q_out=>REG_R0_O);

R_R1 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_R1,d_in=>M1_O,q_out=>REG_R1_O);

R_R2 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_R2,d_in=>M2_O,q_out=>REG_R2_O);

R_R3 : REG generic map(n_bit=>32 ) port map (clk=>clk, rst_n=>rst_n,load=>LR_R3,d_in=>M3_O,q_out=>REG_R3_O);

MUX0 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD0_A,IN0=>M0_O,IN1=>REG_APP_O,IN2=> reg_acc_1 ,IN3=>(OTHERS=>'0'), Y=> ADD0_A  );

MUX1 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD0_B,IN0=>M1_O,IN1=>REG_OUT_MAT,IN2=> reg_acc_0 ,IN3=>(OTHERS=>'0'), Y=> ADD0_B  );

MUX2 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD1_A,IN0=>ADD0_O,IN1=>M2_O,IN2=> ADD2_O ,IN3=>(OTHERS=>'0'), Y=> ADD1_A  );

MUX3 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD1_B,IN0=>CNT_J_32,IN1=>M3_O,IN2=> "00000000000000000000000001111000" ,IN3=>(OTHERS=>'0'), Y=> ADD1_B  );


MUX4 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD2_A,IN0=>M2_O,IN1=>REG_R2_O,IN2=> CNT_M_32 ,IN3=>(OTHERS=>'0'), Y=> ADD2_A  );

MUX5 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD2_B,IN0=>"00000000000000000000000001010000",IN1=>REG_R3_O,IN2=> CNT_FG_SHIFT ,IN3=>(OTHERS=>'0'), Y=> ADD2_B  );

MUX6 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD3_A,IN0=>CNT_J_32,IN1=>REG_ACC_2,IN2=> REG_R0_O ,IN3=>(OTHERS=>'0'), Y=> ADD3_A  );

MUX7 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD3_B,IN0=>CNT_S_32,IN1=>REG_ACC_3,IN2=> REG_R1_O ,IN3=>(OTHERS=>'0'), Y=> ADD3_B  );

MUX8 : MUX_2 GENERIC MAP (n_bit => 32 ) PORT MAP (SEL=>SEL_ADD4_A,D0=>ADD0_O,D1=>ADD2_O, Y=> ADD4_A  );

MUX9 : MUX_4 GENERIC MAP (N => 32 ) PORT MAP (SEL=>SEL_ADD4_B,IN0=>ADD1_O,IN1=>ADD3_O,IN2=> (OTHERS=>'0') ,IN3=>(OTHERS=>'0'), Y=> ADD4_B  );

MUX10 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M0_A,D0=>CNT_I_8,D1=>DATA(31 DOWNTO 24), Y=> M0_A  );

MUX11 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M0_B,D0=>"00000101",D1=>REG_FILTER(31 DOWNTO 24), Y=> M0_B  );

MUX12 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M1_A,D0=>CNT_M_8,D1=>DATA(23 DOWNTO 16), Y=> M1_A  );

MUX13 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M1_B,D0=>"00010100",D1=>REG_FILTER(23 DOWNTO 16), Y=> M1_B  );

MUX14 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M2_A,D0=>CNT_I_8,D1=>DATA(15 DOWNTO 8), Y=> M2_A  );

MUX15 : MUX_2 GENERIC MAP (n_bit => 8 ) PORT MAP (SEL=>SEL_M2_B,D0=>"00001000",D1=>REG_FILTER(15 DOWNTO 8), Y=> M2_B  );

M3_A	<=	DATA( 7 DOWNTO 0 );
M3_B	<=	REG_FILTER(7 DOWNTO 0);



COUNTER_I : COUNTER GENERIC MAP ( N=>3) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_I, ENABLE=>EN_CNT_I,terminal_count=>TC_I,COUNT=>CNT_I  );

COUNTER_J : COUNTER GENERIC MAP ( N=>3) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_J, ENABLE=>EN_CNT_J,terminal_count=>TC_J,COUNT=>CNT_J  );

COUNTER_M : COUNTER GENERIC MAP ( N=>3) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_M, ENABLE=>EN_CNT_M,terminal_count=>TC_M,COUNT=>CNT_M  );

COUNTER_S : COUNTER GENERIC MAP ( N=>3) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_S, ENABLE=>EN_CNT_S,terminal_count=>TC_S,COUNT=>CNT_S  );

COUNTER_Z : COUNTER GENERIC MAP ( N=>5) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_Z, ENABLE=>EN_CNT_Z,terminal_count=>TC_Z,COUNT=>CNT_Z  );

COUNTER_FG : COUNTER GENERIC MAP ( N=>2) PORT MAP(CLK=>CLK,RESET=>RESET_CNT_FG , ENABLE=>EN_CNT_FG ,terminal_count=>TC_FG ,COUNT=>CNT_FG   );


WDATA<=ADD0_O;
--WDATA<=REG_APP_O;
REPLACE_INPUT<=CNT_z;
CNT_FG_SHIFT<= ("0000000000000000000000000000") &CNT_FG & "00";
CNT_I_8<=("00000") & CNT_I;
CNT_J_32<=("00000000000000000000000000000") & CNT_J;
CNT_M_32<=("00000000000000000000000000000") & CNT_M;
CNT_M_8<=("00000") & CNT_M;
CNT_S_32 <=("00000000000000000000000000000") & CNT_S;


REPLACE_FILTER<=BLK_FILTER;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------CU
STATE_UPDATE : process(CLK,RST_n)
BEGIN
IF RST_n ='1' THEN P_STATE<=S0;
ELSIF CLK'EVENT AND CLK ='1' THEN
P_STATE<=N_STATE;
END IF;
END PROCESS;

N_STATE_COMUTE : PROCESS (P_STATE,START,CNT_Z,CNT_S,CNT_FG,CNT_I,CNT_J,ACCEPTED_OUT_SAMPLE,REPLACED_IN_SAMPLE,REPLACED_FILTER,ACCEPTED_DONE_TOT )
BEGIN
CASE P_STATE IS 
	WHEN IDLE => IF (START ='1') THEN
			N_STATE<= S0;
			ELSE N_STATE<= IDLE;
			END IF;
	WHEN S0 => IF ( CNT_Z="1000" ) THEN
			N_STATE<=S19;
			ELSE N_STATE<= S1;
			END IF;
	WHEN S1 => IF (CNT_S ="100" ) THEN 
			N_STATE <= S21 ;
			ELSE N_STATE<= S2;
			END IF;  
	
	WHEN S2 => IF (CNT_FG ="10" ) THEN 
			N_STATE <= S17  ;
			ELSE N_STATE<= S3;
			END IF;  
	WHEN S3 => IF (CNT_M ="100" ) THEN 
			N_STATE <= S20  ;
			ELSE N_STATE<= S4;
			END IF; 
	WHEN S4 => IF (CNT_J ="101" ) THEN 
			N_STATE <= S12  ;
			ELSE N_STATE<= S5;
			END IF;  
	WHEN S5 => IF (CNT_I ="100" ) THEN 
			N_STATE <= S10  ;
			ELSE N_STATE<= S6;
			END IF; 
	WHEN S6 => 	N_STATE <= S25  ;
	WHEN S25=> N_STATE<=S7;
	WHEN S7 => 	N_STATE <= S22  ;
	WHEN S22 => 	N_STATE <= S8  ;
	WHEN S8 => 	N_STATE <= S9   ;
	WHEN S9 => 	N_STATE <= S5  ;
	WHEN S10 => 	N_STATE <= S26  ;
	WHEN S26 => N_STATE<=S11;
	WHEN S11 => 	N_STATE <= S23  ;
	WHEN S23 => 	N_STATE <= S27  ;
	WHEN S27=> N_STATE <=S4;
	WHEN S12 => 	N_STATE <= S28  ;
	WHEN S28 => 	N_STATE <= S3  ;
	WHEN S13 => 	N_STATE <= S15  ;
	WHEN S14 => 	N_STATE <= S15  ;
	WHEN S15 => 	N_STATE <= S16  ;
	WHEN S24 => 	N_STATE <= S1 ;
	WHEN S16 => IF (REPLACED_FILTER ='1' ) THEN 
			N_STATE <= S2   ;
			ELSE N_STATE<= S16;
			END IF;
	WHEN S17 => IF (ACCEPTED_OUT_SAMPLE ='1' ) THEN 
			N_STATE <= S24   ;
			ELSE N_STATE<= S17;
			END IF;
	WHEN S18 => IF (REPLACED_IN_SAMPLE ='1' ) THEN 
			N_STATE <= S0   ;
			ELSE N_STATE<= S18;
			END IF;
 	WHEN S19 =>IF (ACCEPTED_DONE_TOT = '1' ) THEN 
			N_STATE <= IDLE  ;
			ELSE N_STATE<= S19;
			END IF; 	

	WHEN S20 => IF (BLK_FILTER = "0" ) THEN 
			N_STATE <= S13   ;
			ELSE N_STATE<= S14;
			END IF;
	WHEN S21 => 	N_STATE <= S29  ;
	WHEN S29 => 	N_STATE <= S18  ;
 	WHEN OTHERS =>N_STATE<=IDLE;
		
END CASE;	 
END PROCESS;




PROCESS_OUT : PROCESS(P_STATE )

BEGIN
		WE_I<='0';
		SEL_M0_A<='0';
		SEL_M0_B<='0';
		SEL_M1_A<='0';
		SEL_M1_B<='0';
		SEL_M2_A<='0';
		SEL_M2_B<='0';

		SEL_ADD0_A<="00"; 
		SEL_ADD0_B<="00"; 
		SEL_ADD1_A<="00";
		SEL_ADD1_B<="00";
		SEL_ADD2_A<="00";
		SEL_ADD2_B<="00";
		SEL_ADD3_A<="00";
		SEL_ADD3_B<="00";
		SEL_ADD4_A<='0';
		SEL_ADD4_B<="00";
		--add_i<=(OTHERS=>'0');
		
		EN_CNT_I<='0';
		EN_CNT_J<='0';
		EN_CNT_S<='0';
		EN_CNT_M<='0';
		EN_CNT_FG<='0';
		EN_CNT_Z<='0';

		RESET_CNT_I<='0';	
		RESET_CNT_J<='0';
		RESET_CNT_S<='0';	
		RESET_CNT_M<='0';
	
		RESET_CNT_FG<='0';	
		RESET_CNT_Z<='0';
		RESET_BLK_FILTER<='0';

			LR_R0<='0';
			LR_R1<='0';
			LR_R2<='0';
			LR_R3<='0';

			LR_ACC_0<='0';
			LR_ACC_1<='0';
			LR_ACC_2<='0';
			LR_ACC_3<='0';
			LR_ADD_CH<='0';
			LR_ADD_FIL<='0';
			LR_FILTER<='0';
			LR_APP<='0';
			LR_ADD_M_O<='0';
			LR_OUT_MAT<='0';
			LR_OUT_MAT<='0';
			LR_BLK_FILTER<='0';

		REPLACE_FILTER_REQ<='0';
REPLACE_INPUT_REQ <='0';

CASE P_STATE IS
	WHEN IDLE => 	
		WE_I<='0';
		SEL_M0_A<='0';
		SEL_M0_B<='0';
		SEL_M1_A<='0';
		SEL_M1_B<='0';
		SEL_M2_A<='0';
		SEL_M2_B<='0';

		SEL_ADD0_A<="00"; 
		SEL_ADD0_B<="00"; 
		SEL_ADD1_A<="00";
		SEL_ADD1_B<="00";
		SEL_ADD2_A<="00";
		SEL_ADD2_B<="00";
		SEL_ADD3_A<="00";
		SEL_ADD3_B<="00";
		SEL_ADD4_A<='0';
		SEL_ADD4_B<="00";
		DONE_TOT<='0';
			
			
	WHEN S0 =>	RESET_CNT_I<='1';	
		RESET_CNT_J<='1';
		RESET_CNT_S<='1';	
		RESET_CNT_M<='1';
		RESET_CNT_FG<='1';
		REPLACE_INPUT_REQ <='0';

	WHEN S6 =>	SEL_M0_A<='0';
			SEL_M0_B<='0';
			SEL_M1_A<='0'; 
			SEL_M1_B<='0';
			SEL_ADD0_A<="00"; 
			SEL_ADD0_B<="00"; 
			SEL_ADD1_A<="00";
			SEL_ADD1_B<="00";
			LR_ADD_CH<='1';
			LR_ADD_FIL<='1';

			SEL_M2_A<='0';
			SEL_M2_B<='0';
			SEL_ADD2_A<="00";
			SEL_ADD2_B<="00";
			SEL_ADD3_A<="00";
			SEL_ADD3_B<="00";
			SEL_ADD4_A<='1';
			SEL_ADD4_B<="01";
			
			

	WHEN S7 =>	WE_I<='0';	
			req_i<='1';
			add_i<=REG_ADD_FIL;


	WHEN S22 =>	WE_I<='0';	
			req_i<='1';
			add_i<=REG_ADD_CH;
			LR_FILTER<='1';
			
	WHEN S8 =>	SEL_M0_A<='1';
			SEL_M0_B<='1';
			SEL_M1_A<='1'; 
			SEL_M1_B<='1';
			SEL_M2_A<='1'; 
			SEL_M2_B<='1';
			LR_R0<='1';
			LR_R1<='1';
			LR_R2<='1';
			LR_R3<='1';
			

	WHEN S9 =>	EN_CNT_I<='1';	
			SEL_ADD2_A<="01";
			SEL_ADD2_B<="01";
			SEL_ADD3_A<="10";
			SEL_ADD3_B<="10";
	
			SEL_ADD4_A<='1';
			SEL_ADD4_B<="01";
			 LR_ACC_0<='1';
			LR_ACC_1<='1';
			LR_ACC_2<='1';
			 LR_ACC_3<='1';
			
			
			
	WHEN S10 =>	SEL_ADD2_A<="10";
			SEL_ADD2_B<="10";
			SEL_ADD4_A<='0';
			SEL_ADD4_B<="01";
			LR_ADD_M_O<='1';
			SEL_ADD0_A<="10";
			SEL_ADD0_B<="10";
			SEL_ADD3_A<="01";
			SEL_ADD3_B<="01";
			SEL_ADD1_A<="10";
			SEL_ADD1_B<="10";
			LR_APP<='1';
			

	WHEN S26 => 	WE_I<='0';	
			req_i<='1';
			
			RESET_CNT_I<='1';
			EN_CNT_J<='1';
			
	WHEN S11 => 
			add_i<=REG_ADD_M_O;
			
	WHEN S23 =>	LR_OUT_MAT<='1';	
			add_i<=REG_ADD_M_O;
			
			
	WHEN S27=> 	SEL_ADD0_A<="01"; 
			SEL_ADD0_B<="01"; 
			WE_I<='1';	
			req_i<='1';
		

	when s12 => 	EN_CNT_M<='1';
			RESET_CNT_I<='1';	
			RESET_CNT_J<='1';

	WHEN S13=>	LR_BLK_FILTER<='1';
 
	WHEN S14=>	RESET_BLK_FILTER<='1';

	WHEN S15=>	RESET_CNT_M<='1';
			EN_CNT_FG<='1';

	WHEN S17=>	RESET_CNT_FG<='1';
			done_out_sample<='1';

	WHEN S24=>	EN_CNT_S<='1';
			done_out_sample<='0';

	WHEN S21=>	EN_CNT_Z<='1';

	WHEN S18=>	RESET_CNT_S<='1';
			REPLACE_INPUT_REQ <='1';
	WHEN S16=>	REPLACE_FILTER_REQ<='1';
			

	WHEN S19=>	done_TOT<='1';
	


 
			
			
			


 
WHEN OTHERS=>NULL;
END CASE;
END PROCESS;
----------------------------------------------------------------------------------

end architecture;

