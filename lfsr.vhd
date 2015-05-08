library ieee;
use ieee.std_logic_1164.all;

entity lfsr is
 	generic(constant size: integer := 16);
 	port (
	 	clk			:in  std_logic;
		reset			:in  std_logic;
      lfsr_in		:in std_logic_vector (size-1 downto 0);
		lfsr_out		:out std_logic_vector (size-1 downto 0));
end entity;

architecture behavioral of lfsr is
 	signal lfsr_tmp		:std_logic_vector (size-1 downto 0);
 	constant polynome		:std_logic_vector (size-1 downto 0) := "1011010000000001";
begin
 	process (clk, reset)
       variable feedback: std_logic;
	begin
		feedback := lfsr_tmp(0);
		for i in 1 to size-1 loop
		    feedback := feedback xor ( lfsr_tmp(i) and polynome(i) );
		end loop;
	if (reset = '1') then
		lfsr_tmp <= lfsr_in;
	elsif (rising_edge(clk)) then    
		lfsr_tmp <= feedback & lfsr_tmp(size-1 downto 1);
	end if;
	end process;	
	lfsr_out <= lfsr_tmp;
end architecture;