library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library vga_types;
use vga_types.vga_config.all;

library generic_types;
use generic_types.graphics.all;

entity vga is
port(
    system_clock : in STD_LOGIC;
    red : out single_color;
    green : out single_color;
    blue : out single_color;
    vsync : out STD_LOGIC;
    hsync: out STD_LOGIC;
    count_button : in STD_LOGIC;
    reset_button : in STD_LOGIC;
    display_leds : out STD_LOGIC_VECTOR(3 downto 0)
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
    draw_point : out point_2d
);
end component;

-- Button Debouncer component
component button_debouncer is
generic(
    max_button_count : natural := 10000000
);
port(
    clock: in STD_LOGIC;
    button : in STD_LOGIC;
    button_state : out STD_LOGIC
);
end component;

-- Button Pulser component
component button_pulser is
port(
    clock: in STD_LOGIC;
    button_state : in STD_LOGIC := '0';
    button_press : out STD_LOGIC := '0'
);
end component;

-- Clock that drives the VGA Controller
signal pixel_clock : STD_LOGIC;

-- Position of the drawing beam
signal draw_point : point_2d := point_2d_init;
signal draw_point_color : rgb_color := black_color;

signal count_button_state : STD_LOGIC;
signal count_button_press : STD_LOGIC;

signal reset_button_state : STD_LOGIC;
signal reset_button_press : STD_LOGIC;
signal count_value : STD_LOGIC_VECTOR(3 downto 0) := "0000";

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
        draw_point => draw_point
    );

    count_button_debouncer : button_debouncer
    port map(
        clock => system_clock,
        button => count_button,
        button_state => count_button_state
    );

    count_button_pulser : button_pulser
    port map(
        clock => system_clock,
        button_state => count_button_state,
        button_press => count_button_press
    );

    reset_button_debouncer : button_debouncer
    port map(
        clock => system_clock,
        button => reset_button,
        button_state => reset_button_state
    );

    reset_button_pulser : button_pulser
    port map(
        clock => system_clock,
        button_state => reset_button_state,
        button_press => reset_button_press
    );

    process(pixel_clock)

    function is_point_in_rectangle(
            point : in point_2d;
            top_left_point : in point_2d;
            rectangle_length : in vector_2d)
        return boolean is
    begin
        if point.x > top_left_point.x and
                point.x < top_left_point.x + rectangle_length.x and
                point.y > top_left_point.y and
                point.y < top_left_point.y + rectangle_length.y then
            return true;
        else
            return false;
        end if;
    end function is_point_in_rectangle;

    impure function draw_rectangle(
            top_left_point : in point_2d;
            rectangle_length : in vector_2d;
            fill_color : in rgb_color)
        return boolean is
    begin
        if is_point_in_rectangle(draw_point, top_left_point, rectangle_length) then
            draw_point_color <= fill_color;
            return true;
        else
            return false;
        end if;
    end function draw_rectangle;

    variable should_blank : boolean;
    begin
        if rising_edge(pixel_clock) then
            -- Blank everything by default
            should_blank := true;

            if draw_rectangle((10, 10), (30, 30), cyan_color) then
                should_blank := false;
            end if;

            if draw_rectangle((50, 10), (30, 30), blue_color) then
                should_blank := false;
            end if;

            if draw_rectangle((90, 10), (30, 30), orange_color) then
                should_blank := false;
            end if;

            if draw_rectangle((130, 10), (30, 30), yellow_color) then
                should_blank := false;
            end if;

            if draw_rectangle((170, 10), (30, 30), green_color) then
                should_blank := false;
            end if;

            if draw_rectangle((210, 10), (30, 30), magenta_color) then
                should_blank := false;
            end if;

            if draw_rectangle((250, 10), (30, 30), red_color) then
                should_blank := false;
            end if;


            if should_blank then
                draw_point_color <= black_color;
            end if;
        end if;
    end process;

    process(system_clock)
    begin
        if rising_edge(system_clock) then
            if count_button_press = '1' then
                if count_value = "1111" then
                    count_value <= "0000";
                else
                    count_value <= count_value + '1';
                end if;
            end if;

            if reset_button_press = '1' then
                count_value <= "0000";
            end if;
        end if;
    end process;

    display_leds <= count_value;

    red <= draw_point_color.r;
    green <= draw_point_color.g;
    blue <= draw_point_color.b;
end main;
