library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library tetris_types;
use tetris_types.tetris_types.all;

package tetris_time is
    function get_fall_ticks_for_level(
            level : tetris_level;
            tps : natural)
        return natural;
end package tetris_time;

package body tetris_time is
    function get_fall_ticks_for_level(
            level : tetris_level;
            tps : natural)
        return natural is
     variable ticks : natural;
     begin
        case level is
            when 1 => ticks := tps * 1000 / 1000;
            when 2 => ticks := tps * 793 / 1000;
            when 3 => ticks := tps * 617 / 1000;
            when 4 => ticks := tps * 472 / 1000;
            when 5 => ticks := tps * 355 / 1000;
            when 6 => ticks := tps * 262 / 1000;
            when 7 => ticks := tps * 189 / 1000;
            when 8 => ticks := tps * 134 / 1000;
            when 9 => ticks := tps * 93 / 1000;
            when 10 => ticks := tps * 64 / 1000;
         end case;

         return ticks;
     end function get_fall_ticks_for_level;
end package body tetris_time;
