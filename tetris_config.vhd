library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

package tetris_config is
    type piece_falling_ticks_data is array(0 to 9) of natural;
    type tetris_config is record
        piece_falling_ticks : piece_falling_ticks_data;
        table_position : point_2d;
        table_size : size_2d;
        block_size : size_2d;
    end record;

    constant tetris_config_1280_1024_60 : tetris_config := (
        piece_falling_ticks => (
            108108108, -- level 1
            108108108,
            108108108,
            108108108,
            108108108,
            108108108,
            108108108,
            108108108,
            108108108,
            108108108 -- level 10
        ),
        table_position => (200, 200),
        table_size => (400, 800),
        block_size => (40, 40)
    );
end package tetris_config;
