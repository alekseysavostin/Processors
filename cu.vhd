library ieee;
use ieee.std_logic_1164.all;

entity cu is port (
    Clock, Reset: in std_logic;
	 -- control signals
	 IRLoad, JMPmux, PCload, MemInst, MemWr: out std_logic;
	 Asel: out std_logic_vector(1 downto 0);
	 Aload: out std_logic;
	 ALUSel: out std_logic_vector(3 downto 0); -- select for operations
	 -- status signals
	 IR: in std_logic_vector(11 downto 8);
	 Aeq0, Apos: in std_logic;
	 -- control outputs
	 Halt: out std_logic);
end cu;

architecture FSM of cu is
    type state_type is (s_start, s_fetch, s_decode,
	     s_load, s_store, s_alu, s_mov, s_jz, s_jpos, s_halt); -- s_nop
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
					     when "0000" => state <= s_mov; -- MOV
						  when "0001" => state <= s_alu; -- AND
						  when "0010" => state <= s_alu; -- OR
						  when "0011" => state <= s_alu; -- XOR
						  when "0100" => state <= s_alu; -- NOT
						  when "0101" => state <= s_alu; -- ADD
						  when "0110" => state <= s_alu; -- SUB
						  when "0111" => state <= s_alu; -- DEC
						  when "1000" => state <= s_alu; -- INC
						  when "1001" => state <= s_alu; -- SHR
						  when "1010" => state <= s_alu; -- SHL
						  when "1011" => state <= s_load; -- LOAD
						  when "1100" => state <= s_store; -- STORE
						  --when "1101" => state <= s_alu; -- (duplicate)
						  when "1101" => state <= s_jz;
						  when "1110" => state <= s_jpos;
						  when "1111" => state <= s_halt;
						  when others => state <= s_halt;
					 end case;
				when s_load => state <= s_start;
				when s_store => state <= s_start;
				when s_alu => state <= s_start;
				--when s_nop => state <= s_start;
				when s_mov => state <= s_start;
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
				ALUSel <= "0000";
				Halt <= '0';
		  when s_decode => -- also set up for memory access
		      IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1'; -- pass IR address to memory
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				ALUSel <= "0000";
				Halt <= '0';
		  when s_load =>
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1';
				MemWr <= '0';
				Asel <= "10"; -- pass memory to A
				Aload <= '1'; -- load A
				ALUSel <= "0000";
				Halt <= '0';
		  when s_store =>
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1'; -- pass IR address to memory
				MemWr <= '1'; -- store A to memory
				Asel <= "00"; 
				Aload <= '0';
				ALUSel <= "0000";
				Halt <= '0';
			when s_alu =>
			   IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '1';
				MemWr <= '0';
				Asel <= "00"; -- pass add/sub unit to A 
				Aload <= '1'; -- load A
				--if IR = "0010" then ALUSel <= "0101"; -- ADD
				--elsif IR = "0011"  then ALUSel <= "0110"; -- SUB
				--elsif IR = "0100" then ALUSel <= "0001"; -- AND
				--elsif IR = "0101" then ALUSel <= "0010"; -- OR
				--elsif IR = "0110" then ALUSel <= "0011"; -- XOR
				--elsif IR = "0111" then ALUSel <= "0100"; -- NOT
				--elsif IR = "1000" then ALUSel <= "1011"; -- INC
				--elsif IR = "1001" then ALUSel <= "0111"; -- DEC
				--else ALUSel <= "0000";
				--end if;
				ALUSel <= IR;
				Halt <= '0';
			--when s_nop =>
			--   IRload <= '0';
			--	JMPmux <= '0';
			--	PCload <= '0';
			--	Meminst <= '0';
			--	MemWr <= '0';
			--	Asel <= "00";
			--	Aload <= '0';
			--	ALUSel <= "0000";
			--	Halt <= '0';
			when s_mov =>
			   IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "01"; -- pass input to A 
				Aload <= '1'; -- load A
				ALUSel <= "0000";
				Halt <= '0';
			when s_jz =>
			   IRload <= '0';
				JMPmux <= '1'; -- pass IR address to PC
				PCload <= Aeq0; -- load PC if condition is true
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				ALUSel <= "0000";
				Halt <= '0';
			when s_jpos =>
			   IRload <= '0';
				JMPmux <= '1'; -- pass IR address to PC
				PCload <= Apos; -- load PC if condition is true
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				ALUSel <= "0000";
				Halt <= '0';
			when s_halt => 
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				ALUSel <= "0000";
				Halt <= '1';
         when others => 
            IRload <= '0';
				JMPmux <= '0';
				PCload <= '0';
				Meminst <= '0';
				MemWr <= '0';
				Asel <= "00";
				Aload <= '0';
				ALUSel <= "0000";
				Halt <= '0';
         end case;
	 end process;
end FSM;
