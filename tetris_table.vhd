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
    rotate_button_press : in STD_LOGIC
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
    paused : in STD_LOGIC := '0';
    restart : in STD_LOGIC :=  '0';
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
        piece_position : tetris_point;
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
                        tetris_table(piece_position.y + i, piece_position.x + j) /= tetris_empty_id then
                    return true;
                end if;
            end if;
        end loop;
    end loop;
    return false;
end function is_table_colliding;

procedure write_piece_to_table(
        piece_position : in tetris_point;
        piece_table : in tetris_piece_table_data;
        piece_id : in tetris_piece_id;
        signal tetris_table : out tetris_table_data) is
begin
    for i in 0 to tetris_piece_table_size.h - 1 loop
        for j in 0 to tetris_piece_table_size.w - 1 loop
            if piece_table(i, j) = '1' then
                tetris_table(piece_position.y + i, piece_position.x + j) <= piece_id;
            end if;
        end loop;
    end loop;
end procedure write_piece_to_table;

signal table : tetris_table_data := tetris_table_init;
signal level : tetris_level := tetris_first_level;

signal falling_piece_id : tetris_piece_id;
signal falling_piece_position : tetris_point;
signal falling_piece_rotation_id : tetris_piece_rotation_id;

signal falling_piece_position_down_collides : boolean;
signal falling_piece_move_down_triggered : STD_LOGIC;
signal falling_piece_move_down_ticks : natural;

signal falling_piece_position_left_collides : boolean;
signal falling_piece_move_left_triggered : STD_LOGIC;

signal falling_piece_position_right_collides : boolean;
signal falling_piece_move_right_triggered : STD_LOGIC;

signal falling_piece_rotation_right_collides : boolean;
signal falling_piece_rotate_right_triggered : STD_LOGIC;

signal falling_piece_formed_line : boolean;

signal new_falling_piece_id_vec : STD_LOGIC_VECTOR(2 downto 0);

-- State machine states
signal current_state : tetris_state := tetris_init_state;
signal next_state : tetris_state;

begin
    falling_piece_move_down_ticks <= config.piece_falling_ticks(level);

    falling_piece_move_left_triggered <= left_button_press;
    falling_piece_move_right_triggered <= right_button_press;
    falling_piece_rotate_right_triggered <= rotate_button_press;

    falling_block_clock_timer : clock_timer
    generic map(
        restart_on_end => true
    )
    port map(
        clock => clock,
        trigger_ticks => falling_piece_move_down_ticks,
        pulse => falling_piece_move_down_triggered
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
            end if;

            if current_state = tetris_do_fall_piece_state then
                falling_piece_position <= (falling_piece_position.x, falling_piece_position.y + 1);
            end if;

            if current_state = tetris_do_rotate_piece_right_state then
                falling_piece_rotation_id <= get_next_rotation_id(falling_piece_rotation_id);
            end if;

            if current_state = tetris_do_move_piece_left_state then
                falling_piece_position <= (falling_piece_position.x - 1, falling_piece_position.y);
            end if;

            if current_state = tetris_do_move_piece_right_state then
                falling_piece_position <= (falling_piece_position.x + 1, falling_piece_position.y);
            end if;
        end if;
    end process;

    process(clock)
    variable falling_piece_table : tetris_piece_table_data;
    variable formed_line : boolean;
    begin
        if rising_edge(clock) then

            if current_state = tetris_do_place_piece_state then
                falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);
                write_piece_to_table(falling_piece_position, falling_piece_table, falling_piece_id, table);
            end if;

            falling_piece_formed_line <= false;
            if current_state = tetris_do_remove_full_lines_state then
                formed_line := false;
                for i in tetris_table_size.h - 1 downto 0 loop
                    if not formed_line then
                        formed_line := true;
                        for j in 0 to tetris_table_size.w - 1 loop
                            if table(i, j) = tetris_empty_id then
                                formed_line := false;
                            end if;
                        end loop;

                    end if;

                    if formed_line then
                        for j in 0 to tetris_table_size.w - 1 loop
                            if i = 0 then
                                table(i, j) <= tetris_empty_id;
                            else
                                table(i, j) <= table(i - 1, j);
                            end if;
                        end loop;
                    end if;
                end loop;
                falling_piece_formed_line <= formed_line;
            end if;
        end if;
    end process;

    process(clock)
    variable falling_piece_position_down : tetris_point;
    variable falling_piece_table : tetris_piece_table_data;
    begin
        if rising_edge(clock) then
            falling_piece_position_down_collides <= false;
            falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);
            falling_piece_position_down := (falling_piece_position.x, falling_piece_position.y + 1);
            if is_table_colliding(falling_piece_position_down, falling_piece_table, table) then
                falling_piece_position_down_collides <= true;
            end if;
        end if;
    end process;

    process(clock)
    variable falling_piece_position_left : tetris_point;
    variable falling_piece_table : tetris_piece_table_data;
    begin
        if rising_edge(clock) then
            falling_piece_position_left_collides <= false;
            falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);
            falling_piece_position_left := (falling_piece_position.x - 1, falling_piece_position.y);
            if is_table_colliding(falling_piece_position_left, falling_piece_table, table) then
                falling_piece_position_left_collides <= true;
            end if;
        end if;
    end process;    

    process(clock)
    variable falling_piece_table : tetris_piece_table_data;
    variable falling_piece_position_right : tetris_point;
    begin
        if rising_edge(clock) then
            falling_piece_position_right_collides <= false;
            falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);
            falling_piece_position_right := (falling_piece_position.x + 1, falling_piece_position.y);
            if is_table_colliding(falling_piece_position_right, falling_piece_table, table) then
                falling_piece_position_right_collides <= true;
            end if;
        end if;
    end process;   

    process(clock)
    variable next_falling_piece_table : tetris_piece_table_data;
    variable falling_piece_rotation_right_id : tetris_piece_rotation_id;
    begin
        if rising_edge(clock) then
            falling_piece_rotation_right_collides <= false;
            falling_piece_rotation_right_id := get_next_rotation_id(falling_piece_rotation_id);
            next_falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_right_id);
            if is_table_colliding(falling_piece_position, next_falling_piece_table, table) then
                falling_piece_rotation_right_collides <= true;
            end if;
        end if;
    end process;   

    process(clock)
    begin
        if rising_edge(clock) then
            case current_state is
                when tetris_init_state =>
                    next_state <= tetris_generate_new_piece_state;
                when tetris_generate_new_piece_state =>
                    next_state <= tetris_wait_fall_piece_state;
                when tetris_wait_fall_piece_state =>
                    next_state <= tetris_wait_fall_piece_state;
                    if falling_piece_move_down_triggered = '1' then
                        if falling_piece_position_down_collides then
                            next_state <= tetris_do_place_piece_state;
                        else
                            next_state <= tetris_do_fall_piece_state;
                        end if;
                    elsif falling_piece_move_left_triggered = '1' then
                        if not falling_piece_position_left_collides then
                            next_state <= tetris_do_move_piece_left_state;
                        end if;
                    elsif falling_piece_move_right_triggered = '1' then
                        if not falling_piece_position_right_collides then
                            next_state <= tetris_do_move_piece_right_state;
                        end if;
                    elsif falling_piece_rotate_right_triggered = '1' then
                        if not falling_piece_rotation_right_collides then
                            next_state <= tetris_do_rotate_piece_right_state;
                        end if;
                    end if;
                when tetris_do_fall_piece_state =>
                    next_state <= tetris_wait_fall_piece_state;
                when tetris_do_move_piece_left_state =>
                    next_state <= tetris_wait_fall_piece_state;
                when tetris_do_move_piece_right_state =>
                    next_state <= tetris_wait_fall_piece_state;
                when tetris_do_rotate_piece_right_state =>
                    next_state <= tetris_wait_fall_piece_state;
                when tetris_do_place_piece_state =>
                    next_state <= tetris_do_remove_full_lines_state;
                when tetris_do_remove_full_lines_state =>
                    if falling_piece_formed_line then
                        next_state <= tetris_do_remove_full_lines_state;
                    else
                        next_state <= tetris_generate_new_piece_state;
                    end if;
            end case;

            current_state <= next_state;
        end if;
    end process;

    process(clock)
    variable relative_block_position : tetris_point;
    variable falling_piece_table : tetris_piece_table_data;
    variable block_texture : tetris_block_texture_table_data;
    variable block_pallete : tetris_block_color_pallete;
    variable block_pixel_color_id : tetris_block_pixel_color_id;
    variable block_pixel_color : rgb_color;
    variable drawing_block_position : tetris_point := (0, 0);
    variable drawing_block_relative_point : point_2d := (0, 0);
    variable drawing_block_piece_id : tetris_piece_id;
    begin
        if rising_edge(clock) then
            if point /= (-1, -1) then
                if drawing_block_relative_point.x < config.block_size.w - 1 then
                    drawing_block_relative_point.x := drawing_block_relative_point.x + 1;
                else
                    drawing_block_relative_point.x := 0;

                    if drawing_block_position.x < tetris_table_size.w - 1 then
                        drawing_block_position.x := drawing_block_position.x + 1;
                    else
                        drawing_block_position.x := 0;

                        if drawing_block_relative_point.y < config.block_size.h - 1 then
                            drawing_block_relative_point.y := drawing_block_relative_point.y + 1;
                        else
                            drawing_block_relative_point.y := 0;

                            if drawing_block_position.y < tetris_table_size.h - 1 then
                                drawing_block_position.y := drawing_block_position.y + 1;
                            else
                                drawing_block_position.y := 0;
                            end if;
                        end if;
                    end if;
                end if;

                relative_block_position := (drawing_block_position.x - falling_piece_position.x, drawing_block_position.y - falling_piece_position.y);
                drawing_block_piece_id := table(drawing_block_position.y, drawing_block_position.x);
                if relative_block_position.x >= 0 and
                        relative_block_position.y >= 0 and
                        relative_block_position.x <= tetris_piece_table_size.w - 1 and
                        relative_block_position.y <= tetris_piece_table_size.h - 1 then
                    falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);
                    if falling_piece_table(relative_block_position.y, relative_block_position.x) = '1' then
                        drawing_block_piece_id := falling_piece_id;
                    end if;
                end if;
    
                block_texture := get_block_texture_by_id(drawing_block_piece_id);
                block_pallete := get_block_color_pallete_by_id(drawing_block_piece_id);
                block_pixel_color_id := block_texture(drawing_block_relative_point.y / 4, drawing_block_relative_point.x / 4);
                block_pixel_color := block_pallete(block_pixel_color_id);
                color <= block_pixel_color;
            end if;
        end if;
    end process;
end main;
