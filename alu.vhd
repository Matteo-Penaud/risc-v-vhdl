library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port(
        op_a   : in  std_logic_vector(31 downto 0); -- Entrée A
        op_b   : in  std_logic_vector(31 downto 0); -- Entrée B
        alu_sel: in  std_logic_vector(3 downto 0);  -- Sélection de l'opération
        res    : out std_logic_vector(31 downto 0); -- Résultat
        zero   : out std_logic                      -- Flag 'Zéro' (pour les branchements)
    );
end ALU;

architecture archALU of ALU is
    signal res_internal : std_logic_vector(31 downto 0);
begin

    process(op_a, op_b, alu_sel)
    begin
        case alu_sel is
            when "0000" => -- ADD
                res_internal <= std_logic_vector(unsigned(op_a) + unsigned(op_b));
            
            when "1000" => -- SUB
                res_internal <= std_logic_vector(unsigned(op_a) - unsigned(op_b));

            when "0111" => -- AND
                res_internal <= op_a and op_b;

            when "0110" => -- OR
                res_internal <= op_a or op_b;
                
            when "0100" => -- XOR
                res_internal <= op_a xor op_b;
                     
            when "0001" => -- SLL
                res_internal <= STD_LOGIC_VECTOR(SHIFT_LEFT(unsigned(op_a), TO_INTEGER(unsigned(op_b(4 downto 0)))));
                     
            when "0101" => -- SRL
                res_internal <= STD_LOGIC_VECTOR(SHIFT_RIGHT(unsigned(op_a), TO_INTEGER(unsigned(op_b(4 downto 0)))));
                
            when "1101" => -- SRA
                -- SRA : Shift Right Arithmetic : decalage a droit en conservant le signe
                res_internal <= STD_LOGIC_VECTOR(SHIFT_RIGHT(signed(op_a), TO_INTEGER(unsigned(op_b(4 downto 0)))));

            when "0010" => -- SLT
                if signed(op_a) < signed(op_b) then
                    res_internal <= x"00000001";
                else
                    res_internal <= x"00000000";
                end if;
                
            when "0011" => -- SLTU
                if unsigned(op_a) < unsigned(op_b) then
                    res_internal <= x"00000001";
                else
                    res_internal <= x"00000000";
                end if;
            
            -- Les autres opérations viendront ici (XOR, SLL, etc.)
            when others => 
                res_internal <= (others => '0');
        end case;
    end process;

    res <= res_internal;
    
    -- Le flag Zero est utile pour les instructions de saut (if a == b)
    zero <= '1' when res_internal = x"00000000" else '0';

end archALU;