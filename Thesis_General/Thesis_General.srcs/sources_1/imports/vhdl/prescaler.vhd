----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2020 22:00:14
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

entity prescaler is
    Generic (
        width: integer := 16
    );
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end prescaler;

architecture Behavioral of prescaler is

    signal scaler : std_logic_vector(width - 1 downto 0);

begin

    clk_out <= scaler(width - 1);
    
    process (clk_in)
    begin
        if rising_edge(clk_in) then
            scaler <= scaler + 1;
        end if;
    end process;

end Behavioral;
