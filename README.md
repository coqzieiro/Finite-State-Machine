# Finite-State-Machine
Implementação de sistemas digitais baseados em modelos FSM de moore e mealy.

## Máquina de Elevador:
### 1. Introdução

As Máquinas de Estados Finitos (FSM), são modelos lógicos e matemáticos que são compostos por um número finito de estados, transições entre esses estados e as ações. Elas são amplamente utilizadas em projetos de computação, como o design de hardware digital, software de controle de tráfego, linguagens de programação, protocolos de comunicação e, de fato, em qualquer sistema que precise manter um estado e reagir a eventos externos.

Um estado armazena informações sobre o passado, isto é, ele reflete as mudanças desde a entrada num estado, no início do sistema, até o momento presente. Uma transição indica uma mudança de estado e é descrita por uma condição que precisa ser realizada para que a transição ocorra. Uma ação é a descrição de uma atividade que deve ser realizada num determinado momento.

### 2. Desenvolvimento
O projeto do elevador foi implementado na placa FPGA DE0-CV Cyclone V, código: 5CEBA4F23C7

#### 2.1 Elevador
No caso do elevador, projetou-se uma FSM onde os estados representam o andar atual do elevador. As transições entre os estados podem ser acionadas por eventos como “andar requisitado”. As ações podem incluir “mover para cima”, “mover para baixo” ou “ficar parado”. 

#### 2.1.1 Diagrama de estados

<p align="center">
  <img src="https://github.com/coqzieiro/Finite-State-Machine/assets/122469265/d0d87a87-d801-402b-bc3f-9496fddd2d7b"/> <br/>
  Figura 1: Diagrama de estados do projeto do elevador.
</p>

A máquina de estados do elevador funciona por meio de três estados: parado (p), subindo (s) e descendo (d). As entradas são relacionadas à posição relativa entre o andar solicitado e o andar atual, logo, temos a seguinte codificação:

(00)	: andar solicitado > andar atual

(01) : andar solicitado < andar atual

(10): andar solicitado = andar atual

A saída é 1 se o elevador está no andar desejado e 0 caso o contrário.

#### 2.1.2 Tabela de transição

A partir do diagrama de estados, podemos montar uma tabela de transição de estados:

