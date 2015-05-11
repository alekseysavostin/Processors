library ieee;
use ieee.std_logic_1164.all;

entity stack_mp is port (
    Clock, Reset: in std_logic;
	 Halt: out std_logic;
    Data_Out1, Data_Out2: out std_logic_vector(15 downto 0) -- need for debug only!
	 );
end stack_mp;

architecture stack_mpSructural of stack_mp is
    component stack_cu is port (
        Clock, Reset: in std_logic;
	     -- control signals
	     IRLoad, JMPmux, PCload, MemInst: out std_logic;
	     Asel: out std_logic_vector(1 downto 0);
	     InitLfsr, SetDimension, SetPolynom, NextLfsr: out std_logic;
	     EnableStack: out std_logic;
	     StackOperation: out std_logic_vector(1 downto 0); 
	     ALUSel: out std_logic_vector(2 downto 0); -- select for operations
	     -- status signals
	     IR: in std_logic_vector(11 downto 8);
	     Aeq0, Apos: in std_logic;
	     -- control outputs
	     Halt: out std_logic);
    end component;
	
    component stack_dp is port(
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
	     Aeq0, Apos: out std_logic ;Data_Out1, Data_Out2: out std_logic_vector(15 downto 0));
    end component;
	 
	 -- control signals
	 signal mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_EnableStack: std_logic;
	 signal mp_Asel, mp_StackOperation: std_logic_vector(1 downto 0);
	 signal mp_InitLfsr, mp_SetDimension, mp_SetPolynom, mp_NextLfsr: std_logic;
	 signal mp_ALUSel: std_logic_vector(2 downto 0); -- select for ALU operations
	 -- status signals
	 signal mp_IR: std_logic_vector(11 downto 8);
	 signal mp_Aeq0, mp_Apos: std_logic;
begin
    U_cu: stack_cu port map (
	     Clock, Reset,
		  mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_Asel,
		  mp_InitLfsr, mp_SetDimension, mp_SetPolynom, mp_NextLfsr,
		  mp_EnableStack, mp_StackOperation, mp_ALUSel,
		  mp_IR, mp_Aeq0, mp_Apos, Halt);
	 U_dp: stack_dp port map (
	     Clock, Reset,
		  mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_Asel,
		  mp_InitLfsr, mp_SetDimension, mp_SetPolynom, mp_NextLfsr,
		  mp_EnableStack, mp_StackOperation, mp_ALUSel,
		  mp_IR, mp_Aeq0, mp_Apos, Data_Out1, Data_Out2);
end stack_mpSructural; 