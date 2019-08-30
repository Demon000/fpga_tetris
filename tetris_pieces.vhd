library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

library tetris_types;
use tetris_types.tetris_types.all;

package tetris_pieces is
    type piece_type_id is (
        i_type_id,
        j_type_id,
        l_type_id,
        o_type_id,
        s_type_id,
        t_type_id,
        z_type_id
    );

    type piece_rotation_id is (
        normal_rotation_id,
        first_rotation_id,
        second_rotation_id,
        third_rotation_id
    );

    constant piece_table_size : size_2d := (4, 4);
    type piece_table_data is array(
        0 to piece_table_size.h - 1,
        0 to piece_table_size.w - 1
    ) of bit;
    type tetris_piece is record
        table_0 : piece_table_data;
        table_90 : piece_table_data;
        table_180 : piece_table_data;
        table_270 : piece_table_data;
    end record tetris_piece;

    function get_next_rotation(
            rotation_id : in piece_rotation_id)
        return piece_rotation_id;

    function get_prev_rotation(
            rotation_id : in piece_rotation_id)
        return piece_rotation_id;

    function get_piece_by_type_id(
            type_id : piece_type_id)
        return tetris_piece;

    function get_color_by_id(
            color_id : piece_color_id)
        return rgb_color;

    function get_color_id_by_type_id(
            type_id : piece_type_id)
        return piece_color_id;

    function get_color_by_type_id(
            type_id : piece_type_id)
        return rgb_color;

    function get_rotation_table_by_type_id(
            type_id : piece_type_id;
            rotation_id : piece_rotation_id)
        return piece_table_data;

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
    constant o_piece_table : piece_table_data := (
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
end package tetris_pieces;

package body tetris_pieces is
    function get_next_rotation(
            rotation_id : in piece_rotation_id)
        return piece_rotation_id is
    variable next_rotation_id : piece_rotation_id;
    begin
        case rotation_id is
            when normal_rotation_id => next_rotation_id := first_rotation_id;
            when first_rotation_id => next_rotation_id := second_rotation_id;
            when second_rotation_id => next_rotation_id := third_rotation_id;
            when third_rotation_id => next_rotation_id := normal_rotation_id;
        end case;

        return next_rotation_id;
    end function get_next_rotation;

    function get_prev_rotation(
            rotation_id : in piece_rotation_id)
        return piece_rotation_id is
    variable prev_rotation_id : piece_rotation_id;
    begin
        case rotation_id is
            when normal_rotation_id => prev_rotation_id := third_rotation_id;
            when first_rotation_id => prev_rotation_id := normal_rotation_id;
            when second_rotation_id => prev_rotation_id := first_rotation_id;
            when third_rotation_id => prev_rotation_id := second_rotation_id;
        end case;

        return prev_rotation_id;
    end function get_prev_rotation;

    function get_piece_by_type_id(
            type_id : piece_type_id)
        return tetris_piece is
    variable piece : tetris_piece;
    begin
        case type_id is
            when i_type_id => piece := i_piece;
            when j_type_id => piece := j_piece;
            when l_type_id => piece := l_piece;
            when o_type_id => piece := o_piece;
            when s_type_id => piece := s_piece;
            when t_type_id => piece := t_piece;
            when z_type_id => piece := z_piece;
        end case;

        return piece;
    end function get_piece_by_type_id;

    function get_color_by_id(
            color_id : piece_color_id)
        return rgb_color is
    variable color : rgb_color;
    begin
        case color_id is
            when empty_color_id => color := black_color;
            when i_color_id => color := cyan_color;
            when j_color_id => color := blue_color;
            when l_color_id => color := orange_color;
            when o_color_id => color := yellow_color;
            when s_color_id => color := green_color;
            when t_color_id => color := magenta_color;
            when z_color_id => color := red_color;
        end case;

        return color;
    end function get_color_by_id;

    function get_color_id_by_type_id(
            type_id : piece_type_id)
        return piece_color_id is
    variable color_id : piece_color_id;
    begin
        case type_id is
            when i_type_id => color_id := i_color_id;
            when j_type_id => color_id := j_color_id;
            when l_type_id => color_id := l_color_id;
            when o_type_id => color_id := o_color_id;
            when s_type_id => color_id := s_color_id;
            when t_type_id => color_id := t_color_id;
            when z_type_id => color_id := z_color_id;
        end case;

        return color_id;
    end function get_color_id_by_type_id;

    function get_color_by_type_id(
            type_id : piece_type_id)
        return rgb_color is
    variable color_id : piece_color_id;
    variable color : rgb_color;
    begin
        color_id := get_color_id_by_type_id(type_id);
        color := get_color_by_id(color_id);
        return color;
    end function get_color_by_type_id;

    function get_rotation_table_by_type_id(
            type_id : piece_type_id;
            rotation_id : piece_rotation_id)
        return piece_table_data is
    variable table : piece_table_data;
    variable piece : tetris_piece;
    begin
        piece := get_piece_by_type_id(type_id);

        case rotation_id is
            when normal_rotation_id => table := piece.table_0;
            when first_rotation_id => table := piece.table_90;
            when second_rotation_id => table := piece.table_180;
            when third_rotation_id => table := piece.table_270;
        end case;

        return table;
    end function get_rotation_table_by_type_id;
end package body tetris_pieces;
