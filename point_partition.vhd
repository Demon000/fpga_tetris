library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library generic_types;
use generic_types.generic_types.all;

entity point_partition is
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
end point_partition;

architecture main of point_partition is
signal local_partition : point_small_2d := (0, 0);
signal local_relative_point : point_small_2d := (0, 0);
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if paused = '0' then
                if local_relative_point.x < partition_size.w - 1 then
                    local_relative_point.x <= local_relative_point.x + 1;
                else
                    local_relative_point.x <= 0;

                    if local_partition.x < space_size.w - 1 then
                        local_partition.x <= local_partition.x + 1;
                    else
                        local_partition.x <= 0;

                        if local_relative_point.y < partition_size.h - 1 then
                            local_relative_point.y <= local_relative_point.y + 1;
                        else
                            local_relative_point.y <= 0;

                            if local_partition.y < space_size.h - 1 then
                                local_partition.y <= local_partition.y + 1;
                            else
                                local_partition.y <= 0;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    partition <= local_partition;
    relative_point <= local_relative_point;
end main;
