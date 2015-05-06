library ieee;
use ieee.std_logic_1164.all;

entity accum_mp is port (
    Clock, Reset: in std_logic;
	 Output: out std_logic_vector(7 downto 0);
	 Halt: out std_logic);
end accum_mp;

architecture accum_mpSructural of accum_mp is
  component cu PORT (
      Clock, Reset: in std_logic;
		-- control signals
		IRload, JMPmux, PCload, MemInst, MemWr: out std_logic;
		Asel: out std_logic_vector(1 downto 0);
		Aload, Sub: out std_logic;
		-- status signals
		IR: in std_logic_vector(7 downto 5);
		Aeq0, Apos: in std_logic;
		Halt: out std_logic);
	end component;
	
	component dp PORT (
	    Clock, Clear: in std_logic;
		 -- control signals
		 IRload, JMPmux, PCload, MemInst, MemWr: in std_logic;
		 ASel: in std_logic_vector(1 downto 0);
		 Aload, Sub: in std_logic;
		 -- status signals
		 IR: out std_logic_vector(7 downto 5);
		 Aeq0, Apos: out std_logic;
		 -- datapath output);
		 Output: out std_logic_vector(7 downto 0));
	 end component;
	 -- control signals
	 signal mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_MemWr: std_logic;
	 signal mp_Asel: std_logic_vector(1 downto 0);
	 signal mp_Aload, mp_Sub: std_logic;
	 -- status signals
	 signal mp_IR: std_logic_vector(7 downto 5);
	 signal mp_Aeq0, mp_Apos: std_logic;
begin
    U0: cu port map (
	     Clock, Reset,
		  --control signals
		  mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_MemWr,
		  mp_Asel,
		  mp_Aload, mp_Sub,
		  -- status signals
		  mp_IR,
		  mp_Aeq0, mp_Apos,
		  Halt);
	 U1: dp port map (
	     Clock, Reset,
		  --control signals
		  mp_IRload, mp_JMPmux, mp_PCload, mp_MemInst, mp_MemWr,
		  mp_Asel,
		  mp_Aload, mp_Sub,
		  -- status signals
		  mp_IR,
		  mp_Aeq0, mp_Apos,
		  Output);
end accum_mpSructural; 