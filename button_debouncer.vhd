library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_debouncer is
generic(
    max_button_count : natural := 10000000
);
port(
    clock: in STD_LOGIC;
    button : in STD_LOGIC := '0';
    button_state : out STD_LOGIC := '0'
);
end button_debouncer;

architecture main of button_debouncer is
begin
    process(clock)
    variable button_count : natural := 0;
    begin
        if rising_edge(clock) then
            -- Whenever the button state changes to pressed,
            -- report the change and start counting to the time
            -- we will update the button press state
            if button = '1' then
                button_state <= '1';
                button_count := 0;
            end if;

            -- If we finished counting, update the button press state
            -- otherwise, continue counting
            if button_count = max_button_count then
                button_state <= button;
            else
                button_count := button_count + 1;
            end if;
        end if;
    end process;
end main;
