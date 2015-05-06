library ieee;
use ieee.std_logic_1164.all;

entity cu is port (
    Clock, Reset: in std_logic;
	 -- control signals
	 IRLoad, JMPmux, PCload, MemInst, MemWr: out std_logic;
	 Asel: out std_logic_vector(1 downto 0);
	 Aload, Sub: out std_logic;
	 -- status signals
	 IR: in std_logic_vector(7 downto 5);
	 Aeq0, Apos: in std_logic;
	 -- control outputs
	 Halt: out std_logic);
end cu;

architecture FSM of cu is
    type state_type is (s_start, s_fetch, s_decode,
	     s_load, s_store, s_add, s_sub, s_nop, s_jz, s_jpos, s_halt);
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
					     when "000" => state <= s_load;
						  when "001" => state <= s_store;
						  when "010" => state <= s_add;
						  when "011" => state <= s_sub;
						  when "100" => state <= s_nop;
						  --when "100" => state <= s_in;
						  when "101" => state <= s_jz;
						  when "110" => state <= s_jpos;
						  when "111" => state <= s_halt;
						  when others => state <= s_halt;
					 end case;
				when s_load => state <= s_start;
				when s_store => state <= s_start;
				when s_add => state <= s_start;
				when s_sub => state <= s_start;
				when s_nop => state <= s_start;
				--when s_in =>
				--    if (Enter = '0') then -- wait for the Enter key for inputs
				--	     state <= s_in;
				--	 else
				--	     state <= s_start;
				--	 end if;
				when s_jz => state <= s_start;
				when s_jpos => state <= s_start;
				when s_halt => state <= s_halt;
				when others => state <= s_start;
				end case;
        end if;
    end process;
	 
	 output_logic: process (state)
	 begin
	     case state is
		  when s_fetch =>
		      IRload <= '1'; -- load IR
				JMPmux <= '0';
				PCload <= '1'; -- increment PC
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				Sub <= '0';
				Halt <= '0';
		  when s_decode => -- also set up for memory access
		      IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1'; -- pass IR address to memory
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				Sub <= '0';
				Halt <= '0';
		  when s_load =>
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1';
				MemWr <= '0';
				Asel <= "10"; -- pass memory to A
				Aload <= '1'; -- load A
				Sub <= '0';
				Halt <= '0';
		  when s_store =>
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1'; -- pass IR address to memory
				MemWr <= '1'; -- store A to memory
				Asel <= "00"; 
				Aload <= '0';
				Sub <= '0';
				Halt <= '0';
			when s_add =>
			   IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1';
				MemWr <= '0';
				Asel <= "00"; -- pass add/sub unit to A 
				Aload <= '1'; -- load A
				Sub <= '0'; -- select add
				Halt <= '0';
			when s_sub =>
			   IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1';
				MemWr <= '0';
				Asel <= "00"; -- pass add/sub unit to A 
				Aload <= '1'; -- load A
				Sub <= '1'; -- select add
				Halt <= '0';
			when s_nop =>
			   IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				Sub <= '0';
				Halt <= '0';
			--when s_in =>
			--   IRload <= '0';
			--	JMPmux <= '0';
			--	PCload <= '0';
			--	Meminst <= '0';
			--	MemWr <= '0';
			--	Asel <= "01"; -- pass input to A 
			--	Aload <= '1'; -- load A
			--	Sub <= '0';
			--	Halt <= '0';
			when s_jz =>
			   IRload <= '0';
				JMPmux <= '1'; -- pass IR address to PC
				PCload <= Aeq0; -- load PC if condition is true
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				Sub <= '0';
				Halt <= '0';
			when s_jpos =>
			   IRload <= '0';
				JMPmux <= '1'; -- pass IR address to PC
				PCload <= Apos; -- load PC if condition is true
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				Sub <= '0';
				Halt <= '0';
			when s_halt => 
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				Sub <= '0';
				Halt <= '1';
         when others => 
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				Sub <= '0';
				Halt <= '0';
         end case;
	 end process;
end FSM;
