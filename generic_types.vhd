library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package generic_types is
    subtype point_int is integer range -2048 to 2047;
    type point_2d is record
        x : point_int;
        y : point_int;
    end record point_2d;

    subtype size_nat is natural range 0 to 2047;
    type size_2d is record
        w : size_nat;
        h : size_nat;
    end record size_2d;

    constant point_2d_init : point_2d := (
        x => 0,
        y => 0
    );

    constant size_2d_init : size_2d := (
        w => 0,
        h => 0
    );

    subtype single_color is STD_LOGIC_VECTOR(3 downto 0);
    type rgb_color is record
        r : single_color;
        g : single_color;
        b : single_color;
    end record rgb_color;

    function is_point_in_rectangle(
                point : in point_2d;
                top_left_point : in point_2d;
                rectangle_size : in size_2d)
            return boolean;

    -- 000000
    constant black_color : rgb_color := ("0000", "0000", "0000");

    -- 00f0f0
    constant cyan_color : rgb_color := ("0000", "1111", "1111");

    -- 0000f0
    constant blue_color : rgb_color := ("0000", "0000", "1111");

    -- f0a000
    constant orange_color : rgb_color := ("1111", "1010", "0000");

    -- f0f000
    constant yellow_color : rgb_color := ("1111", "1111", "0000");

    -- 00f000
    constant green_color : rgb_color := ("0000", "1111", "0000");

    -- a000f0
    constant magenta_color : rgb_color := ("1010", "0000", "1111");

    -- f00000
    constant red_color : rgb_color := ("1111", "0000", "0000");

    -- f0f0f0
    constant grey_color : rgb_color := ("1000", "1000", "1000");

end package generic_types;
package body generic_types is
    function is_point_in_rectangle(
            point : in point_2d;
            top_left_point : in point_2d;
            rectangle_size : in size_2d)
        return boolean is
    begin
        if point.x > top_left_point.x and
                point.x < top_left_point.x + rectangle_size.w and
                point.y > top_left_point.y and
                point.y < top_left_point.y + rectangle_size.h then
            return true;
        else
            return false;
        end if;
    end function is_point_in_rectangle;
end package body generic_types;
