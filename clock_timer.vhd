library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_timer is
generic(
    trigger_on_start : boolean := false
);
port(
    clock : in STD_LOGIC;
    trigger_ticks : in natural;
    stopped : in STD_LOGIC := '0';
    pulse : out STD_LOGIC
);
end clock_timer;

architecture main of clock_timer is
begin
    process(clock)
    variable counted_ticks : natural := 0;
    begin
        if rising_edge(clock) then
            pulse <= '0';

            if stopped = '1' then
                counted_ticks := 0;
            else
                if trigger_on_start then
                    if counted_ticks = 0 then
                        pulse <= '1';
                    end if;
                else
                    if counted_ticks = trigger_ticks then
                        pulse <= '1';
                    end if;
                end if;

                if counted_ticks = trigger_ticks then
                    counted_ticks := 0;
                else
                    counted_ticks := counted_ticks + 1;
                end if;
            end if;
        end if;
    end process;
end main;
