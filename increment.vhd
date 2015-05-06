library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity increment is
    generic (size: integer := 8);
	 port (
	     A: in std_logic_vector(size-1 downto 0);
		  F: out std_logic_vector(size-1 downto 0));
end increment;

architecture Behavior of increment is
begin
    process (A)
	 begin
	     F <= std_logic_vector(unsigned(A) + 1);
	 end process;
end Behavior;