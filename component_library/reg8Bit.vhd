----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.08.2018 16:52:17
-- Design Name: 
-- Module Name: reg8Bit - Behavioral
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

entity reg8Bit is
    Port ( 
        regIn : in STD_LOGIC_VECTOR (7 downto 0);
        regOut : out STD_LOGIC_VECTOR (7 downto 0) := "10101010";
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC
    );
end reg8Bit;

architecture Behavioral of reg8Bit is

begin
    
    
    process (CLK, RST)
    begin
        
        if (CLK = '1' and CLK'EVENT) then
            regOut <= regIn;
        end if;
        if(RST = '1') then
            regOut <= "10101010";
        end if;
    end process;
    
end Behavioral;
