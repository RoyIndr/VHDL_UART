library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (
        clk_FREQ  : integer := 125_000_000;  
        BAUD_RATE   : integer := 115200        
    );
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        rx_line  : in  STD_LOGIC;
        rx_data  : out STD_LOGIC_VECTOR(7 downto 0);
        rx_done  : out STD_LOGIC := '0'
        --rx_ready : out STD_LOGIC
    );
end uart_rx;

architecture Behavioral of uart_rx is
    constant BAUD16_DIVISOR : INTEGER := clk_FREQ / ( BAUD_RATE * 16 );
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_type := IDLE;
    
    signal BAUD16_COUNT  : integer range 0 to BAUD16_DIVISOR-1 := 0; 
    signal BAUD16_TICK   : STD_LOGIC := '0';
    
    --signal sync_reg      : STD_LOGIC_VECTOR(1 downto 0) := "11";
    signal sample_count     : integer range 0 to 15 := 0;
    signal bit_counter      : integer range 0 to 7 := 0;
    signal data_reg         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal parity_bit       : std_logic := '0';
    signal samples          : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal count_ones       : integer range 0 to 16 := 0;
    signal count_zeros      : integer range 0 to 16 := 0;
    --signal baud_counter  : integer range 0 to BAUD_COUNT-1 := 0;
begin


--process(clk)
--begin
    --if rising_edge(clk) then
        --sync_reg <= sync_reg(0) & rx_line;
    --end if;
--end process;

baud_generator : process (clk) 
begin
    if rising_edge(clk) then
        if reset = '1' or state = IDLE then
            BAUD16_COUNT <= 0;
            BAUD16_TICK <= '0';
        elsif BAUD16_COUNT = BAUD16_DIVISOR-1 then
            BAUD16_COUNT <= 0;
            BAUD16_TICK <= '1';
        else 
            BAUD16_COUNT <= BAUD16_COUNT + 1;
            BAUD16_TICK <= '0';
        end if;
    end if;
end process;


fsm : process(clk, reset)
begin
    if reset = '1' then
        state <= IDLE;
        samples <= (others => '0');
        --rx_ready <= '0';
        data_reg <= (others => '0');
        bit_counter <= 0;
        sample_count <= 0;
        rx_done <= '0';
    elsif rising_edge(clk) then
        --rx_ready <= '1';
        
        case state is
            when IDLE =>
                if rx_line = '0' then 
                    state <= START_BIT;
                    sample_count <= 0;
                    rx_done <= '0';
                end if;
                
            when START_BIT =>
                if BAUD16_TICK  = '1' then
                    
                    --samples <= samples(14 downto 0) & rx_line;
                    if sample_count = 0 then
                        count_ones <= 0;
                        count_zeros <= 0;
                    elsif sample_count < 8 then
                        if rx_line = '1' then
                            count_ones <= count_ones + 1;
                        else
                            count_zeros <= count_zeros + 1;
                        end if;
                    end if;
                    
                    if sample_count = 15 then
                        if count_zeros > count_ones then
                            state <= DATA_BITS;
                            bit_counter <= 0;
                        else
                            state <= IDLE;
                        end if;
                        
                        sample_count <= 0;
                    else
                        sample_count <= sample_count + 1;
                    end if;
                end if;
                
            when DATA_BITS =>
                if BAUD16_TICK = '1' then
                
                    if rx_line = '1' then
                        count_ones <= count_ones + 1;
                    else
                        count_zeros <= count_zeros + 1;
                    end if;
                    
                    if sample_count = 15 then
                        if count_ones > count_zeros then
                            data_reg(bit_counter) <= '1';
                        else 
                            data_reg(bit_counter) <= '0';
                        end if;
                        
                        sample_count<= 0;
                        count_ones <= 0;
                        count_zeros <= 0;
                        
                        if bit_counter = 7 then   
                            state <= STOP_BIT;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;
                    else
                        sample_count <= sample_count + 1;
                    end if;
                end if;
                
            when STOP_BIT =>
                if BAUD16_TICK = '1' then
                    if rx_line = '1' then -- Validasi stop bit
                        count_ones <= count_ones + 1;
                    else
                        count_zeros <= count_zeros + 1;
                        --rx_ready <= '1';
                    end if;
                    
                    if sample_count = 15 then
                        
                        if count_ones > count_zeros then
                            rx_data <= data_reg;
                            rx_done <= '1';
                            --state <= IDLE;
                        else 
                            state <= IDLE;
                        end if;
                        
                    else
                        sample_count <= sample_count + 1;
                    end if;
                end if;
             end case;
    end if;
end process;

end Behavioral;