LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY regfile IS GENERIC (size: INTEGER := 8);
PORT (
    clk: IN STD_LOGIC; --clock
    WE: IN STD_LOGIC; --write enable
    WA: IN STD_LOGIC_VECTOR(1 DOWNTO 0); --write address
    input: IN STD_LOGIC_VECTOR(size-1 DOWNTO 0); --input
    RAE: IN STD_LOGIC; --read enable ports A & B
    RAA: IN STD_LOGIC_VECTOR(1 DOWNTO 0); --read address port A & B
    RBE: IN STD_LOGIC; --read enable ports A & B
    RBA: IN STD_LOGIC_VECTOR(1 DOWNTO 0); --read address port A & B
    Aout, Bout: OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)); --output port A & B
END regfile;

ARCHITECTURE Behavioral OF regfile IS
SUBTYPE reg IS STD_LOGIC_VECTOR(size-1 DOWNTO 0);
TYPE regArray IS array(0 TO 3) OF reg;
SIGNAL RF: regArray; --register file contents
BEGIN
    WritePort: PROCESS (clk)
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            IF (WE = '1') THEN
                RF(CONV_INTEGER(WA)) <= input;
             END IF;
        END IF;
     END PROCESS;
	  
     ReadPortA: PROCESS (RAE, RAA)
     BEGIN
         IF (RAE = '1') then
             Aout <= RF(CONV_INTEGER(RAA)); -- convert bit VECTOR to integer
         ELSE
             Aout <= (others => '0');
         END IF;
     END PROCESS;
	  
     ReadPortB: PROCESS (RBE, RBA)
     BEGIN
         IF (RBE = '1') then
             Bout <= RF(CONV_INTEGER(RBA)); -- convert bit VECTOR to integer
         ELSE
             Bout <= (others => '0');
         END IF;
    END PROCESS;
END Behavioral;