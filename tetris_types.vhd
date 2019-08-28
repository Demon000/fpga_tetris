library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.graphics.all;

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

    constant table_width_blocks : integer := 10;
    constant table_height_blocks : integer := 20;
    constant table_virtual_height_blocks : integer := 22;

    type tetris_table_data is array(
        0 to table_virtual_height_blocks - 1,
        0 to table_width_blocks - 1)
    of piece_color_id;

    constant tetris_table_data_init : tetris_table_data := (others => (others => empty_color_id));
end package tetris_types;
