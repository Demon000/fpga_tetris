library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

package tetris_types is
    subtype tetris_level is natural range 1 to 10;
    constant tetris_first_level : tetris_level := 1;
    constant tetris_last_level : tetris_level := 10;

    type tetris_piece_falling_ticks_data is array(tetris_first_level to tetris_last_level) of natural;

    type tetris_state is (
        tetris_init_state,
        tetris_generate_new_piece_state,
        tetris_wait_fall_piece_state,
        tetris_try_fall_piece_state,
        tetris_try_move_piece_left_state,
        tetris_try_move_piece_right_state,
        tetris_try_rotate_piece_right_state,
        tetris_do_fall_piece_state,
        tetris_do_move_piece_left_state,
        tetris_do_move_piece_right_state,
        tetris_do_rotate_piece_right_state,
        tetris_place_piece_state
    );

    type tetris_config is record
        piece_falling_ticks : tetris_piece_falling_ticks_data;
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
        table_position => (0, 0),
        table_size => (400, 800),
        block_size => (40, 40)
    );

    type tetris_piece_id is (
        tetris_empty_id,
        tetris_i_id,
        tetris_j_id,
        tetris_l_id,
        tetris_o_id,
        tetris_s_id,
        tetris_t_id,
        tetris_z_id
    );

    subtype tetris_point_int is integer range -32 to 31;
    type tetris_point is record
        x : tetris_point_int;
        y : tetris_point_int;
    end record tetris_point;

    subtype tetris_size_nat is integer range 0 to 32;
    type tetris_size is record
        w : tetris_size_nat;
        h : tetris_size_nat;
    end record tetris_size;

    constant tetris_table_size : tetris_size := (10, 20);
    constant tetris_default_falling_piece_position : tetris_point := (3, -2);

    type tetris_table_data is array(
        0 to tetris_table_size.h - 1,
        0 to tetris_table_size.w - 1
    ) of tetris_piece_id;

    constant tetris_table_init : tetris_table_data := (others => (others => tetris_empty_id));
end package tetris_types;
