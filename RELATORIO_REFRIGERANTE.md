## Máquina de Refrigerante:
### 1. Introdução

As Máquinas de Estados Finitos (FSM), são modelos lógicos e matemáticos que são compostos por um número finito de estados, transições entre esses estados e as ações. Elas são amplamente utilizadas em projetos de computação, como o design de hardware digital, software de controle de tráfego, linguagens de programação, protocolos de comunicação e, de fato, em qualquer sistema que precise manter um estado e reagir a eventos externos.

Um estado armazena informações sobre o passado, isto é, ele reflete as mudanças desde a entrada num estado, no início do sistema, até o momento presente. Uma transição indica uma mudança de estado e é descrita por uma condição que precisa ser realizada para que a transição ocorra. Uma ação é a descrição de uma atividade que deve ser realizada num determinado momento.

### 2. Desenvolvimento
O projeto da máquina de refrigerante foi implementada na placa FPGA DE0-CV Cyclone V, código: 5CEBA4F23C7

#### 2.1 Refrigerante
No caso da máquina de refrigerante, os estados representam o valor total inserido na máquina. As transições podem ser acionadas pela inserção de moedas ou pelo pressionamento do botão de liberação. As ações incluem receber as moedas (r), esperar pelo botão de retirada (e) e devolver o dinheiro (d).

As entradas da máquina estão relacionadas a diferença entre a soma das moedas inseridas e o valor do refrigerante, além do botão para retirá-lo. Logo:

(00x) : soma das moedas = 0

(01x) : 0 < soma das moedas < 1

(10x) : soma das moedas = 1

(11x) : soma das moedas > 1

(xx0) : botão não pressionado

(xx1) : botão pressionado

Nesse sentido, a saída é 1 quando a transição gera a entrega bem sucedida do refrigerante e 0 em todas as outras situações.

#### 2.1.1 Diagrama de estados

Desse modo, montou-se um diagrama de estados para representar a lógica do funcionamento da máquina de refrigerante.

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/d57ea80a-e214-4f2a-a12b-34063a9596fb"/> <br/>
  Figura 1: Diagrama de estados do projeto do refrigerante.
</p>

#### 2.1.2 Tabela de transição

A partir do diagrama de estados, podemos montar uma tabela de transição de estados:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/6f9701ea-c111-411e-8163-98e3921d384d"/> <br/>
  Figura 2: Tabela de transição de estados.
</p>

#### 2.1.3 Código em VHDL:

Nesse sentido, implementou-se um código em VHDL para representar o funcionamento da máquina de estados do elevador:

```cpp
-- Date: December 10, 2023
-- Project: elevador
-- Page 1 of 2
-- Revision: elevador

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity elevador is
    Port (
        clk, clk_btn, reset_btn, reset_debouncer: in STD_LOGIC;
        a_desejado: in STD_LOGIC_VECTOR(3 downto 0); -- 4 pinos para o andar solicitado
        a_atual: out STD_LOGIC_VECTOR(3 downto 0); -- 4 bits para o andar atual
        subida, descida, aguardando: out STD_LOGIC -- LEDs para os estados
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
                    null;
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
```
#### 2.1.4 Circuito esquemático:

De tal forma, após implementar o código em VHDL, exportou-se a lógica do elevador em formato de bloco e usou-se um circuito auxiliar para representar o funcionamento correto do elevador:

O display de sete segmentos foi utilizado para representar os andares do elevador:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/5ef7909b-ec85-4c69-8a29-c921614f5dcd"/> <br/>
  Figura 3: Display de sete segmentos.
</p>

Os 4 switchs representam o comando para acessar os andares do elevador:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/759fc274-e09c-4fe2-a754-e76dacdbd113"/> <br/>
  Figura 4: Switchs que representam os andares (0-15).
</p>

O debouncer é o componente responsável por filtrar o sinal do clock:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/dce19c04-6c08-48dd-8885-d3bd0b6700a4"/> <br/>
  Figura 5: Debouncer (filtro para o clock).
</p>

O bloco do elevador foi compilado a partir do código em VHDL:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/80366e64-c242-4210-9e81-f0c39944cf8e"/> <br/>
  Figura 6: Bloco do elevador.
</p>

Foi necessário implementar uma lógica auxiliar para o funcionamento correto dos LED's:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/eb26a54c-b957-439a-a4e8-74b114522721"/> <br/>
  Figura 7: Lógica auxiliar para os LEDs.
</p>

Por fim, temos o circuito esquemático:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/ff5e399f-d9c3-4e0d-8672-7e99abc12292"/> <br/>
  Figura 8: Circuito esquemático.
</p>

### 3. Conclusão

Com a conclusão bem-sucedida do projeto, tornou-se evidente a relevância do processo de modelagem de problemas por meio dos conceitos de máquinas de estados finitos. A execução desses projetos, especificamente do elevador, proporcionou uma compreensão mais profunda das complexidades envolvidas na aplicação prática desses conceitos.

Além disso, a imersão nos projetos permitiu a exploração e aprimoramento do conhecimento em linguagens de hardware, como o VHDL. Essa experiência prática não apenas consolidou o entendimento teórico adquirido, mas também proporcionou insights valiosos sobre as nuances da implementação de soluções em ambientes do mundo real.
