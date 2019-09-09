library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library generic_types;
use generic_types.generic_types.all;

entity view_controller is
generic(
    view0_position : point_2d;
    view0_size : size_2d
);
port(
    clock : in STD_LOGIC;
    global_view_point : in point_2d;
    global_view_color : out rgb_color;
    view0_point : out point_2d;
    view0_color : in rgb_color
);
end view_controller;

architecture main of view_controller is
signal view0_point_local : point_2d;
begin
    view0_point_local <=
            (global_view_point.x - view0_position.x, global_view_point.y - view0_position.y);

    view0_point <=
            view0_point_local when
                view0_point_local.x >= 0 and view0_point_local.x < view0_size.w and
                view0_point_local.y >= 0 and view0_point_local.y < view0_size.h else
            (-1, -1);

    global_view_color <=
            view0_color when
                view0_point_local.x >= 0 and view0_point_local.x < view0_size.w and
                view0_point_local.y >= 0 and view0_point_local.y < view0_size.h else
            black_color;
end main;
