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
        r : STD_LOGIC_VECTOR(3 downto 0);
        g : STD_LOGIC_VECTOR(3 downto 0);
        b : STD_LOGIC_VECTOR(3 downto 0);
    end record rgb_color;

    constant black_color : rgb_color := (
        r => "0000",
        g => "0000",
        b => "0000"
    );
end graphics;
