library ieee;
use ieee.std_logic_1164.all;

entity accum_mp is port (
    Clock, Reset: in std_logic;
	 Halt: out std_logic);
end accum_mp;

architecture accum_mpSructural of accum_mp is
    component accum_cu port (
        Clock, Reset: in std_logic;
	     -- control signals
	     IRLoad, JMPmux, PCload, MemInst, MemWr: out std_logic;
	     Asel: out std_logic_vector(1 downto 0);
	     Aload, InitLfsr, SetDimension, SetPolynom, NextLfsr: out std_logic;
	     ALUSel: out std_logic_vector(2 downto 0); -- select for operations
	     -- status signals
	     IR: in std_logic_vector(11 downto 8);
	     Aeq0, Apos: in std_logic;
	     -- control outputs
	     Halt: out std_logic);
    end component;
	
    component accum_dp is port(
        Clock, Clear: in std_logic;
	     -- control signals
        IRLoad, JMPmux, PCload, MemInst, MemWr: in std_logic;
        ASel: in std_logic_vector(1 downto 0);
	     Aload, InitLfsr, SetDimension, SetPolynom, NextLfsr: in std_logic;
	     ALUSel: in std_logic_vector(2 downto 0); -- select for operations
	     -- status signals
	     IR: out std_logic_vector(11 downto 8);
	     Aeq0, Apos: out std_logic);
    end component;
	 -- control signals
	 signal mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_MemWr: std_logic;
	 signal mp_Asel: std_logic_vector(1 downto 0);
	 signal mp_Aload, mp_InitLfsr, mp_SetDimension, mp_SetPolynom, mp_NextLfsr: std_logic;
	 signal mp_ALUSel: std_logic_vector(2 downto 0); -- select for ALU operations
	 -- status signals
	 signal mp_IR: std_logic_vector(11 downto 8);
	 signal mp_Aeq0, mp_Apos: std_logic;
begin
    U_cu: accum_cu port map (
	     Clock, Reset,
		  --control signals
		  mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_MemWr,
		  mp_Asel,
		  mp_Aload, mp_InitLfsr, mp_SetDimension, mp_SetPolynom, mp_NextLfsr, mp_ALUSel,
		  -- status signals
		  mp_IR,
		  mp_Aeq0, mp_Apos,
		  Halt);
	 U_dp: accum_dp port map (
	     Clock, Reset,
		  --control signals
		  mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_MemWr,
		  mp_Asel,
		  mp_Aload, mp_InitLfsr, mp_SetDimension, mp_SetPolynom, mp_NextLfsr, mp_ALUSel,
		  -- status signals
		  mp_IR,
		  mp_Aeq0, mp_Apos);
end accum_mpSructural; 