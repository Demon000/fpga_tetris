library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library tetris_types;
use tetris_types.tetris_types.all;

package tetris_time is
    function get_ticks_proportion(
            tps : natural;
            proportion : natural)
        return natural;

    function get_ticks_for_level(
            tps : natural;
            level : tetris_level)
        return natural;
end package tetris_time;

package body tetris_time is
    function get_ticks_proportion(
            tps : natural;
            proportion : natural)
        return natural is
    begin
        return tps * proportion / 1000;
    end function get_ticks_proportion;

    function get_ticks_for_level(
            tps : natural;
            level : tetris_level)
        return natural is
    variable ticks : natural;
    begin
        case level is
            when 1 => ticks := get_ticks_proportion(tps, 1000);
            when 2 => ticks := get_ticks_proportion(tps, 793);
            when 3 => ticks := get_ticks_proportion(tps, 617);
            when 4 => ticks := get_ticks_proportion(tps, 472);
            when 5 => ticks := get_ticks_proportion(tps, 355);
            when 6 => ticks := get_ticks_proportion(tps, 262);
            when 7 => ticks := get_ticks_proportion(tps, 189);
            when 8 => ticks := get_ticks_proportion(tps, 134);
            when 9 => ticks := get_ticks_proportion(tps, 93);
            when 10 => ticks := get_ticks_proportion(tps, 64);
        end case;

        return ticks;
    end function get_ticks_for_level;
end package body tetris_time;
