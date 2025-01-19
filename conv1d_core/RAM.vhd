LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY RAM IS
port(
     data_in_RAM: IN std_logic_vector(31 downto 0);
     address_RAM : IN std_logic_vector(31 downto 0);
      clock,WE: IN std_logic;
     data_out_RAM: OUT std_logic_vector(31 downto 0)
 );
END ENTITY;

ARCHITECTURE BEH OF RAM IS

TYPE REG_TYP IS ARRAY (0 TO 127) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MEM : REG_TYP;
begin

PROCESS(CLOCK)
BEGIN
if(CLOCK' EVENT AND CLOCK='1') THEN

	if  WE='1' then
	MEM(to_integer(unsigned(address_RAM)))<=data_in_RAM;
	end if;

	if WE='0' then
	data_out_RAM<=MEM(to_integer(unsigned(address_RAM)));
	end if;

end if;
end process;
END ARCHITECTURE;
