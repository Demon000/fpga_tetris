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
end graphics;
