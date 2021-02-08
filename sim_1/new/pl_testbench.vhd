----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2021 05:50:37 PM
-- Design Name: 
-- Module Name: pl_testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pl_testbench is
--  Port ( );
end pl_testbench;

architecture Behavioral of pl_testbench is
    signal reset    : std_logic;
    signal clk_pl   : std_logic;
    signal rgb1_0   : std_logic;
    signal rgb1_1   : std_logic;
    signal rgb1_2   : std_logic;
    signal rgb2_0   : std_logic;
    signal rgb2_1   : std_logic;
    signal rgb2_2   : std_logic;
    signal sel0     : std_logic;
    signal sel1     : std_logic;
    signal sel2     : std_logic;
    signal sel3     : std_logic;
    signal lat      : std_logic;
    signal oe       : std_logic;
    signal clk_out  : std_logic;
    signal gnd0     : std_logic;
    signal gnd1     : std_logic;
    signal gnd2     : std_logic;
    constant t : time := 10ns;
begin
    
    reset <= '0';
    
    CLOCK_GEN : process
    begin
        clk_pl <= '1';
        wait for t/2;
        clk_pl <= '0';
        wait for t/2;
    end process;
    
    UUT : entity work.led_top
    port map(
        reset   =>  reset   ,
        clk_pl  =>  clk_pl  ,
        rgb1_0  =>  rgb1_0  ,
        rgb1_1  =>  rgb1_1  ,
        rgb1_2  =>  rgb1_2  ,
        rgb2_0  =>  rgb2_0  ,
        rgb2_1  =>  rgb2_1  ,
        rgb2_2  =>  rgb2_2  ,
        sel0    =>  sel0    ,
        sel1    =>  sel1    ,
        sel2    =>  sel2    ,
        sel3    =>  sel3    ,
        lat     =>  lat     ,
        oe      =>  oe      ,
        clk_out =>  clk_out ,
        gnd0    =>  gnd0    ,
        gnd1    =>  gnd1    ,
        gnd2    =>  gnd2    
    );

end Behavioral;
