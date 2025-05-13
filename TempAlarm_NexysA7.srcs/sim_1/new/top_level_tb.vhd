library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level_tb is
-- Empty entity for testbench
end top_level_tb;

architecture sim of top_level_tb is
    -- Component declaration for the Device Under Test (DUT)
    component top_level is
        port (
            clk_in      : in  std_logic;
            reset_n     : in  std_logic;
            alarm_led   : out std_logic;
            sim_temp    : in  std_logic_vector(15 downto 0)
        );
    end component;
    
    -- Test signals
    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '0';  -- Initialize to reset state (active low)
    signal alarm_led    : std_logic;
    signal test_temp_value : std_logic_vector(15 downto 0) := (others => '0');
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the top_level entity (Device Under Test)
    DUT: top_level port map (
        clk_in    => clk,
        reset_n   => reset_n,
        alarm_led => alarm_led,
        sim_temp  => test_temp_value
    );
    
    -- Clock process definition
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize with reset active
        reset_n <= '0';  -- Active-low reset (reset is active)
        wait for 100 ns;
        
        -- Release reset
        reset_n <= '1';  -- Release reset
        wait for 100 ns;
        
        -- Apply temperature below threshold (200-300ns)
        report "Setting temperature below threshold (2000)";
        test_temp_value <= std_logic_vector(to_unsigned(2000, 16));
        wait for 100 ns;
        
        -- Verify alarm is OFF
        assert alarm_led = '0'
            report "Alarm should be OFF with temperature below threshold"
            severity note;
        
        -- Gradually increase temperature to above threshold (300-400ns)
        report "Increasing temperature above threshold (2500)";
        test_temp_value <= std_logic_vector(to_unsigned(2500, 16));
        wait for 100 ns;
        
        -- Verify alarm is ON
        assert alarm_led = '1'
            report "Alarm should be ON with temperature above threshold"
            severity note;
        
        -- Gradually decrease temperature below threshold again (400-500ns)
        report "Decreasing temperature below threshold (2000)";
        test_temp_value <= std_logic_vector(to_unsigned(2000, 16));
        wait for 100 ns;
        
        -- Verify alarm STAYS ON (latching behavior)
        assert alarm_led = '1'
            report "Alarm should STAY ON even when temperature drops (latching behavior)"
            severity note;
        
        -- Continue with temperature below threshold (500-600ns)
        report "Temperature remains below threshold (1800)";
        test_temp_value <= std_logic_vector(to_unsigned(1800, 16));
        wait for 100 ns;
        
        -- Verify alarm STILL stays ON despite further temperature drop
        assert alarm_led = '1'
            report "Alarm should REMAIN ON even with further temperature decrease"
            severity note;
        
        -- Apply reset at 700ns
        report "Applying reset";
        reset_n <= '0';  -- Active-low reset
        wait for 100 ns;
        
        -- Verify alarm turns OFF after reset
        assert alarm_led = '0'
            report "Alarm should turn OFF after reset"
            severity note;
        
        -- End test
        report "Simulation completed successfully after 800ns!";
        wait;
    end process;
end architecture;