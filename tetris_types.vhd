library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.graphics.all;

package table is
    type tetris_table_data is array(0 to 21, 0 to 9) of integer;
    type piece_table_data is array(0 to 3, 0 to 3) of bit;
    subtype piece_class is integer range 0 to 5;
    subtype piece_rotation is integer;

    type tetris_piece is record
        color : rgb_color;
        table_0 : piece_table_data;
        table_90 : piece_table_data;
        table_180 : piece_table_data;
        table_270 : piece_table_data;
    end record tetris_piece;

    function get_next_rotation(
            rotation : in piece_rotation)
        return piece_rotation;

    function get_prev_rotation(
            rotation : in piece_rotation)
        return piece_rotation;

    function get_piece(
            class : piece_class)
        return tetris_piece;

    function get_rotation_table(
            class : piece_class;
            rotation : piece_rotation)
        return piece_table_data;

    -- I piece
    constant i_piece : tetris_piece := (
        color => cyan_color,
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
        color => blue_color,
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
        color => orange_color,
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
        "0000"
    );
    constant o_piece : tetris_piece := (
        color => yellow_color,
        table_0 => o_piece_table,
        table_90 => o_piece_table,
        table_180 => o_piece_table,
        table_270 => o_piece_table
    );

    -- S piece
    constant s_piece : tetris_piece := (
        color => green_color,
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
        color => magenta_color,
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
        color => red_color,
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
end package table;

package body table is
    function get_next_rotation(
            rotation : in piece_rotation)
        return piece_rotation is
    variable next_rotation : piece_rotation;
    begin
        next_rotation := rotation + 1;
        if rotation > 3 then
            next_rotation := 0;
        end if;

        return next_rotation;
    end function get_next_rotation;

    function get_prev_rotation(
            rotation : in piece_rotation)
        return piece_rotation is
    variable prev_rotation : piece_rotation;
    begin
        prev_rotation := rotation - 1;
        if rotation < 0 then
            prev_rotation := 3;
        end if;

        return prev_rotation;
    end function get_prev_rotation;

    function get_piece(
            class : piece_class)
        return tetris_piece is
    variable piece : tetris_piece;
    begin
        case class is
            when 0 => piece := i_piece;
            when 1 => piece := j_piece;
            when 2 => piece := l_piece;
            when 3 => piece := o_piece;
            when 4 => piece := s_piece;
            when 5 => piece := t_piece;
            when 6 => piece := z_piece;
        end case;

        return piece;
    end function get_piece;

    function get_rotation_table(
            class : piece_class;
            rotation : piece_rotation)
        return piece_table_data is
    variable table : piece_table_data;
    variable piece : tetris_piece;
    begin
        piece := get_piece(class);

        case rotation is
            when 0 => table := piece.table_0;
            when 1 => table := piece.table_90;
            when 2 => table := piece.table_180;
            when 3 => table := piece.table_270;
        end case;

        return table;
    end function get_rotation_table;
end package body table;
