----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.03.2025 14:43:17
-- Design Name: 
-- Module Name: modul_delay - Behavioral
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

entity modul_delay is
   generic (
            CLK_FREQ  : integer := 125_000_000
   );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           tx_start : out STD_LOGIC
           );
end modul_delay;

architecture Behavioral of modul_delay is
    constant PERIOD    : integer := CLK_FREQ; -- 1-second interval
    signal counter : integer := 0;
    signal send_flag : std_logic := '0';
begin
    tx_process : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                send_flag <= '0';
                tx_start <= '0';
            else
                if counter >= PERIOD then
                    counter <= 0;
                    send_flag <= '1';
                else
                    counter <= counter + 1;
                    send_flag <= '0';
                end if;

                if send_flag = '1' then
                    tx_start <= '1';
                    --wait for 10 ns;
                    --tx_start <= '0';
                    --tx_data <= tx_data + '1'; -- Kirim data yang meningkat
                else
                    tx_start <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
