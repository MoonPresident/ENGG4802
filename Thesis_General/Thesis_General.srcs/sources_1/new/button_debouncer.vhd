----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.05.2020 22:53:42
-- Design Name: 
-- Module Name: button_debouncer - Behavioral
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

entity button_debouncer is
    Generic (
        g_button_quant : integer := 1;
        g_debounce_scalar : integer := 7
    );
    Port (  I_clk : in std_logic;
            I_buttons : in STD_LOGIC_VECTOR (g_button_quant - 1 downto 0);
            O_buttons_pulse : out STD_LOGIC_VECTOR (g_button_quant - 1 downto 0);
            O_buttons_held : out STD_LOGIC_VECTOR (g_button_quant - 1 downto 0)
    );
end button_debouncer;

architecture Behavioral of button_debouncer is
    type state is (state_low, state_debouncing, state_high);
    type state_vector is array (g_button_quant - 1 downto 0) of state;
    type counter_vector is array(g_button_quant - 1 downto 0) of std_logic_vector(g_debounce_scalar downto 0);
    
    signal next_state : state_vector := (others => state_low);
    signal current_state : state_vector := (others => state_low);
    signal counters : counter_vector := (others => (others => '0'));
begin
    --Aayyyyyyeeee, this one worked on the first bitstream, no simulations or nothing.
    process
    begin
        if rising_edge(I_clk) then
            for i in 0 to (g_button_quant - 1) loop
                case current_state(i) is
                    when state_low =>
                        --Set counters and button holding flag low. Set button pulse to button input.
                        counters(i) <= (others => '0');
                        O_buttons_held(i) <= '0';
                        O_buttons_pulse(i) <= I_buttons(i);
                        
                        if I_buttons(i) = '1' then
                            next_state(i) <= state_debouncing;
                        else
                            next_state(i) <= state_low;
                        end if;
                        
                    when state_debouncing =>
                        counters(i) <= counters(i) + 1;
                        O_buttons_held(i) <= '0';
                        O_buttons_pulse(i) <= '0';
                        if(counters(i)(g_debounce_scalar) = '1')  then
                            if(I_buttons(i) = '1') then
                                next_state(i) <= state_high;
                            else
                                next_state(i) <= state_low;
                            end if;
                        else
                            next_state(i) <= state_debouncing;
                        end if;
                        
                    when state_high =>
                        O_buttons_pulse(i) <= '0';
                        O_buttons_held(i) <= '1';
                        counters(i) <= (others => '0');
                        if I_buttons(i) = '0' then
                            next_state(i) <= state_low;
                        else
                            next_state(i) <= state_high;
                        end if;
                end case;
            end loop;
        end if;
    end process;
    
    current_state <= next_state;

end Behavioral;
