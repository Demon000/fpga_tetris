library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.graphics.all;

package table is
    type tetris_table is array(0 to 21, 0 to 9) of integer;

    subtype rotation_type is integer;
    constant first_rotation_type : rotation_type := 1;
    constant second_rotation_type : rotation_type := 2;
    constant third_rotation_type : rotation_type := 3;
    constant forth_rotation_type : rotation_type := 4;

    subtype piece_type is integer;
    type large_piece is array(0 to 4, 0 to 4) of bit;
    type medium_piece is array(0 to 3, 0 to 4) of bit;
    type small_piece is array(0 to 3, 0 to 3) of bit;

    -- I piece
    constant i_piece_color : rgb_color := cyan_color;
    constant i_piece_type : piece_type := 1;
    constant i_piece_0 : large_piece := (
        "0000",
        "1111",
        "0000",
        "0000"
    );
    constant i_piece_90 : large_piece := (
        "0010",
        "0010",
        "0010",
        "0010"
    );
    constant i_piece_180 : large_piece := (
        "0000",
        "0000",
        "1111",
        "0000"
    );
    constant i_piece_270 : large_piece := (
        "0100",
        "0100",
        "0100",
        "0100"
    );

    -- O piece
    constant o_piece_color : rgb_color := yellow_color;
    constant o_piece_type : piece_type := 2;
    constant o_piece_0 : medium_piece := (
        "0110",
        "0110",
        "0000"
    );
    constant o_piece_90 : medium_piece := o_piece_0;
    constant o_piece_180 : medium_piece := o_piece_0;
    constant o_piece_270 : medium_piece := o_piece_0;

    -- J piece
    constant j_piece_color : rgb_color := blue_color;
    constant j_piece_type : piece_type := 3;
    constant j_piece_0 : small_piece := (
        "100",
        "111",
        "000"
    );
    constant j_piece_90 : small_piece := (
        "011",
        "010",
        "010"
    );
    constant j_piece_180 : small_piece := (
        "000",
        "111",
        "001"
    );
    constant j_piece_270 : small_piece := (
        "010",
        "010",
        "110"
    );

    -- L piece
    constant l_piece_color : rgb_color := orange_color;
    constant l_piece_type : piece_type := 4;
    constant l_piece_0 : small_piece := (
        "001",
        "111",
        "000"
    );
    constant l_piece_90 : small_piece := (
        "010",
        "010",
        "011"
    );
    constant l_piece_180 : small_piece := (
        "000",
        "111",
        "100"
    );
    constant l_piece_270 : small_piece := (
        "110",
        "010",
        "010"
    );

    -- S piece
    constant s_piece_color : rgb_color := green_color;
    constant s_piece_type : piece_type := 5;
    constant s_piece_0 : small_piece := (
        "011",
        "110",
        "000"
    );
    constant s_piece_90 : small_piece := (
        "010",
        "011",
        "001"
    );
    constant s_piece_180 : small_piece := (
        "000",
        "011",
        "110"
    );
    constant s_piece_270 : small_piece := (
        "100",
        "110",
        "010"
    );

    -- T piece
    constant t_piece_color : rgb_color := magenta_color;
    constant t_piece_type : piece_type := 5;
    constant t_piece_0 : small_piece := (
        "010",
        "111",
        "000"
    );
    constant t_piece_90 : small_piece := (
        "010",
        "011",
        "010"
    );
    constant t_piece_180 : small_piece := (
        "000",
        "111",
        "010"
    );
    constant t_piece_270 : small_piece := (
        "010",
        "110",
        "010"
    );

    -- Z piece
    constant z_piece_color : rgb_color := red_color;
    constant z_piece_type : piece_type := 5;
    constant z_piece_0 : small_piece := (
        "110",
        "011",
        "000"
    );
    constant z_piece_90 : small_piece := (
        "001",
        "011",
        "010"
    );
    constant z_piece_180 : small_piece := (
        "000",
        "110",
        "011"
    );
    constant z_piece_270 : small_piece := (
        "010",
        "110",
        "100"
    );
end package table;
