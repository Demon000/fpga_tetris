library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

library tetris_types;
use tetris_types.tetris_types.all;

package tetris_pieces is
    type tetris_piece_rotation_id is (
        tetris_normal_rotation_id,
        tetris_first_rotation_id,
        tetris_second_rotation_id,
        tetris_third_rotation_id
    );

    constant tetris_piece_table_size : size_2d := (4, 4);
    type tetris_piece_table_data is array(
        0 to tetris_piece_table_size.h - 1,
        0 to tetris_piece_table_size.w - 1
    ) of bit;
    type tetris_piece is record
        table_0 : tetris_piece_table_data;
        table_90 : tetris_piece_table_data;
        table_180 : tetris_piece_table_data;
        table_270 : tetris_piece_table_data;
    end record tetris_piece;

    function get_next_rotation_id(
            rotation_id : in tetris_piece_rotation_id)
        return tetris_piece_rotation_id;

    function get_piece_by_type_id(
            type_id : tetris_piece_id)
        return tetris_piece;

    function get_block_color_pallete_by_id(
            type_id : tetris_piece_id)
        return tetris_block_color_pallete;

    function get_block_texture_by_id(
            type_id : tetris_piece_id)
        return tetris_block_texture_table_data;

    function get_rotation_table_by_type_id(
            type_id : tetris_piece_id;
            rotation_id : tetris_piece_rotation_id)
        return tetris_piece_table_data;

    -- Empty piece
    constant empty_piece_table : tetris_piece_table_data := (
        "0000",
        "0000",
        "0000",
        "0000"
    );
    constant empty_piece : tetris_piece := (
        table_0 => empty_piece_table,
        table_90 => empty_piece_table,
        table_180 => empty_piece_table,
        table_270 => empty_piece_table
    );

    -- I piece
    constant i_piece : tetris_piece := (
        table_0 => (
            "0000",
            "1111",
            "0000",
            "0000"
        ),
        table_90 => (
            "0010",
            "0010",
            "0010",
            "0010"
        ),
        table_180 => (
            "0000",
            "0000",
            "1111",
            "0000"
        ),
        table_270 => (
            "0100",
            "0100",
            "0100",
            "0100"
        )
    );

    -- J piece
    constant j_piece : tetris_piece := (
        table_0 => (
            "1000",
            "1110",
            "0000",
            "0000"
        ),
        table_90 => (
            "0110",
            "0100",
            "0100",
            "0000"
        ),
        table_180 => (
            "0000",
            "1110",
            "0010",
            "0000"
        ),
        table_270 => (
            "0100",
            "0100",
            "1100",
            "0000"
        )
    );

    -- L piece
    constant l_piece : tetris_piece := (
        table_0 => (
            "0010",
            "1110",
            "0000",
            "0000"
        ),
        table_90 => (
            "0100",
            "0100",
            "0110",
            "0000"
        ),
        table_180 => (
            "0000",
            "1110",
            "1000",
            "0000"
        ),
        table_270 => (
            "1100",
            "0100",
            "0100",
            "0000"
        )
    );

    -- O piece
    constant o_piece_table : tetris_piece_table_data := (
        "0110",
        "0110",
        "0000",
        "0000"
    );
    constant o_piece : tetris_piece := (
        table_0 => o_piece_table,
        table_90 => o_piece_table,
        table_180 => o_piece_table,
        table_270 => o_piece_table
    );

    -- S piece
    constant s_piece : tetris_piece := (
        table_0 => (
            "0110",
            "1100",
            "0000",
            "0000"
        ),
        table_90 => (
            "0100",
            "0110",
            "0010",
            "0000"
        ),
        table_180 => (
            "0000",
            "0110",
            "1100",
            "0000"
        ),
        table_270 => (
            "1000",
            "1100",
            "0100",
            "0000"
        )
    );

    -- T piece
    constant t_piece : tetris_piece := (
        table_0 => (
            "0100",
            "1110",
            "0000",
            "0000"
        ),
        table_90 => (
            "0100",
            "0110",
            "0100",
            "0000"
        ),
        table_180 => (
            "0000",
            "1110",
            "0100",
            "0000"
        ),
        table_270 => (
            "0100",
            "1100",
            "0100",
            "0000"
        )
    );

    -- Z piece
    constant z_piece : tetris_piece := (
        table_0 => (
            "1100",
            "0110",
            "0000",
            "0000"
        ),
        table_90 => (
            "0010",
            "0110",
            "0100",
            "0000"
        ),
        table_180 => (
            "0000",
            "1100",
            "0110",
            "0000"
        ),
        table_270 => (
            "0100",
            "1100",
            "1000",
            "0000"
        )
    );
end package tetris_pieces;

package body tetris_pieces is
    function get_next_rotation_id(
            rotation_id : in tetris_piece_rotation_id)
        return tetris_piece_rotation_id is
    variable next_rotation_id : tetris_piece_rotation_id;
    begin
        case rotation_id is
            when tetris_normal_rotation_id => next_rotation_id := tetris_first_rotation_id;
            when tetris_first_rotation_id => next_rotation_id := tetris_second_rotation_id;
            when tetris_second_rotation_id => next_rotation_id := tetris_third_rotation_id;
            when tetris_third_rotation_id => next_rotation_id := tetris_normal_rotation_id;
        end case;

        return next_rotation_id;
    end function get_next_rotation_id;

    function get_piece_by_type_id(
            type_id : tetris_piece_id)
        return tetris_piece is
    variable piece : tetris_piece;
    begin
        case type_id is
            when tetris_empty_id => piece := empty_piece;
            when tetris_i_id => piece := i_piece;
            when tetris_j_id => piece := j_piece;
            when tetris_l_id => piece := l_piece;
            when tetris_o_id => piece := o_piece;
            when tetris_s_id => piece := s_piece;
            when tetris_t_id => piece := t_piece;
            when tetris_z_id => piece := z_piece;
        end case;

        return piece;
    end function get_piece_by_type_id;

    function get_block_color_pallete_by_id(
            type_id : tetris_piece_id)
        return tetris_block_color_pallete is
    variable color_pallete : tetris_block_color_pallete;
    begin
        case type_id is
            when tetris_empty_id => color_pallete := tetris_empty_color_pallete;
            when tetris_i_id => color_pallete := tetris_i_color_pallete;
            when tetris_j_id => color_pallete := tetris_j_color_pallete;
            when tetris_l_id => color_pallete := tetris_l_color_pallete;
            when tetris_o_id => color_pallete := tetris_o_color_pallete;
            when tetris_s_id => color_pallete := tetris_s_color_pallete;
            when tetris_t_id => color_pallete := tetris_t_color_pallete;
            when tetris_z_id => color_pallete := tetris_z_color_pallete;
        end case;

        return color_pallete;
    end function get_block_color_pallete_by_id;

    function get_block_texture_by_id(
            type_id : tetris_piece_id)
        return tetris_block_texture_table_data is
    variable block_texture : tetris_block_texture_table_data;
    begin
        case type_id is
            when tetris_empty_id => block_texture := tetris_empty_block_texture_table;
            when tetris_i_id => block_texture := tetris_piece_block_texture_table;
            when tetris_j_id => block_texture := tetris_piece_block_texture_table;
            when tetris_l_id => block_texture := tetris_piece_block_texture_table;
            when tetris_o_id => block_texture := tetris_piece_block_texture_table;
            when tetris_s_id => block_texture := tetris_piece_block_texture_table;
            when tetris_t_id => block_texture := tetris_piece_block_texture_table;
            when tetris_z_id => block_texture := tetris_piece_block_texture_table;
        end case;

        return block_texture;
    end function get_block_texture_by_id;

    function get_rotation_table_by_type_id(
            type_id : tetris_piece_id;
            rotation_id : tetris_piece_rotation_id)
        return tetris_piece_table_data is
    variable table : tetris_piece_table_data;
    variable piece : tetris_piece;
    begin
        piece := get_piece_by_type_id(type_id);

        case rotation_id is
            when tetris_normal_rotation_id => table := piece.table_0;
            when tetris_first_rotation_id => table := piece.table_90;
            when tetris_second_rotation_id => table := piece.table_180;
            when tetris_third_rotation_id => table := piece.table_270;
        end case;

        return table;
    end function get_rotation_table_by_type_id;
end package body tetris_pieces;
