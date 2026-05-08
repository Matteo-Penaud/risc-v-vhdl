library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.standard.BOOLEAN;

entity RegisterFile_tb is
    -- Entité vide pour un testbench
end RegisterFile_tb;

architecture sim of RegisterFile_tb is
    signal t_rst         : std_logic;
    signal t_clk         : std_logic;
    -- Port d'écriture
    signal t_w_addr      : std_logic_vector(4 downto 0); 
    signal t_w_data      : std_logic_vector(31 downto 0);
    signal t_w_enable    : std_logic;
    -- Ports de lecture
    signal t_rs1_addr    : std_logic_vector(4 downto 0);
    signal t_rs1_data    : std_logic_vector(31 downto 0);
    signal t_rs2_addr    : std_logic_vector(4 downto 0);
    signal t_rs2_data    : std_logic_vector(31 downto 0);

    signal sim_finie    : BOOLEAN;
begin
    UUT: entity work.RegisterFile
    port map (
        rst         => t_rst,
        clk         => t_clk,
        w_addr      => t_w_addr,
        w_data      => t_w_data,
        w_enable    => t_w_enable,
        rs1_addr    => t_rs1_addr,
        rs1_data    => t_rs1_data,
        rs2_addr    => t_rs2_addr,
        rs2_data    => t_rs2_data
    );

    -- Générateur d'horloge 50MHz
    clk_process : process
    begin
        while not sim_finie loop
            t_clk <= '0'; wait for 10 ns;
            t_clk <= '1'; wait for 10 ns;
        end loop;
        wait; -- Arrête l'horloge quand sim_finie est vrai
    end process;

    test_process: process
    begin
        t_rst <= '1';
        wait for 25 ns; -- On attend un peu plus d'un cycle
        t_rst <= '0';
        -- On attend le prochain front pour que l'écriture soit faite
        wait until rising_edge(t_clk);

        report "--- TESTS Write x0 ---";
        t_rs1_addr <= b"00000";
        t_w_addr <= b"00000";
        t_w_data <= x"FFFFFFFF";
        t_w_enable <= '1';
        wait until rising_edge(t_clk);
        t_w_enable <= '0';
        wait for 2 ns;
        assert (t_rs1_data = x"00000000") report "Erreur Write x0" severity error;

        report "--- TESTS Write x1 ---";
        t_rs1_addr <= b"00001";
        t_w_addr <= b"00001";
        t_w_data <= x"12345678";
        t_w_enable <= '1';
        wait until rising_edge(t_clk);
        t_w_enable <= '0';
        wait for 2 ns;
        assert (t_rs1_data = x"12345678") report "Erreur Write x1" severity error;

        report "--- TESTS Double read ---";
        t_rs1_addr <= b"00001";
        t_rs2_addr <= b"00010";
        t_w_addr <= b"00001";
        t_w_data <= x"CAFEDECA";
        t_w_enable <= '1';
        wait until rising_edge(t_clk);
        t_w_addr <= b"00010";
        t_w_data <= x"DEADBEEF";
        t_w_enable <= '1';
        wait until rising_edge(t_clk);
        t_w_enable <= '0';
        wait for 2 ns;
        assert (t_rs1_data = x"CAFEDECA") and (t_rs2_data = x"DEADBEEF") report "Erreur Double read" severity error;

        report "--- TESTS Write w_enable 0 ---";
        t_rs1_addr <= b"00011";
        t_w_addr <= b"00011";
        t_w_data <= x"DEADBEEF";
        t_w_enable <= '1';
        wait until rising_edge(t_clk);
        t_w_data <= x"CAFEDECA";
        t_w_enable <= '0';
        wait until rising_edge(t_clk);
        wait for 2 ns;
        assert (t_rs1_data = x"DEADBEEF") report "Erreur Write w_enable 0" severity error;

        report "--- TESTS R/W simultane ---";
        t_rs2_addr <= b"00011";
        t_w_addr <= b"00011";
        t_w_data <= x"7A7A7A7A";
        t_w_enable <= '1';
        assert (t_rs1_data = x"DEADBEEF") report "Erreur R/W simultane" severity error;
        wait until rising_edge(t_clk);
        t_w_enable <= '0';
        wait for 2 ns;

        report "--- TESTS Reset ---";
        t_rst <= '1';
        t_rs1_addr <= b"00010";
        t_rs2_addr <= b"00011";
        wait until rising_edge(t_clk);
        t_rst <= '0';
        assert (t_rs1_data = x"00000000") and (t_rs2_addr = x"00000000") report "Erreur Reset" severity error;
        wait until rising_edge(t_clk);

        report "--- TESTS TERMINES ---";
        sim_finie <= TRUE;
        wait;
    end process;
end sim;