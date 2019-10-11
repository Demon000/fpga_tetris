library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library vga_types;
use vga_types.vga_types.all;

library generic_types;
use generic_types.generic_types.all;

entity vga_controller is
generic(
    config : in vga_config
);
port(
    clock: in STD_LOGIC;
    hsync : out STD_LOGIC;
    vsync : out STD_LOGIC;
    point : out point_2d
);
end vga_controller;

architecture main of vga_controller is
-- Pixel values for each horizontal screen area
constant hdraw_start : vga_integer := 0;

constant hfp_start : vga_integer := hdraw_start;
constant hfp_end : vga_integer := hfp_start + config.hfp_length;

constant hsync_start : vga_integer := hfp_end;
constant hsync_end : vga_integer := hsync_start + config.hsync_length;

constant hbp_start : vga_integer := hsync_end;
constant hbp_end : vga_integer := hbp_start + config.hbp_length;

constant hview_start : vga_integer := hbp_end;
constant hview_end : vga_integer := hview_start + config.hview_length;

constant hdraw_end : vga_integer := hview_end;

-- Pixel values for each vertical screen area
constant vdraw_start : vga_integer := 0;

constant vfp_start : vga_integer := vdraw_start;
constant vfp_end : vga_integer := vfp_start + config.vfp_length;

constant vsync_start : vga_integer := vfp_end;
constant vsync_end : vga_integer := vsync_start + config.vsync_length;

constant vbp_start : vga_integer := vsync_end;
constant vbp_end : vga_integer := vbp_start + config.vbp_length;

constant vview_start : vga_integer := vbp_end;
constant vview_end : vga_integer := vview_start + config.vview_length;

constant vdraw_end : vga_integer := vview_end;

-- Position of the stream
signal stream : point_2d := (hdraw_end - 1, vdraw_end - 1);

begin
    process(clock)
    begin
        if rising_edge(clock) then
            if stream.x < hdraw_end - 1 then
                stream.x <= stream.x + 1;
            else
                stream.x <= hdraw_start;

                if stream.y < vdraw_end - 1 then
                    stream.y <= stream.y + 1;
                else 
                    stream.y <= vdraw_start;
                end if;
            end if;
        end if;
    end process;

    hsync <=
            '1' when
                stream.x >= hsync_start and stream.x < hsync_end else
            '0';
                
    vsync <=
            '1' when
                stream.y >= vsync_start and stream.y < vsync_end else
            '0';

    point <=
            (stream.x - hview_start, stream.y - vview_start) when
                stream.x >= hview_start and stream.x < hview_end and
                stream.y >= vview_start and stream.y < vview_end else
            point_2d_invalid;
end main;
