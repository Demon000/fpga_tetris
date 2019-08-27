library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package graphics is
    type vector_2d is record
        x : integer;
        y : integer;
    end record vector_2d;
    subtype point_2d is vector_2d;

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

    function is_point_in_rectangle(
                point : in point_2d;
                top_left_point : in point_2d;
                rectangle_length : in vector_2d)
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

end package graphics;
package body graphics is
    function is_point_in_rectangle(
            point : in point_2d;
            top_left_point : in point_2d;
            rectangle_length : in vector_2d)
        return boolean is
    begin
        if point.x > top_left_point.x and
                point.x < top_left_point.x + rectangle_length.x and
                point.y > top_left_point.y and
                point.y < top_left_point.y + rectangle_length.y then
            return true;
        else
            return false;
        end if;
    end function is_point_in_rectangle;
end package body graphics;
