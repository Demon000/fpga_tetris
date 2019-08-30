library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_timer is
generic(
    restart_on_end : boolean := false
);
port(
    clock : in STD_LOGIC;
    trigger_ticks : in natural;
    paused : in boolean;
    restart : in boolean;
    pulse : out STD_LOGIC
);
end clock_timer;

architecture main of clock_timer is
signal counted_clocks : natural := 0;
begin
    process(clock)
    variable last_paused : STD_LOGIC := '0';
    begin
        if rising_edge(clock) then
            if restart = true then
                counted_clocks <= 0;
            end if;

            if paused = false then
                if counted_clocks >= trigger_ticks - 1 then
                    pulse <= '1';
                    if restart_on_end = true then
                        counted_clocks <= 0;
                    end if;
                else
                    pulse <= '0';
                    counted_clocks <= counted_clocks + 1;
                end if;
            end if;
        end if;
    end process;
end main;
