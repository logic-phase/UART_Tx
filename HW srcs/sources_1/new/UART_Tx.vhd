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
    Err  :          out std_logic ; 
    Last_bit :      out std_logic 
 );
end UART_Tx;

architecture Behv of UART_Tx is
--FSM decleration 
type States is (IDLE , START , TRANSMIT , FINISH); 
signal CurrentState , NextState : States ;
--signal NextState : States ;
signal i : integer range 0 to DATA_WIDTH-1 := 0 ; 
signal shift_reg : std_logic_vector( DATA_WIDTH-1 downto 0 ) ; 
signal Last_bit_int : std_logic ; 
signal FirstBit_Transition : std_logic ;
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

Transition_state : process(Clk , nRst , FirstBit_Transition , Data) begin 
if (rising_edge(Clk) or rising_edge(FirstBit_Transition)) then 
    case CurrentState is 
        when IDLE =>
             Data_ready <= '0' ; 
             baud_counter <= 0 ; 
             NextState <= START ; 
             shift_reg <= (others => '0') ; 
             Err <= '0' ;
             Tx <= '0' ;
             Last_bit_int <= '0' ;  
             i <= 0 ; 
             FirstBit_Transition <= '0' ;
        when START => 
             if (baud_counter = BAUD_DIV/2) then 
                    NextState <= TRANSMIT ; 
                    shift_reg <= Data ;
                    Err <= '0' ; 
                    baud_counter <= 0 ;
                    FirstBit_Transition <= '1' ;                    
                else 
                    baud_counter <= baud_counter + 1 ; 
             end if ; 
            
        when TRANSMIT =>
        Data_ready <= '1' ;
        if (FirstBit_Transition = '1' ) then --send 1st bit at the begining and then send another bits 
            Tx <= shift_reg(i) ; 
            FirstBit_Transition <= '0' ;
        end if ; 
        ----------------------------------------------------
        --if (shift_reg /= Data)then
        --    Err <= '1' ;
        --    if (Last_bit_int = '1') then
        --        NextState <= IDLE ; 
        --    end if ;  
        --end if ;
        -----------------------------------------------------
         
            if (baud_counter = (BAUD_DIV)+2) then
                baud_counter <= 0 ; 
                    if ((i < DATA_WIDTH-1)) then 
                        i <= i + 1 ;
                        Tx <= shift_reg(i+1) ;
                    else
                        i <= 0 ;
                        NextState <= FINISH ; 
                    end if ;
                else 
                    baud_counter <= baud_counter + 1 ;         
            end if ;
             
        when FINISH => 
            Last_bit_int <= '0' ; 
            --Data_ready <= '1' ; 
            if (baud_counter = (BAUD_DIV/2)) then --fix the issue of one timing clusure of Clk in Tx Module  (1 Clk ahead)
                NextState <= IDLE ; 
                baud_counter <= 0 ; 
            else 
                baud_counter <= baud_counter + 1 ; 
                Tx <= '1' ;   -- stop bit 
            end if ; 
            
    end case ;
end if ;   
Last_bit <= Last_bit_int ; 

end process ; 

end Behv;
