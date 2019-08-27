library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package vga_config is
    type vga_config is record
        hfp_length : natural;
        hsync_length : natural;
        hbp_length : natural;
        hview_length : natural;

        vfp_length : natural;
        vsync_length : natural;
        vbp_length : natural;
        vview_length : natural;
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
end package vga_config;
