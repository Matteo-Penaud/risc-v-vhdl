library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterFile is
    port(
        rst         : in  std_logic;
        clk         : in  std_logic;
        -- Port d'écriture
        w_addr      : in  std_logic_vector(4 downto 0); 
        w_data      : in  std_logic_vector(31 downto 0);
        w_enable    : in  std_logic;
        -- Ports de lecture
        rs1_addr    : in  std_logic_vector(4 downto 0);
        rs1_data    : out std_logic_vector(31 downto 0);
        rs2_addr    : in  std_logic_vector(4 downto 0);
        rs2_data    : out std_logic_vector(31 downto 0)
    );
end RegisterFile;

architecture archRegisterFile of RegisterFile is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal registers : reg_array;
begin
    
    write_process: process(clk) -- Process synchrone pour l'écriture
    begin
        if rising_edge(clk) then -- INDISPENSABLE pour du séquentiel
            if rst = '1' then 
                registers <= (others => (others => '0')); -- Reset à 0 au démarrage
            elsif (w_enable = '1' and w_addr /= "00000") then
                registers(to_integer(unsigned(w_addr))) <= w_data;
            end if;
        end if;
    end process;
    
    -- Cette syntaxe n'est valide que en dehors d'un process
    rs1_data <= x"00000000" when rs1_addr = "00000" else registers(to_integer(unsigned(rs1_addr)));
    rs2_data <= x"00000000" when rs2_addr = "00000" else registers(to_integer(unsigned(rs2_addr)));
end archRegisterFile;