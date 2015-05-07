library ieee;
use ieee.std_logic_1164.all;
-- need the following to perform arithmetics on STD_LOGIC_VECTORs
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity alu is generic (size: integer := 8);
port (
    ALUSel: IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- select for operations
    A, B: IN STD_LOGIC_VECTOR(size-1 DOWNTO 0); -- input operands
    F: OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)); -- output
end alu;

architecture Behavior of alu is
begin
    process(ALUSel, A, B)
    begin
        case ALUSel is
        when "0000" => -- pass through
            F <= A;
        when "0001" =>
            F <= A and B;
        when "0010" =>
            F <= A or B;
        when "0011" =>
            F <= A xor B;
        when "0100" =>
            F <= not A;
        when "0101" =>
            F <= A + B;
		  when "0110" =>
		      F <= A - B;
        when "0111" =>
		      F <= A - 1;
        when "1000" =>
		      F <= A + 1;
        when "1001" =>
		      F <= std_logic_vector(unsigned(A) srl conv_integer(B));
		  when "1010" =>
		      F <= std_logic_vector(unsigned(A) sll conv_integer(B));
        when others =>
            F <= A;
        end case;
    end process;
end Behavior;
