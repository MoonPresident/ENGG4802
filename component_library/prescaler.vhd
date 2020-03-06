----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.12.2019 13:03:41
-- Design Name: 
-- Module Name: prescaler - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



--For SSEG display, a width of 15 is just about perfect.

entity prescaler is
    Generic (
        width : integer := 16
    );
    Port ( 
        sys_clk : in STD_LOGIC;
        scaled_output : out STD_LOGIC
    );
end prescaler;

architecture Behavioral of prescaler is

    signal scaler : STD_LOGIC_VECTOR(width - 1 downto 0) := (others => '0');

begin

    scaled_output <= scaler(width - 1);
    
    process (sys_clk)
    begin
        if rising_edge(sys_clk) then
            scaler <= scaler + 1;
        end if;
    end process;

end Behavioral;
