----------------------------------------------------------------------------------
-- Company: 	Institut Teccart	
-- Engineer: 	Alain Royal
-- 
-- Create Date:    05/12/2018 
-- Design Name: 	 Drive 3 phases
-- Module Name:    D3phases - Behavioral 
-- Project Name: 		drive moteur 3 phase CC
-- Target Devices: 	xc6slx9 3.3V
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--     FPGA_1_0.ucf
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use  IEEE.std_logic_arith.all;
use  IEEE.std_logic_unsigned.all;

entity PWM3phases is  
	generic (DIV_CLK: integer := 600;	-- 60 MHz/DIV_CLK    10 KHz 
				PWMmax:  integer:= 255
				);
  port (CLK: in STD_LOGIC;					-- Gestion d'horloge
		  EN_CLK: out std_logic;
		  CLKout: out std_logic;
												-- entrees
		  PWM: in STD_LOGIC_VECTOR (7 DOWNTO 0):="11111111";
												-- sortie TESTs
		 -- TEST1: out std_logic;
		 -- TEST2: out std_logic;
		 -- TEST3: out std_logic;		  
													-- Sortie
		   AH: out std_logic;	
		   BH: out std_logic;	
		   CH: out std_logic;
			
		   AL: out std_logic;
		   BL: out std_logic;			
		   CL: out std_logic				
	);	  
end PWM3phases;

architecture arch_PWM3phases of PWM3phases is
signal cnt_clk :  integer range 0 to DIV_CLK-1;
signal sCLK : 		std_logic;
signal PWMout: 	    std_logic:='1';

type Sreg0_type is (S1, S2, S3, S4, S5, S6);   -- step 1 @ 6   3 phases
signal Sreg0: 			Sreg0_type:= S1;
signal Sreg0_next:   Sreg0_type;

signal cptPWM: 		   INTEGER range 0 to PWMmax-1:=0;
--signal cptPWM_next:     INTEGER range 0 to PWMmax-1:=0;


begin
		clk_proc: process (CLK)
		begin
	
				if CLK'event and CLK = '1' then
						if cnt_clk >= DIV_CLK-1 then
							cnt_clk <= 0; 
						--sCLK <= not sCLK;					-- CLK/2
						--cptPWM <= cptPWM_next;
							if cptPWM >= PWMmax-1 then		 -- PWM clk
								cptPWM <= 0;
								Sreg0 <= Sreg0_next;			-- PWMout clk
								sCLK <= not sCLK;		
							else
							   cptPWM <= cptPWM +1;
							end if;	
						else
							cnt_clk <= cnt_clk +1;
						end if;					


				end if;
		end process;

Sreg0_machine: process (Sreg0, cptPWM, PWM, PWMout)
begin
				Sreg0_next <= Sreg0 ;
				cptPWM_next <= cptPWM;
				                     					--TEST1 <='1';
							--TEST2 <='1';
							
								if cptPWM <= PWM then 
									PWMout <='1';
								else
									PWMout <='0';
								end if;
	case Sreg0 is
		when S1 =>													-- AB
					   AH <= '1';--PWMout; 
					   AL <= '0';
					   BH <= '0'; 
					   BL <= '1'; 
					   CH <= '0'; 
					   CL <= '0'; 						
					Sreg0_next <= S2;
		when S2 =>													-- AC
					   AH <= '1';--; 
					   AL <= '0';
					   BH <= '0'; 
					   BL <= '0'; 
					   CH <= '0'; 
					   CL <= '1'; 										 
					Sreg0_next <= S3;
		when S3=>													-- BC
					   AH <= '0'; 
					   AL <= '0';
					   BH <= '1';--; 
					   BL <= '0'; 
					   CH <= '0'; 
					   CL <= '1'; 
					Sreg0_next <= S4;
		when S4 =>													-- BA
					   AH <= '0'; 
					   AL <= '1';
					   BH <= '1';--; 
					   BL <= '0'; 
					   CH <= '0'; 
					   CL <= '0'; 
					Sreg0_next <= S5;
		when S5 =>													-- CA
					   AH <= '0'; 
					   AL <= '1';
					   BH <= '0'; 
					   BL <= '0'; 
					   CH <= '1';--PWMout; 
					   CL <= '0'; 
					Sreg0_next <= S6;
		when S6 =>													-- CB
					   AH <= '0'; 
					   AL <= '0';
					   BH <= '0'; 
					   BL <= '1'; 
					   CH <= '1';--PWMout; 
					   CL <= '0'; 
					Sreg0_next <= S1;
		when others =>									--NO moteur
					  null;
	end case;

end process;

---------------------------------------------------- OUT ---------
CLKout <= sCLK;
EN_CLK <= '1';


-----------------------------------------------------TESTs---------
--TEST3 <= RX;

end arch_PWM3phases;

