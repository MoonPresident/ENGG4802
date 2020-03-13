----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2020 21:05:53
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
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity boardtop is
    Port ( 
        AN : out STD_LOGIC_VECTOR (7 downto 0);
        CA : out STD_Logic;
        CB : out STD_Logic;
        CC : out STD_Logic;
        CD : out STD_Logic;
        CE : out STD_Logic;
        CF : out STD_Logic;
        CG : out STD_Logic;
        DP : out STD_Logic;
        LED : out std_logic_vector(1 downto 0);
        clk100mhz : in STD_LOGIC;
        
        BTNC: in std_logic
    );
end boardtop;

architecture Behavioral of boardtop is

    COMPONENT core
        Port (
            I_clk : in  STD_LOGIC;
            I_reset : in  STD_LOGIC;
            I_halt : in  STD_LOGIC;
            
            -- External Interrupt interface
            I_int_data: in STD_LOGIC_VECTOR(31 downto 0);
            I_int: in STD_LOGIC;
            O_int_ack: out STD_LOGIC;
            
            -- memory interface
            MEM_I_ready : IN  std_logic;
            MEM_O_cmd : OUT  std_logic;
            MEM_O_we : OUT  std_logic;
            -- fixme: this is not a true byteEnable and so is confusing.
            -- Will be fixed when memory swizzling is brought core-size
            MEM_O_byteEnable : OUT  std_logic_vector(1 downto 0);
            MEM_O_addr : OUT  std_logic_vector(XLEN32M1 downto 0);
            MEM_O_data : OUT  std_logic_vector(XLEN32M1 downto 0);
            MEM_I_data : IN  std_logic_vector(XLEN32M1 downto 0);
            MEM_I_dataReady : IN  std_logic
            
            ; -- This debug output contains some internal state for debugging
            O_DBG:out std_logic_vector(63 downto 0)
        ); 
    end component;
    
    component prescaler
        Generic (
            width : integer
        );
        Port (
            clk_in: in std_logic;
            clk_out: out std_logic
        );
    end component;
    
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
    
    
    signal cEng_core : std_logic := '0';
    signal I_reset : std_logic := '1';
    signal I_halt : std_logic := '0';
    signal I_int : std_logic := '0';
    
    signal MEM_I_ready : std_logic := '1';
    signal MEM_I_data : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_I_dataReady : std_logic := '0';

    signal MEM_O_data_swizzed : std_logic_vector(31 downto 0) := (others => '0');
 
    signal O_int_ack : std_logic;
    
    signal MEM_O_cmd : std_logic := '0';
    signal MEM_O_we : std_logic := '0';
    signal MEM_O_byteEnable : std_logic_vector(1 downto 0) := (others => '0');
    signal MEM_O_addr : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_O_data : std_logic_vector(31 downto 0) := (others => '0');
    
    signal I_int_data:  STD_LOGIC_VECTOR(31 downto 0);
    signal MEM_I_data_raw : std_logic_vector(31 downto 0) := (others => '0');
    
    signal debug : std_logic_vector(63 downto 0) := (others => '0');
    
--        -- Clock period definitions
--    constant I_clk_period : time := 10 ns;
    
    
    signal MEM_readyState: integer := 0;
    
    
    -- SOC_CtrState definitions - running off SOC clock domain
    constant SOC_CtlState_Ready : integer :=  0;
    
    -- IMM SOC control states are immediate 1-cycle latency
    -- i.e. BRAM or explicit IO
    constant SOC_CtlState_IMM_WriteCmdComplete : integer := 9;
    constant SOC_CtlState_IMM_ReadCmdComplete : integer := 6;
        
    signal IO_LEDS: STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
    signal INT_DATA: std_logic_vector(BWIDTHM1 downto 0):= (others => '0');
    signal IO_DATA: std_logic_vector(BWIDTHM1 downto 0):= (others => '0');
    signal DDR3_DATA: std_logic_vector(BWIDTHM1 downto 0):= (others => '0');
    
    -- Block ram management
    signal MEM_64KB_ADDR : std_logic_vector(31 downto 0):= (others => '0');
    signal MEM_BANK_ID : std_logic_vector(15 downto 0):= (others => '0');
    signal MEM_ANY_CS : std_logic := '0';
    signal MEM_WE : std_logic := '0';
    
    signal MEM_CS_BRAM_1 : std_logic := '0';
    signal MEM_CS_BRAM_2 : std_logic := '0';
    signal MEM_CS_BRAM_3 : std_logic := '0';
    
    signal mI_wea : STD_LOGIC_VECTOR ( 3 downto 0 ):= (others => '0');
    
    signal MEM_CS_DDR3 : std_logic := '0';
    
    signal MEM_CS_SYSTEM : std_logic := '0';
    
    signal MEM_DATA_OUT_BRAM_1: std_logic_vector(BWIDTHM1 downto 0):= (others => '0');
    signal MEM_DATA_OUT_BRAM_2: std_logic_vector(BWIDTHM1 downto 0):= (others => '0');
    signal MEM_DATA_OUT_BRAM_3: std_logic_vector(BWIDTHM1 downto 0):= (others => '0');
    
    
    type rom_type is array (0 to 31) of std_logic_vector(31 downto 0);
           
--    constant ROM: rom_type:=(   
--    X"00008137", --   lui      sp,0x8
--    X"ffc10113", --   addi     sp,sp,-4 # 7ffc <_end+0x7fd0>
--    X"c00015f3", --   csrrw    a1,cycle,zero
--    X"c8001673", --   csrrw    a2,cycleh,zero
--    X"f13016f3", --   csrrw    a3,mimpid,zero
--    X"30101773", --   csrrw    a4,misa,zero
--    X"c02017f3", --   csrrw    a5,instret,zer
--    X"c8201873", --   csrrw    a6,instreth,ze
--    X"c00018f3", --   csrrw    a7,cycle,zero
--    X"c8001973", --   csrrw    s2,cycleh,zero
--    X"400019f3", --   csrrw    s3,0x400,zero
--    X"40069a73", --   csrrw    s4,0x400,a3
--    X"40001af3", --   csrrw    s5,0x400,zero
--    X"40011b73", --   csrrw    s6,0x400,sp
--    X"40001bf3", --   csrrw    s7,0x400,zero
--    X"40073c73", --   csrrc    s8,0x400,a4
--    X"40001cf3", --   csrrw    s9,0x400,zero
--    X"40111d73", --   csrrw    s10,0x401,sp
--    X"40101df3", --   csrrw    s11,0x401,zero
--    X"40172e73", --   csrrs    t3,0x401,a4
--    X"40101ef3", --   csrrw    t4,0x401,zero
--    X"0000006f", --             infloop
--    others => X"00000000");

    constant ROM: rom_type:=(   
    X"00001011", --   addi     sp, sp, -32
    X"0000ec22", --   sd	   s0, 24(sp)
    X"00001000", --   addi     s0, sp, 32
    X"fe042623", --   sw	   zero, -20(s0)
    
    X"fec42783", --   lw	   a5,-20(s0)
    X"00002785", --   addiw    a5, a5, 1
    X"fef42623", --   sw	   a5, -20(s0)

    X"0000006f", --             infloop
    others => X"00000000");
   
   signal ssegAnode, ssegCathode: std_logic_vector(7 downto 0) := x"00";
   
   signal ssegClk: std_logic := '0';

begin
 	-- The O_we signal can sustain too long. Clamp it to only when O_cmd is active.
    MEM_WE <= MEM_O_cmd and MEM_O_we;
    
    -- "Local" BRAM banks are 64KB. To address inside we need lower 16b
    MEM_64KB_ADDR <= X"0000" & MEM_O_addr(15 downto 0);
    MEM_BANK_ID <= MEM_O_addr(31 downto 16);

    MEM_CS_BRAM_1 <= '1' when (MEM_BANK_ID = X"0000") else '0'; -- 0x0000ffff bank 64KB
    MEM_CS_BRAM_2 <= '1' when (MEM_BANK_ID = X"0001") else '0'; -- 0x0001ffff bank 64KB
    MEM_CS_BRAM_3 <= '1' when (MEM_BANK_ID = X"0002") else '0'; -- 0x0002ffff bank 64KB
    
    MEM_CS_DDR3 <= '1' when (MEM_BANK_ID(15 downto 12) = X"1") else '0'; -- 0x1******* ddr3 bank 256MB
    
    -- if any CS line is active, this is 1
    MEM_ANY_CS <= MEM_CS_BRAM_1 or MEM_CS_BRAM_2 or MEM_CS_BRAM_3;
    
    -- select the correct data to send to cpu
    MEM_I_data_raw <= INT_DATA when O_int_ack = '1'     
                  else MEM_DATA_OUT_BRAM_1 when MEM_CS_BRAM_1 = '1' 
                  else MEM_DATA_OUT_BRAM_2 when MEM_CS_BRAM_2 = '1' 
                  else MEM_DATA_OUT_BRAM_3 when MEM_CS_BRAM_3 = '1' 
                  else IO_DATA;
 
    MEM_I_data  <= ROM(to_integer(unsigned( MEM_64KB_ADDR(15 downto 2) )));

    core0: core PORT MAP (
        I_clk => cEng_core,
        I_reset => I_reset,
        I_halt => I_halt,
        I_int => I_int,
        O_int_ack => O_int_ack,
        I_int_data => I_int_data,
        MEM_I_ready => MEM_I_ready,
        MEM_O_cmd => MEM_O_cmd,
        MEM_O_we => MEM_O_we,
        MEM_O_byteEnable => MEM_O_byteEnable,
        MEM_O_addr => MEM_O_addr,
        MEM_O_data => MEM_O_data,
        MEM_I_data => MEM_I_data,
        MEM_I_dataReady => MEM_I_dataReady,
        O_DBG=>debug
    );
    
    
    -- Huge process which handles memory request arbitration at the Soc/Core clock 
    MEM_proc: process(cEng_core)
    begin
        if rising_edge(cEng_core) then
            if MEM_readyState = SOC_CtlState_Ready then
                if MEM_O_cmd = '1' then
                    MEM_I_ready <= '0';
                    MEM_I_dataReady  <= '0';
                    
                    if MEM_O_we = '1' then
                        -- DDR3 request, or immediate command?
                        MEM_readyState <= SOC_CtlState_IMM_WriteCmdComplete;
                    else
                        -- DDR3 request, or immediate command?
                        MEM_readyState <= SOC_CtlState_IMM_ReadCmdComplete; 
                    end if;
                    
                end if;
            elsif MEM_readyState >= 1 then
                 
                
                -- Immediate commands do not cross clock domains and complete immediately
                if MEM_readyState = SOC_CtlState_IMM_ReadCmdComplete then
                    MEM_I_ready <= '1';
                    MEM_I_dataReady <= '1'; 
                    MEM_readyState <= SOC_CtlState_Ready;  
                    
                elsif MEM_readyState = SOC_CtlState_IMM_WriteCmdComplete then
                    MEM_I_ready <= '1';
                    MEM_I_dataReady  <= '0'; 
                    MEM_readyState <= SOC_CtlState_Ready;
          
                end if;
            end if;
        end if;
    end process;
    
    AN <= ssegAnode;
    
    CA <= ssegCathode(0);
    CB <= ssegCathode(1);
    CC <= ssegCathode(2);
    CD <= ssegCathode(3);
    CE <= ssegCathode(4);
    CF <= ssegCathode(5);
    CG <= ssegCathode(6);
    DP <= ssegCathode(7);

    I_reset <= BTNC;


    scaler0: prescaler 
    GENERIC MAP (
        width => 25
    )
    PORT MAP(
        clk_in => clk100mhz,
        clk_out => cEng_core
    );
    
    
    p2: prescaler
    generic map(
        width => 15
    )
    port map(
        clk_in => clk100mhz,
        clk_out => ssegClk
    );
    
    sseg: ssegDriver
    port map(
        clk => ssegClk,
        rst => I_reset,
        cathode_p => ssegCathode,
        anode_p => ssegAnode,
        digit1_p => debug(3 downto 0),
        digit2_p => debug(7 downto 4),
        digit3_p => debug(11 downto 8),
        digit4_p => debug(15 downto 12),
        digit5_p => debug(19 downto 16),
        digit6_p => debug(23 downto 20),
        digit7_p => debug(27 downto 24),
        digit8_p => debug(31 downto 28)
    );


end Behavioral;
