----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.08.2018 16:30:36
-- Design Name: 
-- Module Name: dFlipFlop - Behavioral
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

entity dFlipFlop is
    Port ( D : in STD_LOGIC := '0';
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           Q : out STD_LOGIC := '0'
           );
end dFlipFlop;

architecture Behavioral of dFlipFlop is

begin
    
    process (CLK, RST)
    begin
        if(CLK = '1' and CLK'EVENT) then
            if(RST = '1') then
                Q <= '0';
                --QN <= '1';
            else
                Q <= '1'AND D;
                --QN <= NOT D;
            end if;
        end if;
    end process;        

end Behavioral;
