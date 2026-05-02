# Guia de Requisitos para Implementação: Lista Encadeada em Assembly RISC-V

Este documento organiza as especificações do "Trabalho 1: Programação em Assembly do RISC-V" da disciplina GEX1213 Organização de Computadores (Março de 2026), ministrada pelo Professor Ricardo Parizotto. Ele foi estruturado no formato Markdown para servir como um guia claro de geração e validação de código e documentação.

## 1. Objetivo Principal
O objetivo central deste trabalho é desenvolver, em linguagem de montagem do RISC-V, uma **Lista Encadeada (Linked List)**, acompanhada de sua respectiva documentação. O desenvolvimento não deve se limitar apenas à funcionalidade do código, mas focar na compreensão prática de detalhes de baixo nível, incluindo a manipulação da memória, da pilha (stack) e dos registradores.

## 2. Escopo de Implementação
O trabalho deve ser desenvolvido em grupos de no máximo 5 pessoas. O projeto consistirá **exclusivamente** na implementação da estrutura de dados abaixo:

* **Estrutura de Dados Obrigatória:** Lista Encadeada.

*(Nota: Outras implementações de ordenação, estruturas e busca foram removidas do escopo deste projeto).*

## 3. Requisitos Técnicos e de Código (Obrigatórios)
O código gerado deve cumprir estritamente os seguintes critérios arquiteturais e de simulação:

* **Ambiente de Validação:** O programa precisa ser testado e validado em pelo menos um dos simuladores aceitos: Ripes, Venus, RARS ou gem5.
* **Fluxo de Controle:** O código deve obrigatoriamente utilizar instruções de salto e ligação (`jal`, `jalr`).
* **Convenção de Chamada:** É obrigatório aplicar a convenção de salvamento e de restauração dos registradores na stack.
* **Gerenciamento de Memória:** A estrutura da Lista Encadeada precisa realizar o gerenciamento dinâmico de memória (ex: criação de novos nós). Este comportamento deve simular a função `malloc` da linguagem C, fazendo uso de chamadas de sistema (syscalls) apropriadas para alocar memória no heap.

## 4. Diretrizes de Documentação e Entrega
A entrega final deve ser realizada até as 23h00 do dia 12 de maio. O pacote de entrega exige o código-fonte (arquivos `.riscv` ou `.s`) e um relatório em formato PDF.

### Estrutura Exigida para o Relatório
O relatório deve seguir a abordagem de "Desafios e Soluções" e detalhar os seguintes tópicos:
1. A explicação da lógica implementada para a Lista Encadeada (ex: inserção, remoção, travessia).
2. A estratégia que o grupo utilizou para estruturar a organização das funções e a alocação dinâmica dos nós no heap.
3. A documentação dos erros encontrados ao longo do desenvolvimento (como *segmentation faults* ou problemas com ponteiros) e as soluções aplicadas para resolvê-los.

### Regras sobre o Uso de Inteligência Artificial
* O uso de ferramentas de IA generativa é expressamente permitido.
* Para utilizar IA, os estudantes devem indicar de forma explícita no relatório qual foi o desafio ou o trecho de código em que a ferramenta foi aplicada.
* A explicação técnica do código e a responsabilidade pelo seu funcionamento adequado continuam sendo inteiramente do grupo.

## 5. Critérios de Avaliação
O projeto será avaliado com base na Tabela abaixo:

| Critério | Descrição | Peso |
| :--- | :--- | :--- |
| **Funcionalidade** | Execução correta nos simuladores, respeitando os requisitos de funções e alocação. | 5.0 |
| **Relatório e Clareza** | Documentação detalhada dos desafios, código bem comentado e organização do texto. | 5.0 |