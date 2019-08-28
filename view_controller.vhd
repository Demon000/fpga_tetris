library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library generic_types;
use generic_types.generic_types.all;

entity view_controller is
generic(
    view0_box : view_box := view_box_init;
    view1_box : view_box := view_box_init
);
port(
    clock : in STD_LOGIC;
    
    -- The point we are drawing on the screen
    global_view_point : in point_2d;

    -- The color we draw on the screen
    global_view_color : out rgb_color;

    -- The points that the view receive
    view0_point : out point_2d;
    view1_point : out point_2d;
    
    -- The colors that we get back from the view
    view0_color : in rgb_color := black_color;
    view1_color : in rgb_color := black_color

);
end view_controller;

architecture main of view_controller is

begin
    view0_point <= (global_view_point.x - view0_box.x, global_view_point.y - view0_box.y);
    view1_point <= (global_view_point.x - view1_box.x, global_view_point.y - view1_box.y);   
 
    process(clock)
    begin
        if rising_edge(clock) then
            if global_view_point.x >= view0_box.x and
                    global_view_point.y >= view0_box.y and
                    global_view_point.x < view0_box.x + view0_box.w and
                    global_view_point.y < view0_box.y + view0_box.h then
                global_view_color <= view0_color;
            elsif global_view_point.x >= view1_box.x and
                    global_view_point.y >= view1_box.y and
                    global_view_point.x < view1_box.x + view1_box.w and
                    global_view_point.y < view1_box.y + view1_box.h then
                global_view_color <= view1_color;
            else
                global_view_color <= black_color;
            end if;
        end if;
    end process;
end main;
