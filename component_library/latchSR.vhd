----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.08.2018 16:50:28
-- Design Name: 
-- Module Name: latchSR - Behavioral
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

entity latchSR is
    Port ( S : in STD_LOGIC;
           R : in STD_LOGIC;
           Q : out STD_LOGIC;
           QN : out STD_LOGIC);
end latchSR;

architecture Behavioral of latchSR is

    SIGNAL qbuf, qnbuf : STD_LOGIC := '0';

begin
    Q <= qbuf;
    QN <= qnbuf;
    process (S, R)
    begin
        qbuf <= R nor qnbuf;
        qnbuf <= S nor qbuf;
    end process;
end Behavioral;
