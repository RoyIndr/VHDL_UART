library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    generic (
        clk_FREQ    : integer := 125_000_000;  
        BAUD_RATE   : integer := 115200        
    );
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        tx_start : in  STD_LOGIC;
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);
        tx_line  : out STD_LOGIC
        --tx_ready : out STD_LOGIC
    );
end uart_tx;

architecture Behavioral of uart_tx is
    constant BAUD_DIVISOR : INTEGER := clk_FREQ / BAUD_RATE;
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_type := IDLE;
    
    signal baud_tick : std_logic := '0';
    signal tx_line_internal : STD_LOGIC;
    signal BAUD_COUNT : integer range 0 to BAUD_DIVISOR - 1 := 0; 
    --signal baud_counter : integer range 0 to BAUD_COUNT - 1 := 0;
    signal bit_counter : integer range 0 to 7 := 0;
    signal data_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin

    tx_line <= tx_line_internal;
    -- Baud rate generator
    p_baud_generator : process(clk, reset)
    begin
        if reset = '1' then
            BAUD_COUNT <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if state /= IDLE then
                if BAUD_COUNT = BAUD_DIVISOR-1 then
                    BAUD_COUNT <= 0;
                    baud_tick <= '1';
                else
                    BAUD_COUNT <= BAUD_COUNT + 1;
                    baud_tick <= '0';
                end if;
            else
                BAUD_COUNT <= 0;
                baud_tick <= '0';
            end if;
        end if;
    end process;

-- TX FSM
p_fsm : process(clk, reset)
begin
    if reset = '1' then
        state <= IDLE;
        tx_line_internal <= '1';
        --tx_ready <= '1';
        --baud_counter <= 0;
        bit_counter <= 0;
        data_reg <= (others => '0');
    elsif rising_edge(clk) then
        case state is
            when IDLE =>
                tx_line_internal <= '1';
                bit_counter <= 0;
                --tx_ready <= '1';
                if tx_start = '1' then
                    data_reg <= tx_data;
                    --tx_ready <= '0';
                    state <= START_BIT;
                    
                end if;
                
            when START_BIT =>
                tx_line_internal <= '0';
                --if baud_counter = BAUD_COUNT-1 then
                if baud_tick = '1' then
                    state <= DATA_BITS;
                    bit_counter <= 0;
                --else
                    --baud_counter <= baud_counter + 1;
                end if;
                
            when DATA_BITS =>
                tx_line_internal <= data_reg(bit_counter);
                if baud_tick = '1' then
                    if bit_counter = 7 then
                        state <= STOP_BIT;
                        --bit_counter <= 0;
                    else
                        bit_counter <= bit_counter + 1;
                    end if;
                --else
                    --baud_counter <= baud_counter + 1;
                end if;
                
            when STOP_BIT =>
                tx_line_internal <= '1';
                if baud_tick = '1' then
                    state <= IDLE;
                    --baud_counter <= 0;
                    --tx_ready <= '1';
                --else
                    --baud_counter <= baud_counter + 1;
                end if;
        end case;
    end if;
end process;

end Behavioral;