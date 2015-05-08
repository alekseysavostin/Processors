library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lfsr is
    generic(constant size: integer := 16);
    port (
        Clock, Reset, Init, Nexts: in  std_logic;
		  Dimension: in std_logic_vector (3 downto 0);
		  Polynom: in std_logic_vector (size-1 downto 0);
        LfsrIn: in std_logic_vector (size-1 downto 0);
		  LfsrOut: out std_logic_vector (size-1 downto 0));
end entity;

architecture behavioral of lfsr is
    signal lfsr_tmp: std_logic_vector (size-1 downto 0);
begin
    process (Clock, Reset, Init, Nexts)
        variable feedback: std_logic;
	 begin
		 feedback := lfsr_tmp(0);
		 for i in 1 to size-1 loop
		     feedback := feedback xor (lfsr_tmp(i) and Polynom(i));
		 end loop;
	    if (Init = '1') then
           lfsr_tmp <= LfsrIn;
       elsif (Reset = '1') then
           lfsr_tmp <= (others=>'0');
	    elsif (rising_edge(Clock) and Nexts = '1') then		    
           lfsr_tmp <= '0' & lfsr_tmp(size-1 downto 1);
		 	  lfsr_tmp(conv_integer(Dimension)-1) <= feedback;
	 end if;
	 end process;	
	 LfsrOut <= lfsr_tmp;
end architecture;