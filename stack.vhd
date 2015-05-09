library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stack is generic(constant size: integer := 16; constant RAMSize: integer := 256);
port(
    Clk: in std_logic;  --Clock for the stack.
	 Reset: in std_logic; --Reset
    Enable: in std_logic;  --Enable the stack. Otherwise neither push nor pop will happen.
    Data_In: in std_logic_vector(size-1 downto 0);  --Data to be pushed to stack
	 PUSH_barPOP: in std_logic;  --active low for POP and active high for PUSH.
    Data_Out: out std_logic_vector(size-1 downto 0);  --Data popped from the stack.
    Stack_Full: out std_logic;  --Goes high when the stack is full.
    Stack_Empty: out std_logic  --Goes high when the stack is empty.
    );
end stack;

architecture Behavioral of stack is

type mem_type is array (RAMSize-1 downto 0) of std_logic_vector(size-1 downto 0);
signal stack_mem : mem_type := (others => (others => '0'));
signal stack_ptr : integer := RAMSize-1;
signal full, empty : std_logic := '0';

begin
    Stack_Full <= full; 
    Stack_Empty <= empty;
    
    --PUSH and POP process for the stack.
    process(Clk, Reset, PUSH_barPOP, Enable)
    begin
        if(rising_edge(Clk)) then
		      if (Reset = '1') then
				    stack_ptr <= RAMSize-1;
					 full <= '0';
					 empty <= '1';
            end if;
            --PUSH section.
            if (Enable = '1' and PUSH_barPOP = '1' and full = '0') then
                 --Data pushed to the current address.
                stack_mem(stack_ptr) <= Data_In; 
                if(stack_ptr /= 0) then
                    stack_ptr <= stack_ptr - 1;
                end if; 
                --setting full and empty flags
                if(stack_ptr = 0) then
                    full <= '1';
                    empty <= '0';
                elsif(stack_ptr = RAMSize-1) then
                    full <= '0';
                    empty <= '1';
                else
                    full <= '0';
                    empty <= '0';
                end if;
            end if;
            --POP section.
            if (Enable = '1' and PUSH_barPOP = '0' and empty = '0') then
            --Data has to be taken from the next highest address(empty descending type stack).
                if(stack_ptr /= RAMSize-1) then   
                    Data_Out <= stack_mem(stack_ptr+1); 
                    stack_ptr <= stack_ptr + 1;
                end if; 
                --setting full and empty flags
                if(stack_ptr = 0) then
                    full <= '1';
                    empty <= '0';
                elsif(stack_ptr = RAMSize-1) then
                    full <= '0';
                    empty <= '1';
                else
                    full <= '0';
                    empty <= '0';
                end if; 
            end if;
        end if; 
    end process;
end Behavioral;