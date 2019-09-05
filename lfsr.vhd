library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lfsr_3 is
port (
    clock : in STD_LOGIC;
    output : out STD_LOGIC_VECTOR(2 downto 0)
);
end entity;

architecture main of lfsr_3 is
signal lfsr : STD_LOGIC_VECTOR(31 downto 0) := "10101010101010101010101010101010";
signal feedback : STD_LOGIC;
begin

    feedback <= lfsr(31) xor lfsr(21) xor lfsr(1) xor lfsr(0);		

    process (clock) 
    begin
        if (rising_edge(clock)) then
            lfsr <= lfsr(30 downto 0) & feedback;
        end if;
    end process;
    
    output <= lfsr(31 downto 29);

end architecture;
