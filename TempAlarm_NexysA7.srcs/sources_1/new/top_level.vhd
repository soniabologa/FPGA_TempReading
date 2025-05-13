library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temp_display is
    Port ( 
        CLK100MHZ : in  STD_LOGIC;
        BTNC      : in  STD_LOGIC;
        SW0       : in  STD_LOGIC;  -- Added switch to reset alarm
        SEG       : out STD_LOGIC_VECTOR (6 downto 0);
        AN        : out STD_LOGIC_VECTOR (7 downto 0);
        LED17     : out STD_LOGIC   -- Added alarm LED
    );
end temp_display;

architecture Behavioral of temp_display is
    -- XADC primitive declaration
    component XADC
        generic (
            INIT_40 : bit_vector := X"0000";
            INIT_41 : bit_vector := X"0000";
            INIT_42 : bit_vector := X"0800";
            INIT_48 : bit_vector := X"0100";
            INIT_49 : bit_vector := X"0000";
            INIT_4A : bit_vector := X"0000";
            INIT_4B : bit_vector := X"0000";
            INIT_4C : bit_vector := X"0000";
            INIT_4D : bit_vector := X"0000";
            INIT_4E : bit_vector := X"0000";
            INIT_4F : bit_vector := X"0000";
            INIT_50 : bit_vector := X"B5ED";
            INIT_51 : bit_vector := X"57E4";
            INIT_52 : bit_vector := X"A147";
            INIT_53 : bit_vector := X"CA33";
            INIT_54 : bit_vector := X"A93A";
            INIT_55 : bit_vector := X"52C6";
            INIT_56 : bit_vector := X"9555";
            INIT_57 : bit_vector := X"AE4E";
            INIT_58 : bit_vector := X"5999";
            INIT_5C : bit_vector := X"5111";
            SIM_DEVICE : string := "7SERIES";
            SIM_MONITOR_FILE : string := "design.txt"
        );
        port (
            CONVST         : in  STD_LOGIC;
            CONVSTCLK      : in  STD_LOGIC;
            DADDR          : in  STD_LOGIC_VECTOR (6 downto 0);
            DCLK           : in  STD_LOGIC;
            DEN            : in  STD_LOGIC;
            DI             : in  STD_LOGIC_VECTOR (15 downto 0);
            DWE            : in  STD_LOGIC;
            RESET          : in  STD_LOGIC;
            VAUXN          : in  STD_LOGIC_VECTOR (15 downto 0);
            VAUXP          : in  STD_LOGIC_VECTOR (15 downto 0);
            VN             : in  STD_LOGIC;
            VP             : in  STD_LOGIC;
            ALM            : out STD_LOGIC_VECTOR (7 downto 0);
            BUSY           : out STD_LOGIC;
            CHANNEL        : out STD_LOGIC_VECTOR (4 downto 0);
            DO             : out STD_LOGIC_VECTOR (15 downto 0);
            DRDY           : out STD_LOGIC;
            EOC            : out STD_LOGIC;
            EOS            : out STD_LOGIC;
            JTAGBUSY       : out STD_LOGIC;
            JTAGLOCKED     : out STD_LOGIC;
            JTAGMODIFIED   : out STD_LOGIC;
            OT             : out STD_LOGIC
        );
    end component;

    -- Signals for XADC
    signal reset          : STD_LOGIC;
    signal daddr          : STD_LOGIC_VECTOR(6 downto 0);
    signal den            : STD_LOGIC := '0';
    signal di             : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal dwe            : STD_LOGIC := '0';
    signal do_out         : STD_LOGIC_VECTOR(15 downto 0);
    signal drdy           : STD_LOGIC;
    signal eoc            : STD_LOGIC;
    signal eos            : STD_LOGIC;
    signal busy           : STD_LOGIC;
    signal channel        : STD_LOGIC_VECTOR(4 downto 0);
    signal vauxn          : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal vauxp          : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    
    -- Temperature calculation
    signal temp_raw       : STD_LOGIC_VECTOR(15 downto 0);
    signal temp_celsius   : INTEGER range -50 to 150;
    signal temp_tens      : INTEGER range 0 to 9;
    signal temp_ones      : INTEGER range 0 to 9;
    
    -- Counter for display multiplexing
    signal refresh_counter: STD_LOGIC_VECTOR(19 downto 0);
    signal led_activating_counter: STD_LOGIC_VECTOR(1 downto 0);
    
    -- Debug signals
    signal reading_temp   : STD_LOGIC := '0';
    signal update_counter : INTEGER range 0 to 100000000 := 0;
    
    -- Alarm signals
    signal alarm_active   : STD_LOGIC := '0'; -- Added for temperature alarm state
    
    -- Segment patterns (Active LOW for Nexys A7)
    type segment_array is array (0 to 9) of STD_LOGIC_VECTOR(6 downto 0);
    constant segments : segment_array := (
        "1000000", -- 0
        "1111001", -- 1
        "0100100", -- 2
        "0110000", -- 3
        "0011001", -- 4
        "0010010", -- 5
        "0000010", -- 6
        "1111000", -- 7
        "0000000", -- 8
        "0010000"  -- 9
    );

begin
    -- Reset signal
    reset <= BTNC;
    
    -- Configure and instantiate XADC
    XADC_inst : XADC
    generic map(
        -- Enable continuous sampling mode and temperature sensor
        INIT_40 => X"1000", -- Continuous sampling mode only
        INIT_41 => X"2F00", -- Disable alarms
        INIT_42 => X"0800", -- ADCCLK divider setting
        INIT_48 => X"0100", -- Enable temperature sensor
        INIT_49 => X"0000",
        SIM_DEVICE => "7SERIES"
    )
    port map(
        CONVST         => '0',
        CONVSTCLK      => '0',
        DADDR          => daddr,
        DCLK           => CLK100MHZ,
        DEN            => den,
        DI             => di,
        DWE            => dwe,
        RESET          => reset,
        VAUXN          => vauxn,
        VAUXP          => vauxp,
        VN             => '0',
        VP             => '0',
        ALM            => open,
        BUSY           => busy,
        CHANNEL        => channel,
        DO             => do_out,
        DRDY           => drdy,
        EOC            => eoc,
        EOS            => eos,
        JTAGBUSY       => open,
        JTAGLOCKED     => open,
        JTAGMODIFIED   => open,
        OT             => open
    );
    
    -- Process to read temperature from XADC
    process(CLK100MHZ, reset)
    begin
        if reset = '1' then
            den <= '0';
            daddr <= "0000000"; -- Temperature sensor address
            temp_raw <= (others => '0');
            reading_temp <= '0';
            update_counter <= 0;
        elsif rising_edge(CLK100MHZ) then
            den <= '0'; -- Default state
            
            -- Update temperature reading periodically
            if update_counter >= 50000000 then  -- 0.5 seconds at 100MHz
                update_counter <= 0;
                reading_temp <= '1';
                den <= '1';
                daddr <= "0000000"; -- Temperature sensor address
            else
                update_counter <= update_counter + 1;
                reading_temp <= '0';
            end if;
            
            -- Capture data when ready
            if drdy = '1' then
                temp_raw <= do_out;
            end if;
        end if;
    end process;
    
    -- Process to convert raw XADC value to temperature
    process(CLK100MHZ)
        variable temp_int : INTEGER;
    begin
        if rising_edge(CLK100MHZ) then
            -- For Artix-7: Temp(°C) = ((ADC_CODE * 503.975) / 4096) - 273.15
            temp_int := to_integer(unsigned(temp_raw(15 downto 4)));
            temp_celsius <= (temp_int * 504) / 4096 - 273;
            
            -- Extract digits for display
            if temp_celsius < 0 then
                temp_tens <= 0;  -- Display 0 for negative values
                temp_ones <= 0;
            else
                temp_tens <= (temp_celsius / 10) mod 10;
                temp_ones <= temp_celsius mod 10;
            end if;
        end if;
    end process;
    
    -- Process for temperature alarm 
    process(CLK100MHZ, reset)
    begin
        if reset = '1' then
            alarm_active <= '0';  -- Reset alarm state
        elsif rising_edge(CLK100MHZ) then
            -- If switch is activated, reset the alarm
            if SW0 = '1' then
                alarm_active <= '0';
            -- If temperature goes above 33°C, activate alarm
            elsif temp_celsius > 32 then
                alarm_active <= '1';
            end if;
        end if;
    end process;
    
    -- Connect alarm signal to LED output
    LED17 <= alarm_active;

    -- Process to generate refresh counter
    process(CLK100MHZ, reset)
    begin
        if reset = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(CLK100MHZ) then
            refresh_counter <= std_logic_vector(unsigned(refresh_counter) + 1);
        end if;
    end process;
    
    -- 2 MSBs of refresh counter control multiplexing
    led_activating_counter <= refresh_counter(19 downto 18);
    
    -- Process to multiplex display digits
    process(led_activating_counter, temp_tens, temp_ones)
    begin
        -- Turn off all digits initially
        AN <= "11111111"; 
        
        case led_activating_counter is
            when "00" => -- Rightmost digit (ones)
                AN <= "11111110"; 
                SEG <= segments(temp_ones);
                
            when "01" => -- Tens digit
                AN <= "11111101"; 
                SEG <= segments(temp_tens);
                
            when others => -- All other digits off
                AN <= "11111111";
                SEG <= "1111111";
        end case;
    end process;
    
end Behavioral;