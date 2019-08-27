library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_pulser is
port(
    clock: in STD_LOGIC;
    button_state : in STD_LOGIC := '0';
    button_press : out STD_LOGIC := '0'
);
end button_pulser;

architecture main of button_pulser is
begin
    process(clock)
    variable button_state_reported : STD_LOGIC := '0';
    begin
        if rising_edge(clock) then
            if button_state = '1' and button_state_reported = '0' then
                button_press <= '1';
                button_state_reported := '1';
            elsif button_state = '0' then
                button_state_reported := '0';
            else
                button_press <= '0';
            end if;
        end if;
    end process;
end main;
