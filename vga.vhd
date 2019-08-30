library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library generic_types;
use generic_types.generic_types.all;

library vga_types;
use vga_types.vga_types.all;

library tetris_types;
use tetris_types.tetris_types.all;

entity vga is
port(
    system_clock : in STD_LOGIC;
    red : out single_color;
    green : out single_color;
    blue : out single_color;
    vsync : out STD_LOGIC;
    hsync: out STD_LOGIC
);
end vga;

architecture main of vga is

-- Clock Wizard component
component clk_wiz_0
port(
  CLK_IN1 : in std_logic;
  CLK_OUT1 : out std_logic
);
end component;

-- VGA Controller component
component vga_controller is
generic(
    config : in vga_config
);
port(
    clock: in STD_LOGIC;
    hsync : out STD_LOGIC;
    vsync : out STD_LOGIC;
    point : out point_2d
);
end component;

-- View Controller component
component view_controller is
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
end component;

-- Tetris table component
component tetris_table is
generic(
    size : size_2d;
    tps : natural
);
port(
    clock : in STD_LOGIC;
    point : in point_2d;
    color : out rgb_color
);
end component;

-- Clock that drives the VGA Controller
constant pixel_clock_tps : natural := 108108108;
signal pixel_clock : STD_LOGIC;

-- Position and color of the drawing beam
signal global_view_point : point_2d;
signal global_view_color : rgb_color;

-- Position and size of the tetris table view
constant tetris_table_position : point_2d := (200, 200);
constant tetris_table_size : size_2d := (400, 800);

-- Position and color of the tetris table view drawing beam
signal tetris_table_view_point : point_2d;
signal tetris_table_view_color : rgb_color;

begin
    clk_div_inst : clk_wiz_0
    port map(
        CLK_IN1 => system_clock,
        CLK_OUT1 => pixel_clock
    );

    vga_controller_inst : vga_controller
    generic map(vga_config_1280_1024_60)
    port map(
        clock => pixel_clock,
        hsync => hsync,
        vsync => vsync,
        point => global_view_point
    );

    view_controller_inst : view_controller
    generic map(
        view0_position => tetris_table_position,
        view0_size => tetris_table_size
    )
    port map(
        clock => pixel_clock,
        global_view_point => global_view_point,
        global_view_color => global_view_color,
        view0_point => tetris_table_view_point,
        view0_color => tetris_table_view_color
    );

    tetris_table_0 : tetris_table
    generic map(
        size => tetris_table_size,
        tps => pixel_clock_tps
    )
    port map(
        clock => pixel_clock,
        point => tetris_table_view_point,
        color => tetris_table_view_color
    );

    red <= global_view_color.r;
    green <= global_view_color.g;
    blue <= global_view_color.b;
end main;
