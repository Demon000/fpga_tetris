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
end vga_config;
