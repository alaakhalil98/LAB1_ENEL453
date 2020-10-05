--Binary to BCD code


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY binary_bcd IS

   PORT(
      clk      :  IN    STD_LOGIC;                                
      reset_n  :  IN    STD_LOGIC;                                
      binary   :  IN    STD_LOGIC_VECTOR(12 DOWNTO 0);         
      bcd      :  OUT   STD_LOGIC_VECTOR(15 DOWNTO 0));  
END binary_bcd;

ARCHITECTURE behavior OF binary_bcd IS
type statetype is (S0,S1,S2,S3,S4,S5,s6);
signal CurentState: statetype:=S0;
Signal   counter  : integer:=0;
Signal   bcd_signal : unsigned(28 DOWNTO 0):=(others=>'0');    -- 28 _ _ 25    24 _ _ 21    20 _ _ 17    16 _ _ 13    12 _ _ _ _ _ _ _ _ _ _ _ 0 
Constant add3_0digit: unsigned(28 DOWNTO 0):="00000000000000110000000000000";
Constant add3_1digit: unsigned(28 DOWNTO 0):="00000000001100000000000000000";
Constant add3_2digit: unsigned(28 DOWNTO 0):="00000011000000000000000000000";
Constant add3_3digit: unsigned(28 DOWNTO 0):="00110000000000000000000000000";

begin
bcd_process: process (reset_n, clk)
variable NextState: statetype;
begin
      if (reset_n='0') then -- note, active-low reset
         bcd<= (others=>'0');
         bcd_signal<=(others=>'0');
         counter<=0;
      elsif (rising_edge(clk)) then
               Case CurentState is
                  when S0 =>
                              bcd_signal(12 DOWNTO 0)<=UNSIGNED(binary);                             
                              NextState:=S1;                            
                  when S1 => 
                              if (bcd_signal(28 downto 25) >4) then
                                 bcd_signal <= bcd_signal+ add3_3digit;
                              end if;
                              NextState:=S2;
                  when S2 => 
                              if (bcd_signal(24 downto 21) >4) then
                                 bcd_signal <=bcd_signal+ add3_2digit;
                              end if;
                              NextState:=S3;                   
                  when S3 => 
                              if (bcd_signal(20 downto 17) >4) then
                                 bcd_signal <= bcd_signal+ add3_1digit;
                              end if;
                              NextState:=S4;
                  when S4 => 
                              if (bcd_signal(16 downto 13) >4) then
                                 bcd_signal <= bcd_signal+ add3_0digit;
                              end if;
                              NextState:=S5;
                  when S5 => 
                              bcd_signal<=shift_left(unsigned(bcd_signal), 1);
                              NextState:=S6;
                  when S6 =>
                              If (counter=12) then
                                 bcd<=std_logic_vector(bcd_signal(28 downto 13));
                                 bcd_signal<=(others=>'0');
                                 counter<=0;
                                 NextState:=S0;
                              else
                                 counter<=counter+1;
                                 NextState:=S1;
                              end if;

                  When others => 
                              NextState:=S0;
                              counter<=0;
                              bcd_signal<=(others=>'0');
               End Case;
               CurentState<=NextState;
       end if;
end process;
   

end behavior;