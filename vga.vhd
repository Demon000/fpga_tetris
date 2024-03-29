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
    sysclk : in STD_LOGIC;
    left_button : in STD_LOGIC;
    right_button : in STD_LOGIC;
    rotate_button : in STD_LOGIC;
    down_button : in STD_LOGIC;
    red : out single_color;
    green : out single_color;
    blue : out single_color;
    vsync : out STD_LOGIC;
    hsync : out STD_LOGIC
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

-- Button Debouncer component
component button_debouncer is
port(
    clock: in STD_LOGIC;
    button : in STD_LOGIC := '0';
    button_state : out STD_LOGIC := '0';
    min_button_ticks : natural := 10000000
);
end component;

-- Clock Timer component
component clock_timer is
generic(
    trigger_on_start : boolean := false
);
port(
    clock : in STD_LOGIC;
    trigger_ticks : in natural;
    stopped : in STD_LOGIC := '0';
    pulse : out STD_LOGIC
);
end component;

-- Tetris table component
component tetris_table is
generic(
    config : tetris_config
);
port(
    clock : in STD_LOGIC;
    point : in point_2d;
    color : out rgb_color;
    left_button_press : in STD_LOGIC;
    right_button_press : in STD_LOGIC;
    down_button_press : in STD_LOGIC;
    rotate_button_press : in STD_LOGIC
);
end component;

-- Clock that drives the VGA Controller
signal pixel_clock : STD_LOGIC;

-- Position and color of the drawing beam
signal global_view_point : point_2d;
signal global_view_color : rgb_color;

-- Position and color of the tetris table view drawing beam
signal tetris_table_view_point : point_2d;
signal tetris_table_view_color : rgb_color;

constant used_vga_config : vga_config := vga_config_1280_720_60;
constant used_tetris_config : tetris_config := tetris_config_1280_720_60;

-- Buttons
constant min_button_press_ticks : natural := 324324;
constant move_button_repress_ticks : natural := 27027027;
constant rotate_button_repress_ticks : natural := 54054054;

signal left_button_state : STD_LOGIC;
signal left_button_state_inverted : STD_LOGIC;
signal left_button_onepress : STD_LOGIC;
signal left_button_repress : STD_LOGIC;
signal left_button_press : STD_LOGIC;

signal right_button_state : STD_LOGIC;
signal right_button_state_inverted : STD_LOGIC;
signal right_button_press : STD_LOGIC;

signal down_button_state : STD_LOGIC;
signal down_button_state_inverted : STD_LOGIC;
signal down_button_press : STD_LOGIC;

signal rotate_button_state : STD_LOGIC;
signal rotate_button_state_inverted : STD_LOGIC;
signal rotate_button_press : STD_LOGIC;

begin
    clk_div_inst : clk_wiz_0
    port map(
        CLK_IN1 => sysclk,
        CLK_OUT1 => pixel_clock
    );

    vga_controller_inst : vga_controller
    generic map(used_vga_config)
    port map(
        clock => pixel_clock,
        hsync => hsync,
        vsync => vsync,
        point => global_view_point
    );

    left_button_debouncer : button_debouncer
    port map(
        clock => pixel_clock,
        button => left_button,
        button_state => left_button_state,
        min_button_ticks => min_button_press_ticks
    );

    left_button_state_inverted <= not left_button_state;
    left_button_repress_clock_timer : clock_timer
    generic map(
        trigger_on_start => true
    )
    port map(
        clock => pixel_clock,
        trigger_ticks => move_button_repress_ticks,
        stopped => left_button_state_inverted,
        pulse => left_button_press
    );

    right_button_debouncer : button_debouncer
    port map(
        clock => pixel_clock,
        button => right_button,
        button_state => right_button_state,
        min_button_ticks => min_button_press_ticks
    );

    right_button_state_inverted <= not right_button_state;
    right_button_repress_clock_timer : clock_timer
    generic map(
        trigger_on_start => true
    )
    port map(
        clock => pixel_clock,
        trigger_ticks => move_button_repress_ticks,
        stopped => right_button_state_inverted,
        pulse => right_button_press
    );

    down_button_debouncer : button_debouncer
    port map(
        clock => pixel_clock,
        button => down_button,
        button_state => down_button_state,
        min_button_ticks => min_button_press_ticks
    );

    down_button_state_inverted <= not down_button_state;
    down_button_repress_clock_timer : clock_timer
    generic map(
        trigger_on_start => true
    )
    port map(
        clock => pixel_clock,
        trigger_ticks => move_button_repress_ticks,
        stopped => down_button_state_inverted,
        pulse => down_button_press
    );

    rotate_button_debouncer : button_debouncer
    port map(
        clock => pixel_clock,
        button => rotate_button,
        button_state => rotate_button_state,
        min_button_ticks => min_button_press_ticks
    );

    rotate_button_state_inverted <= not rotate_button_state;
    rotate_button_repress_clock_timer : clock_timer
    generic map(
        trigger_on_start => true
    )
    port map(
        clock => pixel_clock,
        trigger_ticks => rotate_button_repress_ticks,
        stopped => rotate_button_state_inverted,
        pulse => rotate_button_press
    );

    tetris_table_0 : tetris_table
    generic map(
        config => used_tetris_config
    )
    port map(
        clock => pixel_clock,
        point => tetris_table_view_point,
        color => tetris_table_view_color,
        left_button_press => left_button_press,
        right_button_press => right_button_press,
        down_button_press => down_button_press,
        rotate_button_press => rotate_button_press
    );

    view_controller_inst : view_controller
    generic map(
        view0_position => used_tetris_config.table_position,
        view0_size => used_tetris_config.table_size
    )
    port map(
        clock => pixel_clock,
        global_view_point => global_view_point,
        global_view_color => global_view_color,
        view0_point => tetris_table_view_point,
        view0_color => tetris_table_view_color
    );

    red <= global_view_color.r;
    green <= global_view_color.g;
    blue <= global_view_color.b;
end main;
