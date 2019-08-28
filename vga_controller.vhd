library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library vga_types;
use vga_types.vga_config.all;

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
constant hdraw_start : natural := 0;

constant hfp_start : natural := hdraw_start;
constant hfp_end : natural := hfp_start + config.hfp_length;

constant hsync_start : natural := hfp_end;
constant hsync_end : natural := hsync_start + config.hsync_length;

constant hbp_start : natural := hsync_end;
constant hbp_end : natural := hbp_start + config.hbp_length;

constant hview_start : natural := hbp_end;
constant hview_end : natural := hview_start + config.hview_length;

constant hdraw_end : natural := hview_end;

-- Pixel values for each vertical screen area
constant vdraw_start : natural := 0;

constant vfp_start : natural := vdraw_start;
constant vfp_end : natural := vfp_start + config.vfp_length;

constant vsync_start : natural := vfp_end;
constant vsync_end : natural := vsync_start + config.vsync_length;

constant vbp_start : natural := vsync_end;
constant vbp_end : natural := vbp_start + config.vbp_length;

constant vview_start : natural := vbp_end;
constant vview_end : natural := vview_start + config.vview_length;

constant vdraw_end : natural := vview_end;

-- Position of the stream
signal stream : point_2d := point_2d_init;

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

    process(clock)
    begin
        if rising_edge(clock) then
            if stream.x >= hsync_start and stream.x < hsync_end then
                hsync <= '1';
            else
                hsync <= '0';
            end if;
        end if;
    end process;

    process(clock)
    begin
        if rising_edge(clock) then
            if stream.y >= vsync_start and stream.y < vsync_end then
                vsync <= '1';
            else
                vsync <= '0';
            end if;
        end if;
    end process;

    process(clock)
    begin
        if rising_edge(clock) then
            if stream.x >= hview_start and stream.x < hview_end and
                    stream.y >= vview_start and stream.y < vview_end then
                point.x <= stream.x - hview_start;
                point.y <= stream.y - vview_start;
            else
                point.x <= -1;
                point.y <= -1;
            end if;
        end if;
    end process; 
end main;
