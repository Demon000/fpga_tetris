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
    paused : in boolean;
    restart : in boolean;
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
signal falling_trigger_ticks : natural;
signal falling_triggered : STD_LOGIC;

-- Position and size of the block being drawn
signal block_position : tetris_point;
signal piece_relative_block_position : tetris_point;

signal falling_piece_position : tetris_point := default_falling_piece_position;
signal falling_piece_type_id : piece_type_id := s_type_id;
signal falling_piece_rotation_id : piece_rotation_id := normal_rotation_id;
signal falling_piece_color : rgb_color := green_color;
signal falling_piece_color_id : piece_color_id := s_color_id;
signal falling_piece_table : piece_table_data;
signal block_in_piece : STD_LOGIC := '0';
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

    process(clock)
    variable next_position : tetris_point;
    begin
        if rising_edge(clock) then
            if falling_triggered = '1' then
                next_position := (falling_piece_position.x, falling_piece_position.y + 1);
                if is_table_colliding(next_position, falling_piece_table, table) then
                    write_piece_to_table(falling_piece_position, falling_piece_table, falling_piece_color_id, table);
                    falling_piece_position <= default_falling_piece_position;
                else
                    falling_piece_position <= next_position;
                end if;
            end if;
        end if;
    end process;

    process(clock)
    variable next_position : tetris_point;
    begin
        if rising_edge(clock) then
            if left_button_press = '1' then
                next_position := (falling_piece_position.x - 1, falling_piece_position.y);
                if not is_table_colliding(next_position, falling_piece_table, table) then
                    falling_piece_position <= next_position;
                end if;
            end if;
        end if;
    end process;

    process(clock)
    variable next_position : tetris_point;
    begin
        if rising_edge(clock) then
            if right_button_press = '1' then
                next_position := (falling_piece_position.x + 1, falling_piece_position.y);
                if not is_table_colliding(next_position, falling_piece_table, table) then
                    falling_piece_position <= next_position;
                end if;
            end if;
        end if;
    end process;

    block_position <= (point.x / config.block_size.w, point.y / config.block_size.h);
    piece_relative_block_position <= (block_position.x - falling_piece_position.x, block_position.y - falling_piece_position.y);
    falling_piece_table <= get_rotation_table_by_type_id(falling_piece_type_id, falling_piece_rotation_id);
    process(clock)
    begin
        if rising_edge(clock) then
            if piece_relative_block_position.x >= 0 and
                    piece_relative_block_position.y >= 0 and
                    piece_relative_block_position.x < piece_table_size.w and
                    piece_relative_block_position.y < piece_table_size.h and
                    falling_piece_table(piece_relative_block_position.y, piece_relative_block_position.x) = '1' then
                block_in_piece <= '1';
            else
                block_in_piece <= '0';
            end if;
        end if;
    end process;

    process(clock)
    variable block_color_id : piece_color_id;
    variable block_color : rgb_color;
    begin
        if rising_edge(clock) then
            block_color_id := table(block_position.y, block_position.x);
            block_color := get_color_by_id(block_color_id);
            if block_in_piece = '1' then
                color <= falling_piece_color;
            else
                color <= block_color;
            end if;
        end if;
    end process;
end main;
