library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.led_package.all;

entity led_control is
    Port(
        clk     : in std_logic; --internal clock
        reset   : in std_logic;
        di1     : in std_logic_vector(COLOR_DEPTH-1 downto 0); --upper
        di2     : in std_logic_vector(COLOR_DEPTH-1 downto 0); --lower

        rgb1    : out std_logic_vector(2 downto 0);
        rgb2    : out std_logic_vector(2 downto 0);
        sel     : out std_logic_vector(3 downto 0); --select  
        lat     : out std_logic; --latch             
        oe      : out std_logic; --output enable
        clk_out : out std_logic; --clock to LED display
        
        led_addr: out std_logic_vector(8 downto 0) --2^9=512 locations
    );
end entity;

architecture behavioral of led_control is
    type STATE_TYPE is (GET_DATA, INCR_LED, INCR_SECT, LATCH, INCR_DUTY);
    
    signal state        : STATE_TYPE := INCR_DUTY;
    signal next_state   : STATE_TYPE;
    signal s_rgb1       : std_logic_vector(2 downto 0);
    signal s_rgb2       : std_logic_vector(2 downto 0);
    signal next_rgb1    : std_logic_vector(2 downto 0);
    signal next_rgb2    : std_logic_vector(2 downto 0);
    signal col          : unsigned(5 downto 0) := (others => '0');
    signal next_col     : unsigned(5 downto 0);
    signal sect         : unsigned(3 downto 0) := (others => '0');
    signal next_sect    : unsigned(3 downto 0);
    
    signal duty         : unsigned(7 downto 0) := (others => '0');
    signal next_duty    : unsigned(7 downto 0);
    
    signal led_count    : unsigned(8 downto 0) := (others => '0');
    signal next_led_count : unsigned(8 downto 0);
begin

    rgb1 <= s_rgb1; rgb2 <= s_rgb2;
    sel <= std_logic_vector(sect);
    led_addr <= std_logic_vector(led_count);
    
    STATE_REGISTER : process(clk)
    begin
        if rising_edge(clk) then
            if(reset = '1') then
                state <= INCR_DUTY;
                col <= (others => '0');
                sect <= (others => '1');
                duty <= (others => '0');
                led_count <= (others => '0');
            else
                state <= next_state;
                s_rgb1 <= next_rgb1;
                s_rgb2 <= next_rgb2;
                col <= next_col;
                sect <= next_sect;
                duty <= next_duty;
                led_count <= next_led_count;
            end if;
        end if;
    end process;
    
    STATE_MACHINE : process(state, col ,sect, duty, di1, di2, led_count)
        variable v_rgb1, v_rgb2 : std_logic_vector(2 downto 0);
        variable r_count1, g_count1, b_count1 : integer range 2**(COLOR_DEPTH/3)-1 downto 0;
        variable r_count2, g_count2, b_count2 : integer range 2**(COLOR_DEPTH/3)-1 downto 0;
        variable skip : std_logic := '0';
    begin
        --DEFAULT SIGNAL ASSIGNMENTS
        next_rgb1 <= s_rgb1;
        next_rgb2 <= s_rgb2;
        next_state <= state;
        next_col <= col;
        next_sect <= sect;
        next_duty <= duty;
        next_led_count <= led_count;
        v_rgb1 := "000"; v_rgb2 := "000"; clk_out <= '0'; lat <= '0'; oe <= '1';
        
        r_count1 := to_integer( unsigned( di1( COLOR_DEPTH-1        downto  2*COLOR_DEPTH/3 ) )); --bits 23 downto 16
        g_count1 := to_integer( unsigned( di1( 2*COLOR_DEPTH/3-1    downto  COLOR_DEPTH/3   ) )); --bits 15 downto 8
        b_count1 := to_integer( unsigned( di1( COLOR_DEPTH/3-1      downto  0               ) )); --bits 7 downto 0
        r_count2 := to_integer( unsigned( di2( COLOR_DEPTH-1        downto  2*COLOR_DEPTH/3 ) )); --bits 23 downto 16
        g_count2 := to_integer( unsigned( di2( 2*COLOR_DEPTH/3-1    downto  COLOR_DEPTH/3   ) )); --bits 15 downto 8
        b_count2 := to_integer( unsigned( di2( COLOR_DEPTH/3-1      downto  0               ) )); --bits 7 downto 0
         
        case state is
        when GET_DATA =>
            oe <= '0';
            if(duty < gamma255(r_count1) ) then v_rgb1(2) := '1'; end if;
            if(duty < gamma255(g_count1) ) then v_rgb1(1) := '1'; end if;
            if(duty < gamma255(b_count1) ) then v_rgb1(0) := '1'; end if;
            if(duty < gamma255(r_count2) ) then v_rgb2(2) := '1'; end if;
            if(duty < gamma255(g_count2) ) then v_rgb2(1) := '1'; end if;
            if(duty < gamma255(b_count2) ) then v_rgb2(0) := '1'; end if;
            if(col < IMG_WIDTH) then
                next_col <= col + 1;  
                next_state <= INCR_LED;
            else
                next_state <= INCR_SECT;
            end if;
        when INCR_LED =>
            oe <= '0';
--            if(col > 1) then
                clk_out <= '1';
--            end if;
            next_led_count <= led_count + 1;
            next_state <= GET_DATA;
        when INCR_SECT =>
            next_col <= (others => '0');
            next_sect <= sect + 1;
            next_state <= LATCH;
        when LATCH =>
            lat <= '1';
            next_state <= INCR_DUTY;
        when INCR_DUTY =>
            if(sect = "1111") then
                if(duty = unsigned(to_signed(-2, COLOR_DEPTH/3))) then
                    next_duty <= (others => '0');
                else
                    next_duty <= duty + 1;
                end if;
            end if;
            next_state <= GET_DATA;
        end case;
        next_rgb1 <= v_rgb1;
        next_rgb2 <= v_rgb2;
    end process;
end architecture;