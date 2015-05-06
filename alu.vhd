library ieee;
use ieee.std_logic_1164.all;
-- need the following to perform arithmetics on STD_LOGIC_VECTORs
use ieee.std_logic_unsigned.all;

entity alu is generic (size: integer := 8);
port (
    ALUSel: IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- select for operations
    A, B: IN STD_LOGIC_VECTOR(size-1 DOWNTO 0); -- input operands
    F: OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)); -- output
end alu;

architecture Behavior of alu is
begin
    process(ALUSel, A, B)
    begin
        case ALUSel is
        when "000" => -- pass through
            F <= A;
        when "001" =>
            F <= A and B;
        when "010" =>
            F <= A or B;
        when "011" =>
            F <= A xor A;
        when "100" =>
            F <= not A;
        when "101" =>
            F <= A + B;
		  when "110" =>
		      F <= A - B;
        when others =>
            F <= A - 1;
        end case;
    end process;
end Behavior;
