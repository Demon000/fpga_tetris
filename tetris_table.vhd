library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

library tetris_types;
use tetris_types.tetris_types.all;

entity tetris_table is
generic(
    size : size_2d
);
port(
    clock : in STD_LOGIC;
    point : in point_2d;
    color : out rgb_color;
    chosen_color : in rgb_color
);
end tetris_table;

architecture main of tetris_table is

signal table : tetris_table_data := tetris_table_data_init;
signal block_size : size_2d := (
    w => size.w / table_width_blocks,
    h => size.h / table_height_blocks
);

begin
    process(clock)
    begin
        if rising_edge(clock) then
            if point.x rem 20 < 10 then
                color <= black_color;
            else
                color <= chosen_color;
            end if;
        end if;
    end process;
end main;
