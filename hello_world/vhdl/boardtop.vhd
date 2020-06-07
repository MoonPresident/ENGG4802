----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2019 14:02:04
-- Design Name: 
-- Module Name: boardtop - Behavioral
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

entity boardtop is
    Port ( AN : out STD_LOGIC_VECTOR (7 downto 0);
           CA : out STD_Logic;
           CB : out STD_Logic;
           CC : out STD_Logic;
           CD : out STD_Logic;
           CE : out STD_Logic;
           CF : out STD_Logic;
           CG : out STD_Logic;
           DP : out STD_Logic;
           clk100mhz : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (15 downto 0));
end boardtop;

architecture Behavioral of boardtop is

    COMPONENT ssegDriver is
        port (
            clk : in std_logic;
            rst : in std_logic;
            cathode_p : out std_logic_vector(7 downto 0);
            digit1_p : in std_logic_vector(3 downto 0);
            anode_p : out std_logic_vector(7 downto 0);
            digit2_p : in std_logic_vector(3 downto 0);
            digit3_p : in std_logic_vector(3 downto 0);
            digit4_p : in std_logic_vector(3 downto 0);
            digit5_p : in std_logic_vector(3 downto 0);
            digit6_p : in std_logic_vector(3 downto 0);
            digit7_p : in std_logic_vector(3 downto 0);
            digit8_p : in std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    
    COMPONENT prescaler is
        Generic (
            width : integer := 16
        );
        Port ( 
            sys_clk : in STD_LOGIC;
            scaled_output : out STD_LOGIC
        );
    end COMPONENT;
    
    COMPONENT counter is
        Generic(
            width : integer := 8
        );
        Port ( 
            increment: in STD_LOGIC;
            enable : in STD_LOGIC;
            count : out STD_LOGIC_VECTOR(width - 1 downto 0)
        );
    end COMPONENT;

    signal enableHigh : STD_LOGIC;
    signal counterOut : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
    
    signal secondsClk, ssegClk : STD_LOGIC := '0';
    
    signal ssegAnode, ssegCathode : STD_LOGIC_VECTOR(7 downto 0);
    
begin
    
    AN <= ssegAnode;
    
    CA <= ssegCathode(0);
    CB <= ssegCathode(1);
    CC <= ssegCathode(2);
    CD <= ssegCathode(3);
    CE <= ssegCathode(4);
    CF <= ssegCathode(5);
    CG <= ssegCathode(6);
    DP <= ssegCathode(7);
    
    led <= counterOut(15 downto 0);
    
    
    enableHigh <= '1';
    
    p1: prescaler
        generic map(
            width => 27
        )
        port map(
            sys_clk => clk100mhz,
            scaled_output => secondsClk
        );
    
    c1: counter
        generic map(
            width => 16
        )
        port map(
            increment => secondsClk,
            enable => enableHigh,
            count => counterOut
        );
        
    p2: prescaler
        generic map(
            width => 15
        )
        port map(
            sys_clk => clk100mhz,
            scaled_output => ssegClk
        );
    
    sseg: ssegDriver
        port map(
            clk => ssegClk,
            rst => '0',
            cathode_p => ssegCathode,
            anode_p => ssegAnode,
            digit1_p => counterOut(3 downto 0),
            digit2_p => counterOut(7 downto 4),
            digit3_p => counterOut(11 downto 8),
            digit4_p => counterOut(15 downto 12),
            digit5_p => x"A",
            digit6_p => x"B",
            digit7_p => x"C",
            digit8_p => x"D"
        );


end Behavioral;
