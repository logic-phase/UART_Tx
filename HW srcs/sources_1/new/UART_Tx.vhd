----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2026 11:40:11 PM
-- Design Name: 
-- Module Name: UART_Tx - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_Tx is generic (
    DATA_WIDTH : integer := 8  
);
Port (
--input ports 

    Clk     :       in std_logic ; 
    nRst    :       in std_logic ; 
    Data    :       in std_logic_vector (DATA_WIDTH-1 downto 0) ; 
    
--output ports 
    Tx         :    out std_logic ;
    Data_ready :    out std_logic ; 
    Err  :          out std_logic 
 );
end UART_Tx;

architecture Behv of UART_Tx is
--FSM decleration 
type States is (IDLE , START , TRANSMIT , FINISH); 
signal CurrentState , NextState : States ;
--signal NextState : States ;
signal i : integer range 0 to 7 := 0 ; 
signal shift_reg : std_logic_vector( DATA_WIDTH-1 downto 0 ) ; 
--Clk and baud rate decleration 
constant Clk_Freq : integer := 50000000 ; 
constant BAUD_RATE : integer := 9600 ; 
constant BAUD_DIV  : integer := Clk_Freq / BAUD_RATE; 

signal baud_counter : integer range 0 to BAUD_DIV-1 := 0;

begin
update_state : process(clk)
begin
    if rising_edge(clk) then
        if nRst = '0' then
            CurrentState <= IDLE;
        else
            CurrentState <= NextState;          
        end if;
    end if;
end process;

Transition_state : process(Clk  , CurrentState , Data) begin 
    case CurrentState is 
        when IDLE =>
             Data_ready <= '0' ; 
             baud_counter <= 0 ; 
             NextState <= START ; 
             shift_reg <= (others => '0') ; 
             Err <= '0' ;
             Tx <= '0' ; 
             shift_reg <= (others => '0') ;
        when START => 
             if (baud_counter = BAUD_DIV/2) then 
                    NextState <= TRANSMIT ; 
                    Err <= '0' ; 
                    baud_counter <= 0 ; 
                    shift_reg <= Data ; 
                else 
                    baud_counter <= baud_counter + 1 ; 
             end if ; 
            
        when TRANSMIT =>
            if (baud_counter = BAUD_DIV) then 
                Tx <= shift_reg(i) ; 
                i <= i + 1 ;
                baud_counter <= 0 ;  
                    if (i = 7) then
                         NextState <= FINISH ; 
                         i <= 0 ; 
                    end if ; 
                else 
                    baud_counter <= baud_counter + 1 ; 
            end if ; 
             
        when FINISH => 
            Data_ready <= '1' ; 
            if (baud_counter = BAUD_DIV) then 
                NextState <= IDLE ; 
                baud_counter <= 0 ; 
            else 
                baud_counter <= baud_counter + 1 ; 
                Tx <= '1' ; 
            end if ; 
                
    end case ; 

end process ; 
    
     


end Behv;
