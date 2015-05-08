library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity lfsr is
 	generic(constant size: integer := 16);
 	port (
       Clock, Reset: in  std_logic;
		 Dimension: in std_logic_vector (3 downto 0);
		 Polynome: in std_logic_vector (size-1 downto 0);
       Lfsr_in: in std_logic_vector (size-1 downto 0);
		 Lfsr_out: out std_logic_vector (size-1 downto 0));
end entity;

architecture behavioral of lfsr is
    signal lfsr_tmp: std_logic_vector (size-1 downto 0);
begin
    process (Clock, Reset)
        variable feedback: std_logic;
        --constant Dimension: integer := 4;
	 begin
		 feedback := lfsr_tmp(0);
		 for i in 1 to size-1 loop
		     feedback := feedback xor (lfsr_tmp(i) and Polynome(i));
		 end loop;
	    if (Reset = '1') then
           lfsr_tmp <= Lfsr_in;
	    elsif (rising_edge(Clock)) then		    
           lfsr_tmp <= '0' & lfsr_tmp(size-1 downto 1);
		 	  lfsr_tmp(conv_integer(Dimension)-1) <= feedback;
       --else
           --lfsr_tmp <= lfsr_tmp;
	 end if;
	 end process;	
	 lfsr_out <= lfsr_tmp;
end architecture;