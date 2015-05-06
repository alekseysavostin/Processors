LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux4 IS
    generic (size: integer);
    PORT (
    S: IN STD_LOGIC_vector(1 downto 0); -- select line
    D3, D2, D1, D0: IN STD_LOGIC_VECTOR(size-1 downto 0); -- data bus input
    Y: OUT STD_LOGIC_VECTOR(size-1 downto 0)); -- data bus output
END mux4;

ARCHITECTURE Behavioral OF mux4 IS
BEGIN
    PROCESS(S, D3, D2, D1, D0)
    BEGIN
	     case S is
		      when "00" => Y <= D0;
				when "01" => Y <= D1;
				when "10" => Y <= D2;
				when "11" => Y <= D3;
				when others => Y <= D3;
			end case;
    END PROCESS;
END Behavioral;