library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_debouncer is
generic(
    max_button_count : natural := 10000000
);
port(
    clock: in STD_LOGIC;
    button_state : in STD_LOGIC := '0';
    button_press : out STD_LOGIC := '0'
);
end button_debouncer;

architecture main of button_debouncer is
begin
    process(clock)
    variable button_count : natural := 0;
    variable last_button_state : STD_LOGIC := '0';
    begin
        if rising_edge(clock) then
            if last_button_state /= button_state then
                if button_state = '1' then
                    button_count := 1;
                end if;

                last_button_state := button_state;
            end if;

            if button_count = max_button_count then
                button_press <= '1';
                button_count := 0;
            elsif button_count > 0 then
                button_count := button_count + 1;
            else
                button_press <= '0';
            end if;
        end if;
    end process;
end main;
