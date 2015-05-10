library ieee;
use ieee.std_logic_1164.all;

entity stack_cu is port (
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
end stack_cu;

architecture FSM of stack_cu is
    type state_type is (s_start, s_fetch, s_decode,
	     s_load, s_store, s_alu, s_mov, s_next, s_setd, s_set_poly, s_initLfsr, s_nop, s_jz, s_jpos, s_halt); -- s_nop
	 signal state: state_type;
begin
    next_state_logic: process (Reset, Clock)
	 begin
	     if(Reset = '1') then
		      state <= s_start;
		  elsif(Clock'event and Clock='1') then
		      case state is
				when s_start => -- reset
				    state <= s_fetch;
				when s_fetch =>
				    state <= s_decode;
				when s_decode =>
				    case IR is
					     when "0000" => state <= s_mov;      -- MOV
						  when "0001" => state <= s_alu;      -- AND
						  when "0010" => state <= s_alu;      -- OR
						  when "0011" => state <= s_alu;      -- XOR
						  when "0100" => state <= s_alu;      -- NOT
						  when "0101" => state <= s_alu;      -- ADD
						  when "0110" => state <= s_alu;      -- SUB
						  when "0111" => state <= s_next;      -- NEXT (generate next bin in LFSR)
						  when "1000" => state <= s_store;    -- STORE
						  when "1001" => state <= s_load;     -- LOAD
						  when "1010" => state <= s_initLfsr; -- INITLFSR
						  when "1011" => state <= s_set_poly; -- SETPOLY (Set LFSR polynom)
						  when "1100" => state <= s_setd;     -- SETD (Set LFSR dimension)
						  when "1101" => state <= s_jz;       -- JZ
						  when "1110" => state <= s_jpos;     -- JP
						  when "1111" => state <= s_halt;     -- HALT
						  when others => state <= s_halt;
					 end case;
				when s_load => state <= s_start;
				when s_store => state <= s_start;
				when s_alu => state <= s_start;
				when s_setd => state <= s_start;
            when s_set_poly => state <= s_start;
            when s_initLfsr => state <= s_start;
				when s_nop => state <= s_start;
				when s_mov => state <= s_start;
				when s_jz => state <= s_start;
				when s_jpos => state <= s_start;
				when s_halt => state <= s_halt;
				when others => state <= s_start;
				end case;
        end if;
    end process;
	 
	 output_logic: process (state)
	 begin
 		  IRload <= '0';
 		  JMPmux <= '0';
 		  PCload <= '0';
 		  Meminst <= '0';
 		  MemWr <= '0';
 		  Asel <= "00";
 		  Aload <= '0';
 		  ALUSel <= "000";
		  NextLfsr <= '0';
		  SetDimension <= '0';
		  SetPolynom <= '0';
        InitLfsr <= '0';
		  Halt <= '0';
	     case state is
		  when s_fetch =>
		      IRload <= '1'; -- load IR
				PCload <= '1'; -- increment PC
        when s_next =>
            Aload <= '1';
				Asel <= "11"; -- out from LFSR
            NextLfsr <= '1';
		  when s_decode => -- also set up for memory access
				Meminst <= '1'; -- pass IR address to memory
		  when s_load =>
				Meminst <= '1';
				Asel <= "10"; -- pass memory to A
				Aload <= '1'; -- load A
		  when s_store =>
				Meminst <= '1'; -- pass IR address to memory
				MemWr <= '1'; -- store A to memory
			when s_alu =>
				Meminst <= '1';
				Asel <= "00"; -- pass add/sub unit to A 
				Aload <= '1'; -- load A
				ALUSel <= IR(10 downto 8);
			when s_mov =>
				Asel <= "01"; -- pass input to A 
				Aload <= '1'; -- load A
			when s_setd =>
			   SetDimension <= '1';
			when s_set_poly =>
			   SetPolynom <= '1';
         when s_initLfsr =>
            InitLfsr <= '1';             
			when s_jz =>
				JMPmux <= '1'; -- pass IR address to PC
				PCload <= Aeq0; -- load PC if condition is true
			when s_jpos =>
				JMPmux <= '1'; -- pass IR address to PC
				PCload <= Apos; -- load PC if condition is true
			when s_halt => 
				Halt <= '1';
         when others => 
 		      IRload <= '0';
 		      JMPmux <= '0';
 		      PCload <= '0';
 		      Meminst <= '0';
 		      MemWr <= '0';
 		      Asel <= "00";
 		      Aload <= '0';
 		      ALUSel <= "000";
		      NextLfsr <= '0';
		      SetDimension <= '0';
		      SetPolynom <= '0';
            InitLfsr <= '0'; 
				Halt <= '0';
         end case;
	 end process;
end FSM;
