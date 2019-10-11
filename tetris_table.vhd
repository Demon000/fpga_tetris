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
    right_button_press : in STD_LOGIC;
    down_button_press : in STD_LOGIC;
    rotate_button_press : in STD_LOGIC
);
end tetris_table;

architecture main of tetris_table is

component point_partition is
generic(
    space_size : in size_small_2d;
    partition_size : in size_small_2d
);
port(
    clock: in STD_LOGIC;
    paused : in STD_LOGIC;
    partition : out point_small_2d;
    relative_point : out point_small_2d
);
end component;

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

component lfsr_3 is
port(
    clock : in STD_LOGIC; 
    output : out STD_LOGIC_VECTOR(2 downto 0)
);
end component;

function is_table_colliding(
        piece_position : point_small_2d;
        piece_table : tetris_piece_table_data;
        tetris_table : tetris_table_data)
    return boolean is
begin
    for i in 0 to tetris_piece_table_size.h - 1 loop
        for j in 0 to tetris_piece_table_size.w - 1 loop
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

                if piece_position.y + i >= 0 and
                        tetris_table(piece_position.y + i)(piece_position.x + j) /= tetris_empty_id then
                    return true;
                end if;
            end if;
        end loop;
    end loop;
    return false;
end function is_table_colliding;

procedure write_piece_to_table(
        piece_position : in point_small_2d;
        piece_table : in tetris_piece_table_data;
        piece_id : in tetris_piece_id;
        signal tetris_table : out tetris_table_data) is
begin
    for i in 0 to tetris_piece_table_size.h - 1 loop
        for j in 0 to tetris_piece_table_size.w - 1 loop
            if piece_table(i, j) = '1' then
                tetris_table(piece_position.y + i)(piece_position.x + j) <= piece_id;
            end if;
        end loop;
    end loop;
end procedure write_piece_to_table;

signal table : tetris_table_data := tetris_table_init;
signal level : tetris_level := tetris_first_level;

signal is_not_drawing : STD_LOGIC;
signal drawing_block_position : point_small_2d;
signal drawing_block_relative_point : point_small_2d;
signal block_pixel_color : rgb_color;

signal falling_piece_id : tetris_piece_id;
signal falling_piece_position : point_small_2d;
signal falling_piece_rotation_id : tetris_piece_rotation_id;
signal falling_piece_table : tetris_piece_table_data;

signal falling_piece_position_down_collides : boolean;
signal falling_piece_position_down : point_small_2d;
signal falling_piece_fall_down_triggered : STD_LOGIC;
signal falling_piece_fall_down_ticks : natural;
signal falling_piece_move_down_triggered : STD_LOGIC;

signal falling_piece_position_left_collides : boolean;
signal falling_piece_position_left : point_small_2d;
signal falling_piece_move_left_triggered : STD_LOGIC;

signal falling_piece_position_right_collides : boolean;
signal falling_piece_position_right : point_small_2d;
signal falling_piece_move_right_triggered : STD_LOGIC;

signal falling_piece_rotation_right_collides : boolean;
signal falling_piece_rotate_right_triggered : STD_LOGIC;
signal falling_piece_rotation_right_id : tetris_piece_rotation_id;
signal falling_piece_rotation_right_table : tetris_piece_table_data;

constant max_remove_full_lines_iterations : size_small_nat := 4;
signal remove_full_lines_iterations : size_small_nat := 0;

signal new_falling_piece_id_vec : STD_LOGIC_VECTOR(2 downto 0);

-- State machine states
signal current_state : tetris_state := tetris_init_state;

begin
    is_not_drawing <=
            '0' when point /= point_2d_invalid else
            '1';
    block_point_partition : point_partition
    generic map(
        space_size => tetris_table_size,
        partition_size => config.block_size
    )
    port map(
        clock => clock,
        paused => is_not_drawing,
        partition => drawing_block_position,
        relative_point => drawing_block_relative_point
    );

    falling_block_clock_timer : clock_timer
    generic map(
        trigger_on_start => true
    )
    port map(
        clock => clock,
        trigger_ticks => falling_piece_fall_down_ticks,
        pulse => falling_piece_fall_down_triggered
    );

    next_falling_piece_id_lfsr : lfsr_3
    port map(
        clock => clock,
        output => new_falling_piece_id_vec
    );

    process(clock)
    begin
        if rising_edge(clock) then
            if current_state = tetris_generate_new_piece_state then
                case new_falling_piece_id_vec is
                    when "000" => falling_piece_id <= tetris_z_id;
                    when "001" => falling_piece_id <= tetris_i_id;
                    when "010" => falling_piece_id <= tetris_j_id;
                    when "011" => falling_piece_id <= tetris_l_id;
                    when "100" => falling_piece_id <= tetris_o_id;
                    when "101" => falling_piece_id <= tetris_s_id;
                    when "110" => falling_piece_id <= tetris_t_id;
                    when "111" => falling_piece_id <= tetris_z_id;
                end case;
                falling_piece_position <= tetris_default_falling_piece_position;
                falling_piece_rotation_id <= tetris_normal_rotation_id;
            elsif current_state = tetris_do_move_piece_down_state then
                falling_piece_position <= (falling_piece_position.x, falling_piece_position.y + 1);
            elsif current_state = tetris_do_rotate_piece_right_state then
                falling_piece_rotation_id <= get_next_rotation_id(falling_piece_rotation_id);
            elsif current_state = tetris_do_move_piece_left_state then
                falling_piece_position <= (falling_piece_position.x - 1, falling_piece_position.y);
            elsif current_state = tetris_do_move_piece_right_state then
                falling_piece_position <= (falling_piece_position.x + 1, falling_piece_position.y);
            end if;
        end if;
    end process;

    process(clock)
    variable formed_line : boolean;
    begin
        if rising_edge(clock) then
            if current_state = tetris_do_place_piece_state then
                write_piece_to_table(falling_piece_position, falling_piece_table, falling_piece_id, table);
            elsif current_state = tetris_do_remove_full_lines_state then
                formed_line := false;
                for i in tetris_table_size.h - 1 downto 0 loop
                    if not formed_line then
                        formed_line := true;
                        for j in 0 to tetris_table_size.w - 1 loop
                            if table(i)(j) = tetris_empty_id then
                                formed_line := false;
                            end if;
                        end loop;

                    end if;

                    if formed_line then
                        for j in 0 to tetris_table_size.w - 1 loop
                            if i = 0 then
                                table(i) <= tetris_table_row_empty;
                            else
                                table(i) <= table(i - 1);
                            end if;
                        end loop;
                    end if;
                end loop;
            end if;
        end if;
    end process;

    process(clock)
    variable next_state : tetris_state;
    begin
        if rising_edge(clock) then
            case current_state is
                when tetris_init_state =>
                    next_state := tetris_generate_new_piece_state;
                when tetris_generate_new_piece_state =>
                    next_state := tetris_wait_action_piece_state;
                when tetris_wait_action_piece_state =>
                    next_state := tetris_wait_action_piece_state;
                    if falling_piece_move_down_triggered = '1'
                            or falling_piece_fall_down_triggered = '1' then
                        if falling_piece_position_down_collides then
                            next_state := tetris_do_place_piece_state;
                        else
                            next_state := tetris_do_move_piece_down_state;
                        end if;
                    elsif falling_piece_move_left_triggered = '1' then
                        if not falling_piece_position_left_collides then
                            next_state := tetris_do_move_piece_left_state;
                        end if;
                    elsif falling_piece_move_right_triggered = '1' then
                        if not falling_piece_position_right_collides then
                            next_state := tetris_do_move_piece_right_state;
                        end if;
                    elsif falling_piece_rotate_right_triggered = '1' then
                        if not falling_piece_rotation_right_collides then
                            next_state := tetris_do_rotate_piece_right_state;
                        end if;
                    end if;
                when tetris_do_move_piece_left_state =>
                    next_state := tetris_wait_action_piece_state;
                when tetris_do_move_piece_right_state =>
                    next_state := tetris_wait_action_piece_state;
                when tetris_do_move_piece_down_state =>
                    next_state := tetris_wait_action_piece_state;
                when tetris_do_rotate_piece_right_state =>
                    next_state := tetris_wait_action_piece_state;
                when tetris_do_place_piece_state =>
                    next_state := tetris_do_remove_full_lines_state;
                when tetris_do_remove_full_lines_state =>
                    if remove_full_lines_iterations /= max_remove_full_lines_iterations then
                        remove_full_lines_iterations <= remove_full_lines_iterations + 1;
                        next_state := tetris_do_remove_full_lines_state;
                    else
                        remove_full_lines_iterations <= 0;
                        next_state := tetris_generate_new_piece_state;
                    end if;
            end case;

            current_state <= next_state;
        end if;
    end process;

    process(clock)
    variable relative_block_position : point_small_2d;
    variable block_pallete : tetris_block_color_pallete;
    variable block_pixel_color_id : tetris_block_pixel_color_id;
    variable drawing_block_piece_id : tetris_piece_id;
    begin
        if rising_edge(clock) then
            falling_piece_table <= get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);

            falling_piece_fall_down_ticks <= config.piece_falling_ticks(level);
            falling_piece_move_down_triggered <= down_button_press;
            falling_piece_position_down <= (falling_piece_position.x, falling_piece_position.y + 1);
            falling_piece_position_down_collides <= is_table_colliding(falling_piece_position_down, falling_piece_table, table);

            falling_piece_move_left_triggered <= left_button_press;
            falling_piece_position_left <= (falling_piece_position.x - 1, falling_piece_position.y);
            falling_piece_position_left_collides <= is_table_colliding(falling_piece_position_left, falling_piece_table, table);

            falling_piece_move_right_triggered <= right_button_press;
            falling_piece_position_right <= (falling_piece_position.x + 1, falling_piece_position.y);
            falling_piece_position_right_collides <= is_table_colliding(falling_piece_position_right, falling_piece_table, table);

            falling_piece_rotate_right_triggered <= rotate_button_press;
            falling_piece_rotation_right_id <= get_next_rotation_id(falling_piece_rotation_id);
            falling_piece_rotation_right_table <= get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_right_id);
            falling_piece_rotation_right_collides <= is_table_colliding(falling_piece_position, falling_piece_rotation_right_table, table);

            relative_block_position := (drawing_block_position.x - falling_piece_position.x, drawing_block_position.y - falling_piece_position.y);

            if relative_block_position.x >= 0 and
                    relative_block_position.y >= 0 and
                    relative_block_position.x <= tetris_piece_table_size.w - 1 and
                    relative_block_position.y <= tetris_piece_table_size.h - 1 and
                    falling_piece_table(relative_block_position.y, relative_block_position.x) = '1' then
                drawing_block_piece_id := falling_piece_id;
            else
                drawing_block_piece_id := table(drawing_block_position.y)(drawing_block_position.x);
            end if;

            block_pallete := get_block_color_pallete_by_id(drawing_block_piece_id);
            block_pixel_color_id := tetris_block_texture_table(drawing_block_relative_point.y, drawing_block_relative_point.x);
            block_pixel_color <= block_pallete(block_pixel_color_id);
        end if;
    end process;

    color <= block_pixel_color;
end main;
