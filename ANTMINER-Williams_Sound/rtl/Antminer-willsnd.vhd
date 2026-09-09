---------------------------------------------------------------------------------
--                      Williams Sound Board - ANTMINER S9
--                            Code from DarFPGA
--
--                         Modified for ANTMINER S9 
--                             by pinballwiz
--                               07/09/2026
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity willsnd_antminer is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
   	ps2_clk     : inout std_logic;
	ps2_dat     : inout std_logic;
	led         : out std_logic_vector(7 downto 0);
	aled        : out std_logic_vector(3 downto 0)
);
end willsnd_antminer;
------------------------------------------------------------------------------
architecture struct of willsnd_antminer is
 
 signal	clock_48    : std_logic;
 signal	clock_24    : std_logic;
 signal	clock_12    : std_logic;
 --
 signal snd_sel		: std_logic_vector(5 downto 0); 
 signal codeready	: std_logic;
 signal scancode	: std_logic_vector(9 downto 0);
 --
 signal audio_pwm   : std_logic;
 signal speech_pwm  : std_logic;
 signal audio       : std_logic_vector(7 downto 0);
 signal speech      : std_logic_vector(15 downto 0);
 --
 signal rom_addr    : std_logic_vector(13 downto 0);
 signal rom_do      : std_logic_vector(7 downto 0);
 signal spch_do     : std_logic_vector(7 downto 0);
 --
 signal reset       : std_logic;
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
component willsnd_clocks
port(
  clk_out1          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
---------------------------------------------------------------------------
begin

 reset <= not I_RESET;
 aled(3 downto 0) <= "1111"; -- turn unused onboard leds off
---------------------------------------------------------------------------
Clocks: willsnd_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_48
    );
---------------------------------------------------------------------------
-- Clocks Divide

process (clock_48)
begin
 if rising_edge(clock_48) then
	clock_24  <= not clock_24;
 end if;
end process;
--
process (clock_24)
begin
 if rising_edge(clock_24) then
	clock_12  <= not clock_12;
 end if;
end process;
---------------------------------------------------------------------------
-- Main

Core: entity work.williams_sound_board
port map(
	clock          => clock_12,
	reset          => reset,
	select_sound   => snd_sel,
	speech_out     => speech,
	audio_out      => audio,
	rom_addr       => rom_addr,
	rom_do         => rom_do,
	spch_do        => spch_do,
	AD             => AD
	);
---------------------------------------------------------------------------
-- Roms

SND_ROM: entity work.SND_ROM
port map(
	addr => rom_addr(10 downto 0),
	clk	 => clock_12,
	data => rom_do
	);
--

SPCH_ROM: entity work.SPCH_ROM
port map(
	addr => rom_addr(13 downto 0),
	clk	 => clock_12,
	data => spch_do
	);
-------------------------------------------------------------------------------
-- Keyboard

keyboard: entity work.Keyboard
port map(
		Reset     => reset,
		Clock     => clock_12,
		PS2Clock  => ps2_clk,
		PS2Data   => ps2_dat,
		CodeReady => codeready,
		ScanCode  => scancode
		);		
----------------------------------------------------------------------------
-- Input

inputreg: process
begin
	wait until rising_edge(clock_12);
		if scanCode(8) = '1' then
			snd_sel(5 downto 0) <= scanCode(5 downto 0);
		else
			snd_sel(5 downto 0) <= "111111";
		end if;
end process;
------------------------------------------------------------------------------
-- audio dac

    audio_dac : entity work.dac
    generic map(
      msbi_g  => 7
    )
    port  map(
      clk_i   => clock_12,
      res_n_i => I_RESET,
      dac_i   => audio,
      dac_o   => audio_pwm
    );

    O_AUDIO_L <= audio_pwm;
--    O_AUDIO_R <= audio_pwm;
------------------------------------------------------------------------------
-- speech dac

    speech_dac : entity work.dac
    generic map(
      msbi_g  => 15
    )
    port  map(
      clk_i   => clock_12,
      res_n_i => I_RESET,
      dac_i   => speech,
      dac_o   => speech_pwm
    );

--    O_AUDIO_L <= audio_pwm;
    O_AUDIO_R <= speech_pwm;
------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(14 downto 7);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;	
----------------------------------------------------------------------------
end struct;