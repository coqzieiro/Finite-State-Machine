library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity elevador is
    Port (
        clk, clk_btn, reset_btn, reset_debouncer: in STD_LOGIC;
        a_desejado: in STD_LOGIC_VECTOR(3 downto 0); -- 4 pinos para o andar solicitado
        a_atual: out STD_LOGIC_VECTOR(3 downto 0);   -- 4 bits para o andar atual
        subida, descida, aguardando: out STD_LOGIC     -- LEDs para os estados
    );
end elevador;

architecture Elevator of elevador is
    type STATE_TYPE is (parado, subindo, descendo);
    signal estado, prox_estado: STATE_TYPE;
    signal a_interno: STD_LOGIC_VECTOR(3 downto 0) := "0000"; -- Inicia no andar térreo

    -- Declaração do componente debouncer
    component debouncer
        port (
            clk_fpga, rst_debouncer, input_key: in STD_LOGIC;
            out_key: out STD_LOGIC
        );
    end component;

    -- Sinal para conectar ao debouncer
    signal db_a_desejado: STD_LOGIC_VECTOR(3 downto 0);
	 signal out_clk_db, out_reset_db: STD_LOGIC;

begin

    -- Debouncer
    D1: debouncer PORT MAP (clk_fpga => clk, rst_debouncer => reset_debouncer, input_key => a_desejado(3), out_key => db_a_desejado(3));
	 D2: debouncer PORT MAP (clk_fpga => clk, rst_debouncer => reset_debouncer, input_key => a_desejado(2), out_key => db_a_desejado(2));
	 D3: debouncer PORT MAP (clk_fpga => clk, rst_debouncer => reset_debouncer, input_key => a_desejado(1), out_key => db_a_desejado(1));
	 D4: debouncer PORT MAP (clk_fpga => clk, rst_debouncer => reset_debouncer, input_key => a_desejado(0), out_key => db_a_desejado(0));
	 D5: debouncer PORT MAP (clk_fpga => clk, rst_debouncer => reset_debouncer, input_key => clk_btn, out_key => out_clk_db);
	 D6: debouncer PORT MAP (clk_fpga => clk, rst_debouncer => reset_debouncer, input_key => reset_btn, out_key => out_reset_db);
	 
    -- Transição de estado e Atualização de andar
    process(out_clk_db, out_reset_db)
    begin
        if out_reset_db = '1' then
            estado <= parado;
            a_interno <= "0000"; -- Reset para o andar térreo
        elsif rising_edge(out_clk_db) then
            -- Atualize o estado
            estado <= prox_estado;

            -- Atualize a_interno com base no estado e Verificações adicionais
            case estado is
                when subindo =>
                    if a_interno < db_a_desejado and a_interno < "1111" then
                        a_interno <= a_interno + 1;
                    end if;
                when descendo =>
                    if a_interno > db_a_desejado and a_interno > "0000" then
                        a_interno <= a_interno - 1;
                    end if;
                when others =>
            end case;
        end if;
    end process;
	 
    -- Saída
    process(estado)
    begin
        case estado is
            when parado =>
                subida <= '0';
                descida <= '0';
                aguardando <= '1';

            when subindo =>
                subida <= '1';
                descida <= '0';
                aguardando <= '0';

            when descendo =>
                subida <= '0';
                descida <= '1';
                aguardando <= '0';
        end case;
    end process;

    -- Determinar o próximo estado
    process(estado, a_interno, db_a_desejado)
    begin
        case estado is
            when parado =>
                if a_interno = db_a_desejado then
                    prox_estado <= parado;
                elsif a_interno < db_a_desejado then
                    prox_estado <= subindo;
                elsif a_interno > db_a_desejado then
                    prox_estado <= descendo;
                end if;

            when subindo =>
                if a_interno >= db_a_desejado then
                    prox_estado <= parado;
                else
                    prox_estado <= subindo;
                end if;

            when descendo =>
                if a_interno <= db_a_desejado then
                    prox_estado <= parado;
                else
                    prox_estado <= descendo;
                end if;
        end case;
    end process;



    -- Atribuir a_interno à saída
    a_atual <= a_interno;

end Elevator;
