library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.graphics.all;

package table is
    type tetris_table is array(0 to 21, 0 to 9) of integer;
    type piece_table is array(0 to 3, 0 to 3) of bit;
    subtype piece_class is integer range 0 to 5;

    type piece is record
        class : piece_class;
        color : rgb_color;
        table_0 : piece_table;
        table_90 : piece_table;
        table_180 : piece_table;
        table_270 : piece_table;
    end record piece;

    -- I piece
    constant i_piece : piece := (
        class => 0,
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

    -- O piece
    constant o_piece_table : piece_table := (
        "0110",
        "0110",
        "0000"
    );
    constant o_piece : piece := (
        class => 1,
        color => yellow_color,
        table_0 => o_piece_table,
        table_90 => o_piece_table,
        table_180 => o_piece_table,
        table_270 => o_piece_table
    );

    -- J piece
    constant j_piece : piece := (
        class => 2,
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
    constant l_piece : piece := (
        class => 3,
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

    -- S piece
    constant s_piece : piece := (
        class => 4,
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
    constant t_piece : piece := (
        class => 5,
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
    constant z_piece : piece := (
        class => 6,
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
