library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package vga_types is
    subtype vga_integer is natural range 0 to 2047;

    type vga_config is record
        hfp_length : vga_integer;
        hsync_length : vga_integer;
        hbp_length : vga_integer;
        hview_length : vga_integer;

        vfp_length : vga_integer;
        vsync_length : vga_integer;
        vbp_length : vga_integer;
        vview_length : vga_integer;
    end record vga_config;

    constant vga_config_1280_1024_60 : vga_config := (
        hfp_length => 48,
        hsync_length => 112,
        hbp_length => 248,
        hview_length => 1280,
        vfp_length => 1,
        vsync_length => 3,
        vbp_length => 38,
        vview_length => 1024
    );

    constant vga_config_1280_720_60 : vga_config := (
        hfp_length => 110,
        hsync_length => 40,
        hbp_length => 220,
        hview_length => 1280,
        vfp_length => 5,
        vsync_length => 5,
        vbp_length => 30,
        vview_length => 720
    );
end package vga_types;
