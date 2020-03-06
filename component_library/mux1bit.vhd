----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.08.2018 22:53:54
-- Design Name: 
-- Module Name: mux1bit - Behavioral
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

entity mux1bit is
    Port ( sel0 : in STD_LOGIC;
           in0 : in STD_LOGIC;
           out0 : out STD_LOGIC;
           out1 : out STD_LOGIC
    );
end mux1bit;

architecture Behavioral of mux1bit is

begin
    
    out0 <= in0 AND NOT sel0;
    out1 <= in0 AND sel0;

end Behavioral;
