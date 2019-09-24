library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_debouncer is
port(
    clock: in STD_LOGIC;
    button : in STD_LOGIC := '0';
    button_state : out STD_LOGIC := '0';
    min_button_ticks : natural := 10000000
);
end button_debouncer;

architecture main of button_debouncer is
begin
    process(clock)
    variable button_ticks : natural := 0;
    begin
        if rising_edge(clock) then
            -- Whenever the button state changes to pressed,
            -- report the change and start counting to the time
            -- we will update the button press state
            if button = '1' then
                button_state <= '1';
                button_ticks := 0;
            end if;

            -- If we finished counting, update the button press state
            -- otherwise, continue counting
            if button_ticks >= min_button_ticks - 1 then
                button_state <= button;
            else
                button_ticks := button_ticks + 1;
            end if;
        end if;
    end process;
end main;
