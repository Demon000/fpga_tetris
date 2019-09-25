library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package generic_types is
    subtype point_int is integer range -2048 to 2047;
    constant point_int_invalid : point_int := 2047;
    type point_2d is record
        x : point_int;
        y : point_int;
    end record point_2d;
    constant point_2d_invalid : point_2d := (point_int_invalid, point_int_invalid);

    subtype point_small_int is integer range -128 to 127;
    type point_small_2d is record
        x : point_small_int;
        y : point_small_int;
    end record point_small_2d;

    subtype size_nat is natural range 0 to 2047;
    type size_2d is record
        w : size_nat;
        h : size_nat;
    end record size_2d;

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
