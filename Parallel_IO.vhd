
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Parallel_IO is
  Port (WR, RD, ACK, RESET, CE, A0: in std_logic;
        WR_out, RD_out, CE_out, ACK_out: out std_logic;
        D: in std_logic_vector(7 downto 0);
        D_out: out std_logic_vector(2 downto 0);
        P: out std_logic_vector(7 downto 0));
end Parallel_IO;

architecture Behavioral of Parallel_IO is

signal Y1, Y2 : std_logic;
signal CR0, CR1, SR0, SR1, SR2, INTE, OBF, INTR: std_logic;
signal D_reg: std_logic_vector(7 downto 0);
begin
    CE_out <= CE;
    WR_out <= WR;
    RD_out <= RD;
    ACK_out <= ACK; 
    process(RESET, CE, A0, INTE, INTR, OBF, WR, RD, D, CR0, CR1, SR0, SR1, SR2, D_reg)
    begin
        if RESET = '1' then
            CR0 <= '0';
            CR1 <= '0';
            SR0 <= '0';
            SR1 <= '0';
            SR2 <= '0';
            INTE <= '0';
        else
            
            if A0 = '1' and WR = '0' then
                CR0 <= D(0) and not(CE);
                CR1 <= D(1) and not(CE);
            else 
                CR0 <= CR0;
                CR1 <= CR1;
            end if;
            INTE <= (CR1) and not(CE);
            if CR0 <= '0' then
                SR0 <= '0';
                SR1 <= '0';
                SR2 <= '0';
                D_out <= "000";
                
            else
                
                if A0 = '1' and RD = '0' then
                    SR0 <= OBF and not(CE);
                    SR1 <= INTE and not(CE);
                    SR2 <= INTR and not(CE);
                else
                    SR0 <= SR0;
                    SR1 <= SR1;
                    SR2 <= SR2;
                end if;
                D_out(2) <= (SR2 and not(RD));
                D_out(1) <= (SR1 and not(RD));
                D_out(0) <= (SR0 and not(RD));
            end if;
            if WR = '0' and A0 = '0' and CE = '0' then
                D_reg <= D;
            else
                D_reg <= D_reg; 
            end if; 
            
            if WR = '1' then
                P <= D_reg;
            end if; 
        end if;
    end process;
     
    
        Y1 <= (((Y1 and Y2) or (not(WR) and Y1) or (not(ACK) and Y1) or(WR and ACK and Y2)) and CR0) and not(RESET);
        
        Y2 <= (((not(Y1) and Y2) or (ACK and Y2) or (not(WR) and Y2) or (not(WR) and ACK and not(Y1))) and CR0) and not(RESET);
        
        OBF <= (((not(Y2)) or (WR and not(ACK)) or (not(WR) and not(Y1)) or (not(ACK) and not(Y1))) or CE) or RESET;
        
        INTR <= ((((WR and not(Y1) and not(Y2)) or (WR and ACK and not(Y2)) or (not(ACK) and not(Y1) and not(Y2))) and INTE) and not(CE))
                     and not(RESET);
    
end Behavioral;
