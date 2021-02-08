library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.led_package.all;
Library xpm;
use xpm.vcomponents.all;

entity led_top is
    port(
        --ENTITY INTERFACE
        reset   : in std_logic;
        clk_pl  : in std_logic; --programmable logic clock
        clk_ps  : in std_logic; --processor-generated clock
        addr_ps : in std_logic_vector(9 downto 0);
        data_ps : in std_logic_vector(COLOR_DEPTH-1 downto 0);

        --LED MATRIX INTERFACE
        rgb1_0  : out std_logic;
        rgb1_1  : out std_logic;
        rgb1_2  : out std_logic;
        rgb2_0  : out std_logic;
        rgb2_1  : out std_logic;
        rgb2_2  : out std_logic;
        sel0    : out std_logic; 
        sel1    : out std_logic; 
        sel2    : out std_logic; 
        sel3    : out std_logic; 
        lat     : out std_logic; 
        oe      : out std_logic;
        clk_out : out std_logic; --clock to LED display
        gnd0    : out std_logic := '0';
        gnd1    : out std_logic := '0';
        gnd2    : out std_logic := '0'
    );
end led_top;

architecture structural of led_top is
    type DATA_TYPE is array (integer range <>) of std_logic_vector(COLOR_DEPTH-1 downto 0);
    signal ram_do           :   DATA_TYPE(0 to 1);
    signal addr_led         :   std_logic_vector(8 downto 0); --512 locations
    signal clk_led          :   std_logic;
    signal s_rgb1           :   std_logic_vector(2 downto 0);
    signal s_rgb2           :   std_logic_vector(2 downto 0);
    signal s_sel            :   std_logic_vector(3 downto 0);
    
    signal ena              :   std_logic_vector(1 downto 0);
    signal enb              :   std_logic := '1';
    signal wea              :   std_logic_vector(0 downto 0) := "1";
    signal dbiterra 		: 	std_logic := '0';
	signal dbiterrb			:	std_logic := '0';
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal injectdbiterra	:	std_logic := '0';
	signal injectdbiterrb 	:	std_logic := '0';
	signal injectsbiterra 	:	std_logic := '0';
	signal injectsbiterrb 	:	std_logic := '0';
	signal regcea 			:	std_logic := '0';
	signal regceb 			:	std_logic := '0';
	signal sleep 			:	std_logic := '0';
begin
    rgb1_0 <= s_rgb1(0);
    rgb1_1 <= s_rgb1(1);
    rgb1_2 <= s_rgb1(2);
    rgb2_0 <= s_rgb2(0);
    rgb2_1 <= s_rgb2(1);
    rgb2_2 <= s_rgb2(2);
    
    sel0 <= s_sel(0);
    sel1 <= s_sel(1);
    sel2 <= s_sel(2);
    sel3 <= s_sel(3);
    
	CLK_DIV_LED_CONTROL : entity work.clk_div
        generic map(count => 6)
        port map(
           clk_in => clk_pl,
           clk_out => clk_led
    );

    LED_CONTROL: entity work.led_control
    port map(
        clk => clk_led,
        reset => reset,
        di1 => ram_do(0),
        di2 => ram_do(1),
        rgb1 => s_rgb1,
        rgb2 => s_rgb2,
        sel => s_sel,
        lat => lat,
        oe => oe,
        clk_out => clk_out,
        led_addr => addr_led
    );
    
    ena(0) <= NOT addr_ps(9);
    ena(1) <= addr_ps(9);
    
    SDPRAM_GENERATE : for i in 0 to 1 generate
        -- xpm_memory_sdpram: Simple Dual Port RAM
        -- Xilinx Parameterized Macro, version 2019.2
        xpm_memory_sdpram_inst : xpm_memory_sdpram
        generic map (
            ADDR_WIDTH_A => 9, -- DECIMAL
            ADDR_WIDTH_B => 9, -- DECIMAL
            AUTO_SLEEP_TIME => 0, -- DECIMAL
            BYTE_WRITE_WIDTH_A => 24, -- DECIMAL
            CASCADE_HEIGHT => 0, -- DECIMAL
            CLOCKING_MODE => "independent_clock", -- String
            ECC_MODE => "no_ecc", -- String
            MEMORY_INIT_FILE => "none", -- String
            MEMORY_INIT_PARAM => "0", -- String
            MEMORY_OPTIMIZATION => "true", -- String
            MEMORY_PRIMITIVE => "auto", -- String
            MEMORY_SIZE => 32*16*24, -- DECIMAL
            MESSAGE_CONTROL => 0, -- DECIMAL
            READ_DATA_WIDTH_B => 24, -- DECIMAL
            READ_LATENCY_B => 1, -- DECIMAL
            READ_RESET_VALUE_B => "0", -- String
            RST_MODE_A => "SYNC", -- String
            RST_MODE_B => "SYNC", -- String
            SIM_ASSERT_CHK => 0, -- DECIMAL; enable simulation messages
            USE_EMBEDDED_CONSTRAINT => 0, -- DECIMAL
            USE_MEM_INIT => 1, -- DECIMAL
            WAKEUP_TIME => "disable_sleep", -- String
            WRITE_DATA_WIDTH_A => 24, -- DECIMAL
            WRITE_MODE_B => "no_change" -- String
        )
        port map (
            dbiterrb => dbiterrb,
            doutb => ram_do(i),
            sbiterrb => sbiterrb,
            addra => addr_ps(8 downto 0),
            addrb => addr_led,
            clka => clk_ps,
            clkb => clk_led,
            dina => data_ps,
            ena => ena(i),
            enb => enb,
            injectdbiterra => injectdbiterra,
            injectsbiterra => injectsbiterra,
            regceb => regceb,
            rstb => reset,
            sleep => sleep,
            wea => wea
        );
        -- End of xpm_memory_sdpram_inst instantiation
    end generate;
end structural;
