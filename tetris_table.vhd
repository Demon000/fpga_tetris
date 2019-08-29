library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

library tetris_types;
use tetris_types.tetris_types.all;

library tetris_pieces;
use tetris_pieces.tetris_pieces.all;

entity tetris_table is
generic(
    size : size_2d
);
port(
    clock : in STD_LOGIC;
    point : in point_2d;
    color : out rgb_color
);
end tetris_table;

architecture main of tetris_table is

signal table : tetris_table_data := tetris_table_data_init;
signal block_size : size_2d := (
    w => size.w / table_width_blocks,
    h => size.h / table_height_blocks
);

begin
    table(19, 0) <= i_color_id;
    table(19, 1) <= j_color_id;
    table(19, 2) <= l_color_id;
    table(19, 3) <= o_color_id;
    table(19, 4) <= s_color_id;
    table(19, 5) <= t_color_id;
    table(19, 6) <= z_color_id;
    table(19, 7) <= empty_color_id;
    table(19, 8) <= i_color_id;
    table(19, 9) <= j_color_id;

    process(clock)
    variable block_x : natural;
    variable block_y : natural;
    variable block_color_id : piece_color_id;
    variable block_color : rgb_color;
    begin
        if rising_edge(clock) then
            block_x := point.x / block_size.w;
            block_y := point.y / block_size.h;
            block_color_id := table(block_y, block_x);
            block_color := get_color_by_id(block_color_id);
            color <= block_color;
        end if;
    end process;
end main;
