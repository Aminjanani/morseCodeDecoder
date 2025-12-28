library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity morse_tb is
end morse_tb;

architecture TB_ARCHITECTURE of morse_tb is
    component morse
    port(
        clk : in STD_LOGIC;
        input : in STD_LOGIC;
        outleddot : out STD_LOGIC;
        outleddas : out STD_LOGIC;
        outledsep : out STD_LOGIC;
        state_iden1 : out STD_LOGIC;
        state_iden2 : out STD_LOGIC;
        output : out STD_LOGIC_VECTOR(7 downto 0);
		counter_o : out integer
    );
    end component;

    signal clk : STD_LOGIC;
    signal input : STD_LOGIC;
    signal outleddot : STD_LOGIC;
    signal outleddas : STD_LOGIC;
    signal outledsep : STD_LOGIC;
    signal state_iden1 : STD_LOGIC;
    signal state_iden2 : STD_LOGIC;
    signal output : STD_LOGIC_VECTOR(7 downto 0);
	signal counter_o : integer;

    -- Clock period definitions
    constant clk_period : time := 10 ns; -- 100 MHz clock

    -- Test timing constants
    constant DOT_TIME    : time := 250 ns; -- 25 cycles
    constant DASH_TIME   : time := 750 ns; -- 75 cycles
    constant IDLE_TIME   : time := 1 ms;   -- 100 cycles

    -- Test case tracking
    signal test_case_num : integer := 0;
    signal expected_output : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

    UUT : morse
        port map (
            clk => clk,
            input => input,
            outleddot => outleddot,
            outleddas => outleddas,
            outledsep => outledsep,
            state_iden1 => state_iden1,
            state_iden2 => state_iden2,
            output => output,
			counter_o => counter_o
        );

    -- Clock generation
    clock_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stimulus: process
        procedure press_button(duration: time) is
        begin
            input <= '0';
            wait for duration;
            input <= '1';
        end procedure;

        procedure send_dot is
        begin
            press_button(DOT_TIME);
            wait for DOT_TIME;
        end procedure;

        procedure send_dash is
        begin
            press_button(DASH_TIME);
            wait for DOT_TIME;              
        end procedure;

        procedure send_char(pattern: string; expected: std_logic_vector(7 downto 0)) is
        begin
            for i in pattern'range loop
                case pattern(i) is
                    when '.' => send_dot;
                    when '-' => send_dash;
                    when others => null;
                end case;
            end loop;
            expected_output <= expected;
            wait for IDLE_TIME - DOT_TIME;
        end procedure;
    begin
        -- Initialize
        input <= '1';
        wait for 100 ns;

        -- Test case 1: A (.-)
        test_case_num <= 1;
        send_char(".-", "00000000"); 	-- 0
        wait for 100 ns;

        -- Test case 2: B (-...)
        test_case_num <= 2;
        send_char("-...", "00000001");	-- 1
        wait for 100 ns;

        -- Test case 3: S (...)
        test_case_num <= 3;
        send_char("...", "00010010");	-- 12
        wait for 100 ns;

        -- Test case 4: 3 (...--)
        test_case_num <= 4;
        send_char("...--", "00011101");	-- 1D 
        wait for 100 ns;

        -- Test case 5: Invalid short press
        test_case_num <= 5;
        press_button(100 ns);
        expected_output <= "11111111";	-- FF
        wait for 100 ns;

        -- Test case 6: Partial character timeout
        test_case_num <= 6;
        send_dot;
        expected_output <= "11111111";	-- FF
        wait for IDLE_TIME * 2;
        wait for 100 ns;

        -- Test case 7: SOS sequence
        test_case_num <= 7;
        send_char("...", "00010010"); -- S
        send_char("---", "00001110"); -- O
        send_char("...", "00010010"); -- S
        wait for 100 ns;

        -- End simulation
        test_case_num <= 0;
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_morse of morse_tb is
    for TB_ARCHITECTURE
        for UUT : morse
            use entity work.morse(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_morse;