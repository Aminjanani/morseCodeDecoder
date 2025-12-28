library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity morse is
    port(
        clk        : in std_logic;                    -- 100 MHz clock
        input      : in std_logic;                    -- Button input (active low/high)
        
        outleddot  : out std_logic;                   -- Lit during dot
        outleddas  : out std_logic;                   -- Lit during dash
        outledsep  : out std_logic;                   -- Lit when idle (separator)
		
		state_iden1: out std_logic;
		state_iden2: out std_logic;
        
		output     : out std_logic_vector(7 downto 0);-- ASCII/mapped output
		
		counter_o  : out integer
    );
end entity;

architecture Behavioral of morse is

    constant DOT_TIME    : integer := 20;  -- ~200 ns @ 100MHz
    constant DASH_TIME   : integer := 40;  -- ~400 ns
    constant IDLE_TIME   : integer := 80;  -- ~800 ns between characters

    type state_type is (IDLE, PRESSED, RELEASED, PROCESSING);
    signal state : state_type := IDLE;

    signal char_index       : integer range 0 to 7 := 7; 
	signal last_index       : integer range 0 to 7 := 7;

    signal char_pattern     : std_logic_vector(7 downto 0) := (others => '0');
    signal decoded_char     : std_logic_vector(7 downto 0) := "00000000";

    signal counter          : integer := 0;
    signal done_counter     : integer := 0;

    signal timer_done       : std_logic := '0';

    -- Morse code lookup table (A-Z, 0-9)
    type morse_rom is array (0 to 35) of std_logic_vector(7 downto 0);
    constant morse_lut : morse_rom := (
        "01------", -- A  .-	  0
        "1000----", -- B  -...	  1
        "1010----", -- C  -.-.	  2
        "100-----", -- D  -..	  3
        "0-------", -- E  .		  4
        "0010----", -- F  ..-.	  5
        "110-----", -- G  --.	  6
        "0000----", -- H  ....	  7
        "00------", -- I  ..	  8
        "0111----", -- J  .---	  9
        "101-----", -- K  -.-	  10
        "0100----", -- L  .-..	  11
        "11------", -- M  --	  12
        "10------", -- N  -.	  13
        "111-----", -- O  ---	  14
        "0110----", -- P  .--.	  15
        "1101----", -- Q  --.-	  16
        "010-----", -- R  .-.	  17
        "000-----", -- S  ...	  18
        "1-------", -- T  -		  19
        "001-----", -- U  ..-	  20
        "0001----", -- V  ...-	  21
        "011-----", -- W  .--	  22
        "1001----", -- X  -..-	  23
        "1011----", -- Y  -.--	  24
        "1100----", -- Z  --..	  25

        "11111---", -- 0 (-----)  26
    	"01111---", -- 1 (.----)  27
    	"00111---", -- 2 (..---)  28
    	"00011---", -- 3 (...--)  29
    	"00001---", -- 4 (....-)  30
    	"00000---", -- 5 (.....)  31
    	"10000---", -- 6 (-....)  32
    	"11000---", -- 7 (--...)  33
    	"11100---", -- 8 (---..)  34
    	"11110---"  -- 9 (----.)  35 
		
		-- "000000--", -- 'space' 	  36
		-- "000001--" -- 'reserved' 37
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if done_counter = IDLE_TIME then
                timer_done <= '1';
			elsif state = IDLE then
                done_counter <= done_counter + 1;
                timer_done <= '0';
            end if;
				
				
			if state /= IDLE or char_index = 7 then
               	done_counter <= 0;
			end if;
            
		end if;
	 end process;
	 
	 
	 process(clk) 
	 	variable complement_element : std_logic_vector(7 downto 0) := (others => '-');
	 begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    if input = '0' then -- button pressed
                        state <= PRESSED;
                        counter <= 0;
								
                    elsif timer_done = '1' and char_index /= 7 then
                        state <= PROCESSING;
                    end if;

                when PRESSED =>
                    counter <= counter + 1;
                    if input = '1' then -- button released
                        state <= RELEASED;
                    end if;

                when RELEASED =>
                    if counter >= DASH_TIME then
                        char_pattern(char_index) <= '1';
                        outleddas <= '1';
                        outleddot <= '0';
                        char_index <= char_index - 1;
								
                    elsif counter >= DOT_TIME then
                        char_pattern(char_index) <= '0';
                        outleddot <= '1';
                        outleddas <= '0';
                        char_index <= char_index - 1;
								
                    else
                        -- ignored (too short)
                        state <= IDLE;
                    end if;
                    
                    if char_index = 0 then
                        state <= PROCESSING;
                    else
                        state <= IDLE;
                        counter <= 0;
                    end if;

                when PROCESSING =>
                    decoded_char <= "11111111";
                    -- Match pattern
                    for i in 0 to 35 loop
                        if char_pattern(7 downto char_index + 1) & complement_element(char_index downto 0) = morse_lut(i) then
                            decoded_char <= std_logic_vector(to_unsigned(i, 8)); -- + to_unsigned(65,8)
                            exit;
                        end if;
                    end loop;
					output <= decoded_char;

                    char_index <= 7;
                    char_pattern <= (others => '0');
                    state <= IDLE;
                    
            end case;
        end if;
    end process;
	 
	 process (clk)
	 begin
		if    state = IDLE then
			state_iden1 <= '0';
			state_iden2 <= '0';

		elsif state = PRESSED then
			state_iden1 <= '1';
			state_iden2 <= '0';

		elsif state = RELEASED then
			state_iden1 <= '0';
			state_iden2 <= '1';

		elsif state = PROCESSING then
			state_iden1 <= '1';
			state_iden2 <= '1';

		end if;
	 end process;

	 outledsep <= not input;
	 counter_o <= counter;
end architecture;