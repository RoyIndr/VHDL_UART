library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_top is
    generic (
        clk_FREQ    : integer := 125_000_000  
        --BAUD_RATE   : integer := 115200        
    );
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        rx_input    : in STD_LOGIC;
        --tx_data     : std_logic_vector(7 downto 0) := (others => '0');
        tx_output   : out STD_LOGIC;
        rx_done     : out STD_LOGIC
        
        --tx_ready : out STD_LOGIC
    );
end uart_top;

architecture Behavioral of uart_top is
    --constant CLK_FREQ  : integer := 100_000_000;
    constant BAUD_RATE : integer := 115200;
    
    --signal clk         : std_logic := '0';
    --signal reset         : std_logic := '1';
    signal tx_start    : std_logic := '0';
    signal tx_data     : std_logic_vector(7 downto 0) := "01010011"; --Binary S
    signal rx_data     : std_logic_vector(7 downto 0);
    signal tx_line  : std_logic;
    
    signal rx_line_internal  : STD_LOGIC;
    signal tx_start_internal : STD_LOGIC;
    signal tx_ready_internal : STD_LOGIC;
    signal rx_ready_internal : STD_LOGIC;
    --signal tx_output : STD_LOGIC;
    --signal rx_input           : std_logic;
    
    component uart_tx
        generic (
            clk_FREQ  : integer := CLK_FREQ;
            BAUD_RATE : integer := BAUD_RATE
        );
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        tx_start : in  STD_LOGIC;
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);
        tx_line  : out STD_LOGIC
        --tx_ready : out STD_LOGIC
    );
    end component;
    
    component uart_rx
        generic (
            clk_FREQ  : integer := CLK_FREQ;
            BAUD_RATE : integer := BAUD_RATE
        );
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        rx_line  : in  STD_LOGIC;
        rx_data  : out STD_LOGIC_VECTOR(7 downto 0);
        rx_done  : out STD_LOGIC
        --rx_ready : out STD_LOGIC
    );
    end component;
    
    component modul_delay
        generic (
            clk_FREQ    : INTEGER := CLK_FREQ
        );
        
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            tx_start : out STD_LOGIC
           );
    end component;
    
begin
    -- Clock process
   --clk_process : process
    --begin
        --wait for 5 ns;
        --clk <= not clk;
    --end process;

    -- Instansiasi modul Receiver
    UART_RX_INST: uart_rx
        generic map (
            clk_FREQ  => CLK_FREQ,
            BAUD_RATE => BAUD_RATE
        )
    port map(
        clk      => clk,
        reset    => reset,
        --rx_line  => rx_input,
        rx_line => rx_input,
        rx_data  => rx_data,
        rx_done  => rx_done
        --rx_ready => rx_ready_internal
    );
    
    -- Instansiasi modul Transmitter
    UART_TX_INST: uart_tx
        generic map (
            clk_FREQ  => CLK_FREQ,
            BAUD_RATE => BAUD_RATE
        )
    port map(
        clk      => clk,
        reset    => reset,
        tx_start => tx_start,
        tx_data  => tx_data,
        --tx_line  => tx_output
        tx_line => tx_output
        --tx_ready => tx_ready_internal
    );
    
    --Instansiasi modul delay
    MODULE_DELAY: modul_delay
        generic map (
            clk_FREQ => CLK_FREQ
        )
        
        port map (
            clk => clk,
            reset => reset,
            tx_start => tx_start
        );
    
    --rx_ready <= rx_ready_internal;
    --tx_ready <= tx_ready_internal;
    -- Test process
    --process
    --begin
        -- Reset sequence
        --reset <= '1';
        --wait for 100 ns;
        --reset <= '0';
        
        -- Send a byte
        --tx_data <= "10101010"; -- Example data: 0xAA
        --tx_start <= '1';
        --wait for 10 ns;
        --tx_start <= '0';

        -- Wait for transmission to complete
        --wait for 1 ms;
        
        -- Check received data
        --assert rx_data = tx_data report "Mismatch between TX and RX data" severity error;

        -- End simulation
        --wait;
    --end process;
end Behavioral;