library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
    -- Entité vide pour un testbench
end alu_tb;

architecture sim of alu_tb is
    -- 1. Signaux de connexion (on les initialise à 0)
    signal t_op_a    : std_logic_vector(31 downto 0) := (others => '0');
    signal t_op_b    : std_logic_vector(31 downto 0) := (others => '0');
    signal t_alu_sel : std_logic_vector(3 downto 0)  := (others => '0');
    signal t_res     : std_logic_vector(31 downto 0);
    signal t_zero    : std_logic;

begin

    -- 2. On branche l'ALU réelle sur nos signaux de test
    UUT: entity work.ALU
    port map (
        op_a    => t_op_a,
        op_b    => t_op_b,
        alu_sel => t_alu_sel,
        res     => t_res,
        zero    => t_zero
    );

    -- 3. Le scénario de test (Processus de stimulus)
    process
    begin
        -- Test ADD
        report "--- TESTS ADD ---";

        -- Cas 1+1
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "0000"; -- ADD
        wait for 10 ns; -- Le wait permet d'attendre pour mettre a jour les signaux
        assert (t_res = x"00000002") report "Erreur ADD: 1+1" severity error;

        -- Cas 0+1
        t_op_a <= x"00000000";
        t_op_b <= x"00000001";
        t_alu_sel <= "0000"; -- ADD
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur ADD: 0+1" severity error;

        -- Cas 0xFFFFFFFF + 1
        t_op_a <= x"FFFFFFFF";
        t_op_b <= x"00000002";
        t_alu_sel <= "0000"; -- ADD
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur ADD: FFFFFFFF+2" severity error;

        -- Test SUB
        report "--- TESTS SUB ---";

        -- Cas A - 4
        t_op_a <= x"0000000A";
        t_op_b <= x"00000004";
        t_alu_sel <= "1000"; -- SUB
        wait for 10 ns;
        assert (t_res = x"00000006") report "Erreur SUB: 0xA - 4" severity error;

        -- Cas 1 - 1
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "1000"; -- SUB
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SUB: 1 - 1" severity error;

        -- Cas 1 - 1
        t_op_a <= x"00000000";
        t_op_b <= x"00000010";
        t_alu_sel <= "1000"; -- SUB
        wait for 10 ns;
        assert (t_res = x"FFFFFFF0") report "Erreur SUB: 0 - 0x10" severity error;

        -- Test AND
        report "--- TESTS AND ---";

        -- Cas 1 and 1
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "0111"; -- AND
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur AND: 1 and 1" severity error;

        -- Cas 1 and 2
        t_op_a <= x"00000001";
        t_op_b <= x"00000002";
        t_alu_sel <= "0111"; -- AND
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur AND: 1 and 2" severity error;

        -- Cas 1 and 2
        t_op_a <= x"CAFEDECA";
        t_op_b <= x"DEADBEEF";
        t_alu_sel <= "0111"; -- AND
        wait for 10 ns;
        assert (t_res = x"CAAC9ECA") report "Erreur AND: CAFEDECA and DEADBEEF" severity error;

        -- Test OR
        report "--- TESTS OR ---";

        -- Cas 1 or 1
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "0110"; -- OR
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur OR: 1 or 1" severity error;

        -- Cas 1 or 2
        t_op_a <= x"00000001";
        t_op_b <= x"00000002";
        t_alu_sel <= "0110"; -- OR
        wait for 10 ns;
        assert (t_res = x"00000003") report "Erreur OR: 1 or 2" severity error;

        -- Cas 1 or 2
        t_op_a <= x"CAFEDECA";
        t_op_b <= x"DEADBEEF";
        t_alu_sel <= "0110"; -- OR
        wait for 10 ns;
        assert (t_res = x"DEFFFEEF") report "Erreur OR: CAFEDECA or DEADBEEF" severity error;

        -- Test XOR
        report "--- TESTS XOR ---";

        -- Cas 1 xor 1
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "0100"; -- XOR
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur XOR: 1 xor 1" severity error;

        -- Cas 1 xor 2
        t_op_a <= x"00000001";
        t_op_b <= x"00000002";
        t_alu_sel <= "0100"; -- XOR
        wait for 10 ns;
        assert (t_res = x"00000003") report "Erreur XOR: 1 xor 2" severity error;

        -- Cas 1 xor 2
        t_op_a <= x"CAFEDECA";
        t_op_b <= x"DEADBEEF";
        t_alu_sel <= "0100"; -- XOR
        wait for 10 ns;
        assert (t_res = x"14536025") report "Erreur XOR: CAFEDECA xor DEADBEEF" severity error;

        -- Test SLL
        report "--- TESTS SLL ---";

        -- Cas 0 << 1
        t_op_a <= x"00000000";
        t_op_b <= x"00000001";
        t_alu_sel <= "0001"; -- SLL
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SLL: 0 << 1" severity error;

        -- Cas 1 << 1
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "0001"; -- SLL
        wait for 10 ns;
        assert (t_res = x"00000002") report "Erreur SLL: 1 << 1" severity error;

        -- Cas 1 << 0x1F
        t_op_a <= x"00000001";
        t_op_b <= x"0000001F";
        t_alu_sel <= "0001"; -- SLL
        wait for 10 ns;
        assert (t_res = x"80000000") report "Erreur SLL: 1 << 0x1F" severity error;

        -- Cas 1 << 0x20
        t_op_a <= x"00000001";
        t_op_b <= x"00000020";
        t_alu_sel <= "0001"; -- SLL
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SLL: 1 << 0x20" severity error;

        -- Cas 1 << 0x25
        t_op_a <= x"00000001";
        t_op_b <= x"00000025";
        t_alu_sel <= "0001"; -- SLL
        wait for 10 ns;
        assert (t_res = x"00000020") report "Erreur SLL: 1 << 0x25" severity error;

        -- Test SRL
        report "--- TESTS SRL ---";

        -- Cas 0 >> 1
        t_op_a <= x"00000000";
        t_op_b <= x"00000001";
        t_alu_sel <= "0101"; -- SRL
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SRL: 0 >> 1" severity error;

        -- Cas 1 >> 1
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "0101"; -- SRL
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SRL: 1 >> 1" severity error;

        -- Cas 0x80000000 >> 1
        t_op_a <= x"80000000";
        t_op_b <= x"00000001";
        t_alu_sel <= "0101"; -- SRL
        wait for 10 ns;
        assert (t_res = x"40000000") report "Erreur SRL: 0x80000000 >> 1" severity error;

        -- Cas 1 >> 0x1F
        t_op_a <= x"80000000";
        t_op_b <= x"0000001F";
        t_alu_sel <= "0101"; -- SRL
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SRL: 0x80000000 >> 0x1F" severity error;

        -- Cas 1 >> 0x20
        t_op_a <= x"00000001";
        t_op_b <= x"00000020";
        t_alu_sel <= "0101"; -- SRL
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SRL: 1 >> 0x20" severity error;

        -- Cas 1 >> 0x25
        t_op_a <= x"80000000";
        t_op_b <= x"00000025";
        t_alu_sel <= "0101"; -- SRL
        wait for 10 ns;
        assert (t_res = x"04000000") report "Erreur SRL: 0x80000000 >> 0x25" severity error;

        -- Test SRA (Shift Right Arithmetic) :
        -- Shift avec seulement les 5 LSb
        report "--- TESTS SRA ---";

        -- Cas 0 >> 1
        t_op_a <= x"00000000"; -- Le bit de signe est à 0
        t_op_b <= x"00000001"; -- On décale de 1
        t_alu_sel <= "1101"; -- SRA
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SRA : 0 >> 1" severity error;

        -- Cas 2 >> 1
        t_op_a <= x"00000002";
        t_op_b <= x"00000001"; -- On décale de 1
        t_alu_sel <= "1101"; -- SRA
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SRA: 2 >> 1" severity error;

        -- Cas 0x80000000 >> 0x1F
        t_op_a <= x"80000000"; -- Le bit de signe est à 1
        t_op_b <= x"0000001F"; -- On décale de 1F
        t_alu_sel <= "1101"; -- SRA
        wait for 10 ns;
        assert (t_res = x"FFFFFFFF") report "Erreur SRA: 0x80000000 >> 0x1F" severity error;

        -- Cas 0x80000000 >> 0x20
        t_op_a <= x"80000000";
        t_op_b <= x"00000020";
        t_alu_sel <= "1101"; -- SRA
        wait for 10 ns;
        assert (t_res = x"80000000") report "Erreur SRA: 0x80000000 >> 0x20" severity error;

        -- Cas 0x80000000 >> 0x25
        t_op_a <= x"80000000";
        t_op_b <= x"00000025";
        t_alu_sel <= "1101"; -- SRA
        wait for 10 ns;
        assert (t_res = x"FC000000") report "Erreur SRA: 0x80000000 >> 0x25" severity error;

        -- Cas 0x80000000 >> 1
        t_op_a <= x"80000000"; -- Le bit de signe est à 1
        t_op_b <= x"00000001"; -- On décale de 1
        t_alu_sel <= "1101"; -- SRA
        wait for 10 ns;
        assert (t_res = x"C0000000") report "Erreur SRA: 0x80000000 >> 1" severity error;

        -- Test SLT (Set Less Than) Signed
        report "--- TESTS SLT ---";

        -- Cas 1 < 2
        t_op_a <= x"00000001";
        t_op_b <= x"00000002";
        t_alu_sel <= "0010"; -- SLT
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SLT: 1 < 2" severity error;

        -- Cas 2 < 1
        t_op_a <= x"00000002";
        t_op_b <= x"00000001";
        t_alu_sel <= "0010"; -- SLT
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SLT: 2 < 1" severity error;

        -- Cas -1 < 1
        t_op_a <= x"FFFFFFFF";
        t_op_b <= x"00000001";
        t_alu_sel <= "0010"; -- SLT
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SLT: -1 < 1" severity error;

        -- Test SLTU (Set Less Than Unsigned)
        report "--- TESTS SLTU ---";

        -- Cas a < b
        t_op_a <= x"00000001";
        t_op_b <= x"00000002";
        t_alu_sel <= "0011"; -- SLTU
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SLTU: a < b" severity error;

        -- Cas a > b
        t_op_a <= x"00000002";
        t_op_b <= x"00000001";
        t_alu_sel <= "0011"; -- SLTU
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SLTU: a > b" severity error;

        -- Cas a == b
        t_op_a <= x"00000001";
        t_op_b <= x"00000001";
        t_alu_sel <= "0011"; -- SLTU
        wait for 10 ns;
        assert (t_res = x"00000000") report "Erreur SLTU: a == b" severity error;
        
        -- Cas : SLTU rd, x0, rs2 sets rd to 1 if rs2 is not equal to zero, otherwise sets rd to zero
        t_op_a <= x"00000000";
        t_op_b <= x"00000001";
        t_alu_sel <= "0011"; -- SLTU
        wait for 10 ns;
        assert (t_res = x"00000001") report "Erreur SLTU: comparaison avec x0" severity error;

        report "--- TESTS TERMINES ---";
        wait; -- Stoppe la simulation
    end process;

end sim;