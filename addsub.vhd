LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY addsub IS
    GENERIC(n: INTEGER :=4); -- default number of bits = 4
    PORT(
        S: IN STD_LOGIC; -- select subtract signal
        A: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        B: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        F: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        unsigned_overflow: OUT STD_LOGIC;
        signed_overflow: OUT STD_LOGIC);
END addsub;

ARCHITECTURE Behavioral OF addsub IS
-- temporary result for extracting the unsigned overflow bit
SIGNAL result: STD_LOGIC_VECTOR(n DOWNTO 0);
-- temporary result for extracting the c3 bit
SIGNAL c3: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN
    PROCESS(S, A, B)
    BEGIN
        IF (S = '0') THEN -- addition
        -- the two operands are zero extended one extra bit before adding
        -- the & is for string concatination
            result <= ('0' & A) + ('0' & B);
            c3 <= ('0' & A(n-2 DOWNTO 0)) + ('0' & B(n-2 DOWNTO 0));
            F <= result(n-1 DOWNTO 0); -- extract the n-bit result
            unsigned_overflow <= result(n); -- get the unsigned overflow bit
            signed_overflow <= result(n) XOR c3(n-1); -- get signed overflow bit
        ELSE -- subtraction
            -- the two operands are zero extended one extra bit before subtracting
            -- the & is for string concatination
            result <= ('0' & A) - ('0' & B);
            c3 <= ('0' & A(n-2 DOWNTO 0)) - ('0' & B(n-2 DOWNTO 0));
            F <= result(n-1 DOWNTO 0); -- extract the n-bit result
            unsigned_overflow <= result(n); -- get the unsigned overflow bit
            signed_overflow <= result(n) XOR c3(n-1); -- get signed overflow bit
        END IF;
    END PROCESS;
END Behavioral;