library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pin_fanout is
    port(
        gpio : out std_logic_vector(4 downto 0);
        p1_up : in std_logic;
        p1_down : in std_logic;
        p2_up : in std_logic;
        p2_down : in std_logic;
        reset : in std_logic
    );
end pin_fanout;

architecture Behavioral of pin_fanout is
begin
    gpio(0) <= p1_up;
    gpio(1) <= p1_down;
    gpio(2) <= p2_up;
    gpio(3) <= p2_down;
    gpio(4) <= reset;
end Behavioral;
