library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package graphics is
    type point_2d is record
        x : integer;
        y : integer;
    end record point_2d;

    constant point_2d_init : point_2d := (
        x => -1,
        y => -1
    );

    subtype single_color is STD_LOGIC_VECTOR(3 downto 0);
    type rgb_color is record
        r : single_color;
        g : single_color;
        b : single_color;
    end record rgb_color;

    -- 000000
    constant black_color : rgb_color := (
        r => "0000",
        g => "0000",
        b => "0000"
    );

    -- 00f0f0
    constant cyan_color : rgb_color := (
        r => "0000",
        g => "1100",
        b => "1100"
    );

    -- 0000f0
    constant blue_color : rgb_color := (
        r => "0000",
        g => "0000",
        b => "1100"
    );

    -- f0a000
    constant orange_color : rgb_color := (
        r => "1100",
        g => "1010",
        b => "0000"
    );

    -- f0f000
    constant yellow_color : rgb_color := (
        r => "1100",
        g => "1100",
        b => "0000"
    );

    -- 00f000
    constant green_color : rgb_color := (
        r => "0000",
        g => "1100",
        b => "0000"
    );

    -- a000f0
    constant magenta_color : rgb_color := (
        r => "1010",
        g => "0000",
        b => "1100"
    );

    -- f00000
    constant magenta_color : rgb_color := (
        r => "1100",
        g => "0000",
        b => "0000"
    );
end graphics;
