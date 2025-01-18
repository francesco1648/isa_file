
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
	
	
	kernel : in std_logic_vector (kernel_size-1 downto 0)

);
end entity;

architecture beh of conv1d_core is


begin



end architecture;

