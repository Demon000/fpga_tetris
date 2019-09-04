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

--component ila_0
--port(
--	clk : in STD_LOGIC;
--	probe0 : in STD_LOGIC_VECTOR(10 DOWNTO 0);
--	probe1 : in STD_LOGIC_VECTOR(10 DOWNTO 0);
--	probe2 : in STD_LOGIC_VECTOR(10 DOWNTO 0);
--	probe3 : in STD_LOGIC_VECTOR(10 DOWNTO 0);
--	probe4 : in STD_LOGIC_VECTOR(10 DOWNTO 0);
--	probe5 : in STD_LOGIC_VECTOR(10 DOWNTO 0)
--);
--end component;

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

                if tetris_table(piece_position.y + i, piece_position.x + j) /= tetris_empty_id then
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
signal need_new_falling_piece : STD_LOGIC;
signal move_falling_piece_left : STD_LOGIC;
signal move_falling_piece_right : STD_LOGIC;
signal move_falling_piece_down : STD_LOGIC;
signal rotate_falling_piece_right : STD_LOGIC;

signal falling_trigger_ticks : natural;
signal falling_triggered : STD_LOGIC;

-- Position and size of the block being drawn
signal block_position : tetris_point := (0, 0);
signal block_relative_point : point_2d := (0, 0);

--signal probe_point_x : STD_LOGIC_VECTOR(10 downto 0);
--signal probe_point_y : STD_LOGIC_VECTOR(10 downto 0);

--signal probe_block_relative_point_x : STD_LOGIC_VECTOR(10 downto 0);
--signal probe_block_relative_point_y : STD_LOGIC_VECTOR(10 downto 0);

signal falling_piece_id : tetris_piece_id := tetris_s_id;
signal falling_piece_position : tetris_point := tetris_default_falling_piece_position;
signal falling_piece_rotation_id : tetris_piece_rotation_id := tetris_normal_rotation_id;

signal block_drawing_piece_id : tetris_piece_id;
begin
    falling_trigger_ticks <= config.piece_falling_ticks(level);

    falling_block_clock_timer : clock_timer
    generic map(
        restart_on_end => true
    )
    port map(
        clock => clock,
        trigger_ticks => falling_trigger_ticks,
        pulse => falling_triggered
    );

--    probe_point_x <= std_logic_vector(to_unsigned(point.x, 11));
--    probe_point_y <= std_logic_vector(to_unsigned(point.y, 11));

--    probe_block_relative_point_x <= std_logic_vector(to_unsigned(block_relative_point.x, 11));
--    probe_block_relative_point_y <= std_logic_vector(to_unsigned(block_relative_point.y, 11));

--    ila_0_inst : ila_0
--    port map(
--        clk => clock,
--        probe0 => probe_point_x,
--        probe1 => probe_point_y,
--        probe2 => probe_block_relative_point_x,
--        probe3 => probe_block_relative_point_y,
--        probe4 => "00000000000",
--        probe5 => "00000000000"
--    );

    process(clock)
    begin
        if rising_edge(clock) then
            if need_new_falling_piece = '1' then
                falling_piece_id <= tetris_s_id;
                falling_piece_position <= tetris_default_falling_piece_position;
                falling_piece_rotation_id <= tetris_normal_rotation_id;
            end if;

            if rotate_falling_piece_right = '1' then
                falling_piece_rotation_id <= get_next_rotation_id(falling_piece_rotation_id);
            end if;

            if move_falling_piece_down = '1' then
                falling_piece_position <= (falling_piece_position.x, falling_piece_position.y + 1);
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
    variable next_rotation_id : tetris_piece_rotation_id;
    variable next_falling_piece_table : tetris_piece_table_data;
    variable falling_piece_table : tetris_piece_table_data;
    begin
        if rising_edge(clock) then
            falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);

            need_new_falling_piece <= '0';
            move_falling_piece_down <= '0';
            if falling_triggered = '1' then
                next_position := (falling_piece_position.x, falling_piece_position.y + 1);
                if is_table_colliding(next_position, falling_piece_table, table) then
                    write_piece_to_table(falling_piece_position, falling_piece_table, falling_piece_id, table);

                    need_new_falling_piece <= '1';
                else
                    move_falling_piece_down <= '1';
                end if;
            end if;

            move_falling_piece_left <= '0';
            if left_button_press = '1' then
                next_position := (falling_piece_position.x - 1, falling_piece_position.y);
                if not is_table_colliding(next_position, falling_piece_table, table) then
                    move_falling_piece_left <= '1';
                end if;
            end if;

            move_falling_piece_right <= '0';
            if right_button_press = '1' then
                next_position := (falling_piece_position.x + 1, falling_piece_position.y);
                if not is_table_colliding(next_position, falling_piece_table, table) then
                    move_falling_piece_right <= '1';
                end if;
            end if;

            rotate_falling_piece_right <= '0';
            if rotate_button_press = '1' then
                next_rotation_id := get_next_rotation_id(falling_piece_rotation_id);
                next_falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, next_rotation_id);
                if not is_table_colliding(falling_piece_position, next_falling_piece_table, table) then
                    rotate_falling_piece_right <= '1';
                end if;
            end if;
        end if;
    end process;

    process(clock)
    begin
        if rising_edge(clock) then
            if point /= (-1, -1) then
                
                if block_relative_point.x < config.block_size.w - 1 then
                    block_relative_point.x <= block_relative_point.x + 1;
                else
                    block_relative_point.x <= 0;

                    if block_position.x < tetris_table_size.w - 1 then
                        block_position.x <= block_position.x + 1;
                    else
                        block_position.x <= 0;

                        if block_relative_point.y < config.block_size.h - 1 then
                            block_relative_point.y <= block_relative_point.y + 1;
                        else
                            block_relative_point.y <= 0;

                            if block_position.y < tetris_table_size.h - 1 then
                                block_position.y <= block_position.y + 1;
                            else
                                block_position.y <= 0;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process(clock)
    variable relative_block_position : tetris_point;
    variable falling_piece_table : tetris_piece_table_data;
    begin
        if rising_edge(clock) then
            block_drawing_piece_id <= table(block_position.y, block_position.x);

            relative_block_position := (block_position.x - falling_piece_position.x, block_position.y - falling_piece_position.y);
            if relative_block_position.x >= 0 and
                    relative_block_position.y >= 0 and
                    relative_block_position.x <= tetris_piece_table_size.w - 1 and
                    relative_block_position.y <= tetris_piece_table_size.h - 1 then

                falling_piece_table := get_rotation_table_by_type_id(falling_piece_id, falling_piece_rotation_id);
                if falling_piece_table(relative_block_position.y, relative_block_position.x) = '1' then
                    block_drawing_piece_id <= falling_piece_id;
                end if;
            end if;
        end if;
    end process;

    process(clock)
    variable block_color : rgb_color;
    begin
        if rising_edge(clock) then
            color <= grey_color;
            if block_drawing_piece_id /= tetris_empty_id then
                block_color := get_color_by_id(block_drawing_piece_id);
                color <= block_color;
            end if;
        end if;
    end process;
end main;
