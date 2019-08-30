library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

package tetris_types is
    subtype tetris_level is natural range 1 to 10;

    type piece_color_id is (
        empty_color_id,
        i_color_id,
        j_color_id,
        l_color_id,
        o_color_id,
        s_color_id,
        t_color_id,
        z_color_id
    );

    type tetris_point is record
        x : integer range -32 to 31;
        y : integer range -32 to 31;
    end record tetris_point;

    type tetris_size is record
        w : integer range -32 to 31;
        h : integer range -32 to 31;
    end record tetris_size;

    constant tetris_table_size : tetris_size := (10, 20);

    type tetris_table_data is array(
        0 to tetris_table_size.h - 1,
        0 to tetris_table_size.w - 1
    ) of piece_color_id;

    constant tetris_table_data_init : tetris_table_data := (others => (others => empty_color_id));
end package tetris_types;
