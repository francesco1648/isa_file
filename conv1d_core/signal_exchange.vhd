library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_exchange is
    port (
        clk      : in std_logic;
        reset    : in std_logic;
        c_to_vhdl: in std_logic_vector(7 downto 0); -- Input da C
        vhdl_to_c: out std_logic_vector(7 downto 0) -- Output per C
    );
end entity;

architecture behavior of signal_exchange is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            vhdl_to_c <= (others => '0');
        elsif rising_edge(clk) then
            vhdl_to_c <= std_logic_vector(unsigned(c_to_vhdl) + 1); -- Invia un segnale modificato
        end if;
    end process;
end architecture;
