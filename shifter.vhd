LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY shifter IS GENERIC (size: INTEGER := 8);
PORT (
    SHSel: IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- select for operations
    input: IN STD_LOGIC_VECTOR(size DOWNTO 0); -- input operands
    output: OUT STD_LOGIC_VECTOR(size DOWNTO 0)); -- output
END shifter;

ARCHITECTURE Behavior OF shifter IS
BEGIN
    PROCESS(SHSel, input)
        BEGIN
            CASE SHSel IS
            WHEN "00" => -- pass through
                output <= input;
            WHEN "01" => -- shift right
                output <= input(size-2 DOWNTO 0) & '0';
            WHEN "10" => -- shift left
                output <= '0' & input(size-1 DOWNTO 1);
            WHEN OTHERS => -- rotate right
                output <= input(0) & input(size-1 DOWNTO 1);
        END CASE;
    END PROCESS;
END Behavior;
