library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Indispensable pour les calculs (unsigned)

entity Blinky is
	port(
		CLOCK_50: in STD_LOGIC;
		LEDG: out STD_LOGIC_VECTOR(3 downto 0)
	);
end Blinky;

architecture archBlinky of Blinky is
	-- Un compteur de 25 bits (2^25 / 50MHz = environ 0.6 seconde)
	signal counter : unsigned(29 downto 0) := (others => '0');
	
	-- Ces fils n'existent qu'à l'intérieur du FPGA (0 pin physique utilisée)
    signal s_op_a   : std_logic_vector(31 downto 0) := x"00000005"; -- On met 5
    signal s_op_b   : std_logic_vector(31 downto 0) := x"00000003"; -- On met 3
    signal s_res    : std_logic_vector(31 downto 0);
    signal s_alu_sel: std_logic_vector(3 downto 0)  := "0000"; -- Addition
begin	
	-- On "pose" l'ALU sur notre circuit
    ma_super_alu : entity work.ALU 
    port map (
        op_a    => s_op_a,    -- Le port 'op_a' de l'ALU est relié à notre signal 's_op_a'
        op_b    => s_op_b,
        alu_sel => s_alu_sel,
        res     => s_res,     -- Le résultat sort dans 's_res'
        zero    => open       -- 'open' signifie qu'on ne branche pas ce fil
    );

	process(CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
			counter <= counter + 1;
		end if;
	end process;
	
	-- On affiche les 4 bits de poids fort du compteur sur les LEDs
   -- (On convertit le type 'unsigned' en 'std_logic_vector')
   LEDG <= std_logic_vector(counter(29 downto 26));
end archBlinky;