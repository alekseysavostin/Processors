library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stack is generic(constant size: integer := 16; constant RAMSize: integer := 256);
port(
    Clk: in std_logic;  --Clock for the stack.
	 Reset: in std_logic; --Reset
    Enable: in std_logic;  --Enable the stack. Otherwise neither push nor pop will happen.
    Data_In: in std_logic_vector(size-1 downto 0);  --Data to be pushed to stack
	 Operation: in std_logic_vector(1 downto 0);
    Data_Out1: out std_logic_vector(size-1 downto 0);
	 Data_Out2: out std_logic_vector(size-1 downto 0));
end stack;

architecture Behavioral of stack is

type mem_type is array (RAMSize-1 downto 0) of std_logic_vector(size-1 downto 0);
signal stack_mem : mem_type := (others => (others => '0'));
signal stack_ptr : integer := RAMSize-1;

begin
    --PUSH and POP process for the stack.
    process(Clk, Reset, Operation, Enable)
    begin
        if(rising_edge(Clk) and Enable = '1') then
		      if (Reset = '1') then
				    stack_ptr <= RAMSize-1;
            elsif (Operation = "00") then --POP section.
                stack_ptr <= stack_ptr + 1; --Data has to be taken from the next highest address(empty descending type stack).
            elsif (Operation = "01") then --PUSH section.
                stack_mem(stack_ptr) <= Data_In; --Data pushed to the current address.
                stack_ptr <= stack_ptr - 1;
            elsif (Operation = "10") then
                stack_mem(stack_ptr+1) <= Data_In;
				elsif (Operation = "11") then
                stack_mem(stack_ptr+2) <= Data_In;
					 stack_ptr <= stack_ptr + 1;
            end if; 
        end if; 
    end process;
	 Data_Out1 <= stack_mem(stack_ptr+1); 
	 Data_Out2 <= stack_mem(stack_ptr+2);
end Behavioral;