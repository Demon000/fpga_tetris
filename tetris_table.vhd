library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library generic_types;
use generic_types.generic_types.all;

library tetris_types;
use tetris_types.tetris_types.all;

library tetris_time;
use tetris_time.tetris_time.all;

library tetris_pieces;
use tetris_pieces.tetris_pieces.all;

entity tetris_table is
generic(
    size : size_2d;
    tps : natural
);
port(
    clock : in STD_LOGIC;
    point : in point_2d;
    color : out rgb_color
);
end tetris_table;

architecture main of tetris_table is

component clock_timer is
generic(
    restart_on_end : boolean := false
);
port(
    clock : in STD_LOGIC;
    trigger_ticks : in natural;
    paused : in boolean;
    restart : in boolean;
    pulse : out STD_LOGIC
);
end component;

signal table : tetris_table_data := tetris_table_data_init;
constant first_level : tetris_level := 1;
signal level : tetris_level := first_level;
signal falling_trigger_ticks : natural;
signal falling_triggered : STD_LOGIC;

-- Position and size of the block being drawn
signal block_position : tetris_point;
signal piece_relative_block_position : tetris_point;
signal block_size : size_2d := (size.w / tetris_table_size.w, size.h / tetris_table_size.h);

--constant default_falling_piece_position : point_2d := (3, -2);
constant default_falling_piece_position : tetris_point := (3, -2);
signal falling_piece_position : tetris_point := default_falling_piece_position;
signal falling_piece_type_id : piece_type_id := s_type_id;
signal falling_piece_rotation_id : piece_rotation_id := normal_rotation_id;
begin
    block_position <= (point.x / block_size.w, point.y / block_size.h);
    piece_relative_block_position <= (block_position.x - falling_piece_position.x, block_position.y - falling_piece_position.y);
    falling_trigger_ticks <= get_ticks_for_level(tps, level);

    falling_block_clock_timer : clock_timer
    generic map(
        restart_on_end => true
    )
    port map(
        clock => clock,
        trigger_ticks => falling_trigger_ticks,
        paused => false,
        restart => false,
        pulse => falling_triggered
    );

    process(clock)
    begin
        if rising_edge(clock) then
            if falling_triggered = '1' then
                falling_piece_position.y <= falling_piece_position.y + 1;
            end if;
        end if;
    end process;

    process(clock)
    variable falling_piece_color : rgb_color;
    variable falling_piece_table : piece_table_data;
    variable block_color_id : piece_color_id;
    variable block_color : rgb_color;
    begin
        if rising_edge(clock) then
            falling_piece_color := get_color_by_type_id(falling_piece_type_id);
            falling_piece_table := get_rotation_table_by_type_id(falling_piece_type_id, falling_piece_rotation_id);
            block_color_id := table(block_position.y, block_position.x);
            block_color := get_color_by_id(block_color_id);

            if piece_relative_block_position.x >= 0 and
                    piece_relative_block_position.y >= 0 and
                    piece_relative_block_position.x < piece_table_size.w and
                    piece_relative_block_position.y < piece_table_size.h then
                if falling_piece_table(
                            piece_relative_block_position.y,
                            piece_relative_block_position.x
                        ) = '1' then
                    color <= falling_piece_color;
                else
                    color <= block_color;
                end if;
            else
                color <= block_color;
            end if;
        end if;
    end process;
end main;
