library ieee;
use ieee.std_logic_1164.all;

library lpm; -- for memory
use lpm.lpm_components.all;

entity stack_dp is port(
    Clock, Clear: in std_logic;
	 -- control signals
    IRLoad, JMPmux, PCload, MemInst: in std_logic;
    ASel: in std_logic_vector(1 downto 0);
	 InitLfsr, SetDimension, SetPolynom, NextLfsr: in std_logic;
	 EnableStack: in std_logic;
	 StackOperation: in std_logic_vector(1 downto 0); 
	 ALUSel: in std_logic_vector(2 downto 0); -- select for operations
	 -- status signals
	 IR: out std_logic_vector(11 downto 8);
	 Aeq0, Apos: out std_logic;
	 Data_Out1, Data_Out2: out std_logic_vector(15 downto 0));
end stack_dp;

architecture dpStructutal of stack_dp is
    component reg
	 generic(size: integer := 4);
	 port (
	     Clock, Clear, Load: in std_logic;
		  D: in std_logic_vector(size-1 downto 0);
		  Q: out std_logic_vector(size-1 downto 0));
    end component;
	 
	 component increment
	 GENERIC (size: integer := 8);
	 port (
	     A: in std_logic_vector(size-1 downto 0);
		  F: out std_logic_vector(size-1 downto 0));
    end component;
	 
	 component mux2
	 generic (size: integer := 8);
	 port (
	     S: in std_logic;
		  D1, D0: in std_logic_vector(size-1 downto 0);
		  Y: out std_logic_vector(size-1 downto 0));
    end component;
	 
	 component mux4
	 generic (size: integer := 8);
	 port (
        S: in std_logic_vector(1 downto 0);
		  D3, D2, D1, D0: in std_logic_vector(size-1 downto 0);
		  Y: out std_logic_vector(size-1 downto 0));
    end component;
	 
	 component alu
    generic (size: integer := 8);
    port (
        ALUSel: IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- select for operations
        A, B: IN STD_LOGIC_VECTOR(size-1 DOWNTO 0); -- input operands
        F: OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)); -- output
    end component;
	 
	 component lfsr is
 	 generic(constant size: integer := 16);
 	 port (
        Clock, Reset, Init, Nexts: in  std_logic;
		  Dimension: in std_logic_vector (3 downto 0);
		  Polynom: in std_logic_vector (size-1 downto 0);
        LfsrIn: in std_logic_vector (size-1 downto 0);
		  LfsrOut: out std_logic_vector (size-1 downto 0));
    end component;
	 
	 component stack is generic(constant size: integer := 16; constant RAMSize: integer := 256);
    port(
    Clk: in std_logic;  --Clock for the stack.
	 Reset: in std_logic; --Reset
    Enable: in std_logic;  --Enable the stack. Otherwise neither push nor pop will happen.
    Data_In: in std_logic_vector(size-1 downto 0);  --Data to be pushed to stack
	 Operation: in std_logic_vector(1 downto 0);
    Data_Out1: out std_logic_vector(size-1 downto 0);
	 Data_Out2: out std_logic_vector(size-1 downto 0));
    end component;
	 
	 signal dp_IR: std_logic_vector(11 downto 0);
	 signal dp_JMPmux, dp_PC, dp_increment, dp_meminst: std_logic_vector(7 downto 0);
	 signal dp_StackOut1, dp_StackOut2, dp_RAMQ, dp_StackMux, dp_alures, dp_LfsrOut, dp_Polynom, tt1: std_logic_vector(15 downto 0);
	 signal dp_Dimension: std_logic_vector (3 downto 0);
	 --signal dp_StackOut1Temp, dp_StackOut2Temp: std_logic_vector(15 downto 0);
	 
begin
    U0: stack generic map(16, 16) port map (Clock, Clear, EnableStack, dp_StackMux, StackOperation, dp_StackOut1, dp_StackOut2);
    -- IR
    U_IR: reg generic map(12) port map (Clock, Clear, IRLoad, dp_RAMQ(11 downto 0), dp_IR);
	 IR <= dp_IR(11 downto 8);
	 -- JMPmux
	 U_PCM: mux2 generic map(8) port map (JMPmux, dp_IR(7 downto 0), dp_increment, dp_JMPmux);
	 --U_TMP1: reg generic map(16) port map (Clock, Clear, EnableStack, dp_StackOut1, dp_StackOut1Temp);
	 --U_TMP2: reg generic map(16) port map (Clock, Clear, EnableStack, dp_StackOut2, dp_StackOut2Temp);
	 -- PC
	 U_PC: reg generic map(8) port map (Clock, Clear, PCLoad, dp_JMPmux, dp_PC);
	 -- memInst
	 U_MemInst: mux2 generic map(8) port map (Meminst, dp_IR(7 downto 0), dp_PC, dp_meminst);
	 -- increment
	 U_Inc: increment generic map(8) port map(dp_PC, dp_increment);
	 -- memory
	 U_Ram: lpm_ram_dq
	     generic map (
	         lpm_widthad => 8,
		      lpm_outdata => "UNREGISTERED",
		      lpm_file => "stack_program.mif",
		      lpm_width => 16)
		  port map (
		      data => (others => '0'),
				address => dp_meminst,
				we => '0',
				inclock => Clock,
				q => dp_RAMQ);
    -- A input mux
    U_AMux: mux4 generic map(16) port map (Asel, dp_LfsrOut, dp_RAMQ, "00000000" & dp_IR(7 downto 0), dp_alures, dp_StackMux);
	 -- ALU
	 U_Alu: alu generic map(16) port map (ALUSel, dp_StackOut1, dp_StackOut2, dp_alures);
	 
	 U_lfsr_polynom: reg generic map(16) port map (Clock, Clear, SetPolynom, dp_StackOut1, dp_Polynom);
	 U_lfsr_dimension: reg generic map(4) port map (Clock, Clear, SetDimension, dp_StackOut1(3 downto 0), dp_Dimension);
	 --U_LR: reg generic map(16) port map (Clock, Clear, '1', dp_LfsrOut, tt1);
	 U_lfsr: lfsr generic map(16) port map (Clock, Clear, InitLfsr, NextLfsr, dp_Dimension, dp_Polynom, dp_StackOut1, dp_LfsrOut);
	 
	 Aeq0 <= '1' when dp_StackOut1 = "0000000000000000" else '0';
	 Apos <= not dp_StackOut1(15);
	 Data_Out1 <= dp_StackOut1;
	 Data_Out2 <= dp_StackOut2;
end dpStructutal;