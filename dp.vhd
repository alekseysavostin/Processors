library ieee;
use ieee.std_logic_1164.all;

library lpm; -- for memory
use lpm.lpm_components.all;

entity dp is port(
    Clock, Clear: in std_logic;
	 -- control signals
    IRLoad, JMPmux, PCload, MemInst, MemWr: in std_logic;
    ASel: in std_logic_vector(1 downto 0);
	 Aload, Sub: in std_logic;
	 -- status signals
	 IR: out std_logic_vector(7 downto 5);
	 Aeq0, Apos: out std_logic;
	 Output: out std_logic_vector(7 downto 0)); -- datapath output
end dp;

architecture dpStructutal of dp is
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
	 
	 component addsub
	 generic(n: integer := 4);
	 port (
	     S: in std_logic;
		  A: in std_logic_vector(n-1 downto 0);
		  B: in std_logic_vector(n-1 downto 0);
		  F: out std_logic_vector(n-1 downto 0);
		  unsigned_overflow: out std_logic;
		  signed_overflow: out std_logic);
    end component;
	 
	 signal dp_IR, dp_RAMQ: std_logic_vector(7 downto 0);
	 signal dp_JMPmux, dp_PC, dp_increment, dp_meminst: std_logic_vector(4 downto 0);
	 signal dp_Amux, dp_addsub, dp_A: std_logic_vector(7 downto 0);

begin
    -- IR
    U0: reg generic map(8) port map (Clock, Clear, IRLoad, dp_RAMQ, dp_IR);
	 IR <= dp_IR(7 downto 5);
	 -- JMPmux
	 U1: mux2 generic map(5) port map (JMPmux, dp_IR(4 downto 0), dp_increment, dp_JMPmux);
	 -- PC
	 U2: reg generic map(5) port map (Clock, Clear, PCLoad, dp_JMPmux, dp_PC);
	 -- memInst
	 U3: mux2 generic map(5) port map (Meminst, dp_IR(4 downto 0), dp_PC, dp_meminst);
	 -- increment
	 U4: increment generic map(5) port map(dp_PC, dp_increment);
	 -- memory
	 U5: lpm_ram_dq
	     generic map (
	         lpm_widthad => 5,
		      lpm_outdata => "UNREGISTERED",
		      lpm_file => "program.mif",
		      lpm_width => 8)
		  port map (
		      data => dp_A,
				address => dp_meminst,
				we => MemWr,
				inclock => Clock,
				q => dp_RAMQ);
    -- A input mux
    U6: mux4 generic map(8) port map (Asel, dp_RAMQ, dp_RAMQ, dp_RAMQ, dp_addsub, dp_Amux);
	 -- Accumulator
	 U7: reg generic map(8) port map (Clock, Clear, ALoad, dp_Amux, dp_A);
	 -- Adder-substractor
	 U8: addsub generic map(8) port map (Sub, dp_A, dp_RAMQ, dp_addsub, open, open);
	 
	 Aeq0 <= '1' when dp_A = "00000000" else '0';
	 Apos <= not dp_A(7);
	 Output <= dp_A;
end dpStructutal;