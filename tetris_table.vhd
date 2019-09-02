library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library generic_types;
use generic_types.generic_types.all;

library tetris_types;
use tetris_types.tetris_types.all;

library tetris_pieces;
use tetris_pieces.tetris_pieces.all;

entity tetris_table is
generic(
    config : tetris_config
);
port(
    clock : in STD_LOGIC;
    point : in point_2d;
    color : out rgb_color;
    left_button_press : in STD_LOGIC;
    right_button_press : in STD_LOGIC
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
    paused : in boolean := false;
    restart : in boolean := false;
    pulse : out STD_LOGIC
);
end component;

function is_table_colliding(
        piece_position : tetris_point;
        piece_table : piece_table_data;
        tetris_table : tetris_table_data)
    return boolean is
begin
    for i in 0 to piece_table_size.h - 1 loop
        for j in 0 to piece_table_size.w - 1 loop
            if piece_table(i, j) = '1' then
                if piece_position.y + i > tetris_table_size.h - 1 then
                    return true;
                end if;

                if piece_position.x + j < 0 then
                    return true;
                end if;

                if piece_position.x + j > tetris_table_size.w - 1 then
                    return true;
                end if;

                if tetris_table(piece_position.y + i, piece_position.x + j) /= empty_color_id then
                    return true;
                end if;
            end if;
        end loop;
    end loop;
    return false;
end function is_table_colliding;

procedure write_piece_to_table(
        piece_position : in tetris_point;
        piece_table : in piece_table_data;
        piece_color_id : in piece_color_id;
        signal tetris_table : out tetris_table_data) is
begin
    for i in 0 to piece_table_size.h - 1 loop
        for j in 0 to piece_table_size.w - 1 loop
            if piece_table(i, j) = '1' then
                tetris_table(piece_position.y + i, piece_position.x + j) <= piece_color_id;
            end if;
        end loop;
    end loop;
end procedure write_piece_to_table;

signal table : tetris_table_data := tetris_table_data_init;
signal level : tetris_level := tetris_first_level;
signal need_new_falling_piece : STD_LOGIC;
signal move_falling_piece_left : STD_LOGIC;
signal move_falling_piece_right : STD_LOGIC;


signal falling_trigger_ticks : natural;
signal falling_triggered : STD_LOGIC;

-- Position and size of the block being drawn
signal block_position : tetris_point;

signal falling_piece_type_id : piece_type_id;
signal falling_piece_position : tetris_point;
signal falling_piece_rotation_id : piece_rotation_id;

signal block_drawing_color_id : piece_color_id;
begin
    falling_trigger_ticks <= config.piece_falling_ticks(level);

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

    new_falling_piece_clock_timer : clock_timer
    port map(
        clock => clock,
        trigger_ticks => 108108108,
        pulse => need_new_falling_piece
    );

    process(clock)
    begin
        if rising_edge(clock) then
            if need_new_falling_piece = '1' then
                falling_piece_type_id <= s_type_id;
                falling_piece_position <= default_falling_piece_position;
                falling_piece_rotation_id <= normal_rotation_id;
            end if;

            if move_falling_piece_left = '1' then
                falling_piece_position <= (falling_piece_position.x - 1, falling_piece_position.y);
            end if;

            if move_falling_piece_right = '1' then
                falling_piece_position <= (falling_piece_position.x + 1, falling_piece_position.y);
            end if;
        end if;
    end process;

    process(clock)
    variable next_position : tetris_point;
    variable falling_piece_color_id : piece_color_id;
    variable falling_piece_table : piece_table_data;
    begin
        if rising_edge(clock) then
            if falling_triggered = '1' then
                falling_piece_table := get_rotation_table_by_type_id(falling_piece_type_id, falling_piece_rotation_id);
                next_position := (falling_piece_position.x, falling_piece_position.y + 1);

                if is_table_colliding(next_position, falling_piece_table, table) then
                    falling_piece_color_id := get_color_id_by_type_id(falling_piece_type_id);
                    write_piece_to_table(falling_piece_position, falling_piece_table, falling_piece_color_id, table);

                    need_new_falling_piece <= '1';
                else
                    need_new_falling_piece <= '0';
                end if;
            end if;

            if left_button_press = '1' then
                next_position := (falling_piece_position.x - 1, falling_piece_position.y);
                if not is_table_colliding(next_position, falling_piece_table, table) then
                    move_falling_piece_left <= '1';
                end if;
            end if;

            if right_button_press = '1' then
                next_position := (falling_piece_position.x + 1, falling_piece_position.y);
                if not is_table_colliding(next_position, falling_piece_table, table) then
                    move_falling_piece_right <= '1';
                end if;
            end if;
        end if;
    end process;

    block_position <= (point.x / config.block_size.w, point.y / config.block_size.h);
    process(clock)
    variable relative_block_position : tetris_point;
    variable falling_piece_color_id : piece_color_id;
    variable falling_piece_table : piece_table_data;
    variable block_color_id : piece_color_id;
    begin
        if rising_edge(clock) then
            relative_block_position := (block_position.x - falling_piece_position.x, block_position.y - falling_piece_position.y);
            falling_piece_table := get_rotation_table_by_type_id(falling_piece_type_id, falling_piece_rotation_id);
            if relative_block_position.x >= 0 and
                    relative_block_position.y >= 0 and
                    relative_block_position.x <= piece_table_size.w - 1 and
                    relative_block_position.y <= piece_table_size.h - 1 and
                    falling_piece_table(relative_block_position.y, relative_block_position.x) = '1' then
                falling_piece_color_id := get_color_id_by_type_id(falling_piece_type_id);
                block_drawing_color_id <= falling_piece_color_id;
            else
                block_color_id := table(block_position.y, block_position.x);
                block_drawing_color_id <= block_color_id;
            end if;
        end if;
    end process;

    process(clock)
    variable block_color : rgb_color;
    begin
        if rising_edge(clock) then
            if block_drawing_color_id = empty_color_id then
                color <= grey_color;
            else
                block_color := get_color_by_id(block_drawing_color_id);
                color <= block_color;
            end if;
        end if;
    end process;
end main;
