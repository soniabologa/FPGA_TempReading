library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    port (
        clk_in      : in  std_logic;
        reset_n     : in  std_logic;  -- Active-low (reset when '0')
        alarm_led   : out std_logic;
        -- Add a simulation-only port for temperature input
        sim_temp    : in  std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of top_level is
    signal alarm_latched : std_logic := '0';
    constant TEMP_THRESHOLD : integer := 2415;
begin
    -- For simulation, we'll use the sim_temp input directly
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset_n = '0' then  -- Active-low reset
                alarm_latched <= '0';
            elsif to_integer(unsigned(sim_temp)) > TEMP_THRESHOLD then
                alarm_latched <= '1';
            end if;
        end if;
    end process;
    
    alarm_led <= alarm_latched;
end architecture;