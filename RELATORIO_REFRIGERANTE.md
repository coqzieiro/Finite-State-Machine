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

De tal modo, elaborou-se uma tabela para representar as transições de estados:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/3d54b1a9-bb84-41e0-a0f9-bebf3d8cfbb9"/> <br/>
  Figura 2: Tabela de transição de estados.
</p>

#### 2.1.3 Código em VHDL:

Nesse sentido, implementou-se um código em VHDL para representar o funcionamento da máquina de estados do elevador:

```cpp
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity refrigerante is
    port (
        clock       : in std_logic;
        reset       : in std_logic;
        switch_10   : in std_logic;
        switch_25   : in std_logic;
        switch_50   : in std_logic;
        switch_100  : in std_logic;
        button      : in std_logic;
        release_led : out std_logic; -- LED indicando a liberação do refrigerante
        return_led  : out std_logic; -- LED indicando o retorno das moedas
        leds        : out std_logic_vector(11 downto 0)
    );
end refrigerante;

architecture behavior of refrigerante is
    signal accumulator  : unsigned(11 downto 0) := (others => '0');
    signal value_added   : unsigned(11 downto 0) := (others => '0');
    signal first_clock   : boolean := true;

begin
    process (clock, reset)
    begin
        if reset = '1' then
            if first_clock = false then
                accumulator <= (others => '0');
            end if;

            release_led <= '0';
            return_led  <= '0';
            first_clock <= true; -- Sinaliza que o primeiro clock foi recebido
        elsif rising_edge(clock) then
            -- Remove lixo de memória após o primeiro clock
            if first_clock then
                first_clock <= false; -- Primeiro clock foi processado
            else
                -- Atualiza o acumulador com base nos switches ativos
                value_added <= (others => '0');

                if switch_10 = '1' then
                    value_added(3 downto 0) <= "1010"; -- 10 em binário
                end if;

                if switch_25 = '1' then
                    value_added(4 downto 0) <= "11001"; -- 25 em binário
                end if;

                if switch_50 = '1' then
                    value_added(5 downto 0) <= "110010"; -- 50 em binário
                end if;

                if switch_100 = '1' then
                    value_added(9 downto 0) <= "0001100100"; -- 100 em binário
                end if;

                accumulator <= accumulator + value_added;

                -- Verifica se o valor acumulado ultrapassou 100 e o botão está em 0
                if accumulator > to_unsigned(100, 12) and button = '0' then
                    release_led <= '0'; -- Acende o LED de liberação do refrigerante
                    return_led  <= '1';

                    -- Reseta o estado
                    accumulator <= (others => '0');
                    value_added <= (others => '0');
                    first_clock <= true; -- Sinaliza que o primeiro clock foi recebido
                else
                    release_led <= '0'; -- Mantém o LED de liberação apagado

                    -- Manipula o pressionamento do botão
                    if button = '1' then
                        if accumulator = to_unsigned(100, 12) then
                            release_led <= '1'; -- Usuário inseriu o valor correto (1 real)
                            return_led  <= '0';
                        else
                            return_led  <= '1'; -- Usuário inseriu menos que 1 real, retorna todas as moedas
                            release_led <= '0';
                        end if;

                        -- Reseta o estado
                        accumulator <= (others => '0');
                        value_added <= (others => '0');
                        first_clock <= true; -- Sinaliza que o primeiro clock foi recebido
                    end if;
                end if;
            end if;
        end if;
    end process;

    leds <= std_logic_vector(accumulator);

end behavior;

```
#### 2.1.4 Circuito esquemático:

Analogamente, após implementar o código em VHDL, exportou-se a lógica da máquina de refrigerante em formato de bloco e usou-se um circuito auxiliar para representar o seu funcionamento correto:

O display de sete segmentos auxilia na representação das moedas inseridas na máquina de refrigerante:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/c08b4c1b-1efb-49cd-8393-9b0dc60eecb9"/> <br/>
  Figura 3: Display de sete segmentos.
</p>

Os 4 switchs representam as moedas de 10, 25, 50 e 100:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/ac696fd2-506b-4275-9a3f-ebc05ac42b5c"/> <br/>
  Figura 4: Switchs.
</p>

O debouncer é o componente responsável por filtrar o sinal do clock:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/dce19c04-6c08-48dd-8885-d3bd0b6700a4"/> <br/>
  Figura 5: Debouncer (filtro para o clock).
</p>

O bloco do elevador foi compilado a partir do código em VHDL:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/cdeffa8d-9f44-45a1-be42-34ec0edf7b7c"/> <br/>
  Figura 6: Bloco da máquina de refrigerante.
</p>

Por fim, temos o circuito esquemático:

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/947c7279-c651-466c-bfe0-082f0b8c94c6"/> <br/>
  Figura 8: Circuito esquemático.
</p>

### 3. Conclusão

Com o término exitoso do projeto, ficou claro o quão importante é a modelagem de problemas utilizando os princípios de máquinas de estados finitos. A realização desses projetos, em particular o do refrigerante, permitiu um entendimento mais aprofundado das complexidades que surgem ao aplicar esses conceitos na prática.

Ademais, a participação ativa nos projetos possibilitou a exploração e o aperfeiçoamento do conhecimento em linguagens de hardware, como o VHDL. Essa vivência prática não só reforçou o aprendizado teórico, mas também ofereceu percepções importantes sobre as sutilezas da implementação de soluções em cenários reais.
