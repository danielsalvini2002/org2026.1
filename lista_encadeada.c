#include <stdio.h>
#include <stdlib.h>

/**
 * @brief Estrutura de um nó da lista encadeada
 * 
 * Cada nó contém um valor inteiro e um ponteiro para o próximo nó
 */
typedef struct No {
    int valor;              // Dados armazenados no nó
    struct No *proximo;     // Ponteiro para o próximo nó (NULL se for o último)
} No;

/**
 * @brief Cria um novo nó com um valor específico
 * 
 * @param valor Valor inteiro a ser armazenado no nó
 * @return Ponteiro para o novo nó alocado, ou NULL se falhar
 */
No* criar_no(int valor) {
    // Aloca memória para um novo nó
    No *novo = (No *)malloc(sizeof(No));
    
    if (novo == NULL) {
        printf("Erro: não foi possível alocar memória\n");
        return NULL;
    }
    
    // Inicializa o novo nó
    novo->valor = valor;      // Armazena o valor
    novo->proximo = NULL;     // O próximo começa como vazio
    
    return novo;
}

/**
 * @brief Insere um valor no início da lista
 * 
 * @param cabeca Ponteiro duplo para o primeiro nó da lista
 * @param valor Valor a ser inserido
 */
void inserir_inicio(No **cabeca, int valor) {
    // Cria um novo nó
    No *novo = criar_no(valor);
    
    if (novo == NULL) {
        return;
    }
    
    // O novo nó aponta para o que era o primeiro (pode ser NULL)
    novo->proximo = *cabeca;
    
    // Atualiza a cabeça para apontar para o novo nó
    *cabeca = novo;
}

/**
 * @brief Insere um valor no final da lista
 * 
 * @param cabeca Ponteiro duplo para o primeiro nó da lista
 * @param valor Valor a ser inserido
 */
void inserir_final(No **cabeca, int valor) {
    // Cria um novo nó
    No *novo = criar_no(valor);
    
    if (novo == NULL) {
        return;
    }
    
    // Se a lista está vazia, o novo nó se torna a cabeça
    if (*cabeca == NULL) {
        *cabeca = novo;
        return;
    }
    
    // Percorre a lista até encontrar o último nó
    No *atual = *cabeca;
    while (atual->proximo != NULL) {
        atual = atual->proximo;
    }
    
    // Liga o último nó ao novo nó
    atual->proximo = novo;
}

/**
 * @brief Remove o primeiro nó da lista
 * 
 * @param cabeca Ponteiro duplo para o primeiro nó da lista
 * @return Valor removido, ou -1 se lista vazia
 */
int remover_inicio(No **cabeca) {
    // Verifica se a lista está vazia
    if (*cabeca == NULL) {
        printf("Erro: lista vazia\n");
        return -1;
    }
    
    // Salva o primeiro nó
    No *temp = *cabeca;
    
    // Guarda o valor antes de liberar memória
    int valor = temp->valor;
    
    // Atualiza a cabeça para o próximo nó
    *cabeca = temp->proximo;
    
    // Libera a memória do nó removido
    free(temp);
    
    return valor;
}

/**
 * @brief Busca um valor na lista
 * 
 * @param cabeca Primeiro nó da lista
 * @param valor Valor a procurar
 * @return 1 se encontrado, 0 se não encontrado
 */
int buscar(No *cabeca, int valor) {
    // Percorre a lista
    No *atual = cabeca;
    while (atual != NULL) {
        if (atual->valor == valor) {
            return 1;  // Encontrou
        }
        atual = atual->proximo;
    }
    
    return 0;  // Não encontrou
}

/**
 * @brief Exibe todos os elementos da lista
 * 
 * @param cabeca Primeiro nó da lista
 */
void exibir(No *cabeca) {
    printf("Lista: ");
    
    No *atual = cabeca;
    while (atual != NULL) {
        printf("%d -> ", atual->valor);
        atual = atual->proximo;
    }
    
    printf("NULL\n");
}

/**
 * @brief Libera toda a memória da lista
 * 
 * @param cabeca Ponteiro duplo para o primeiro nó da lista
 */
void liberar_lista(No **cabeca) {
    No *atual = *cabeca;
    
    // Percorre toda a lista, liberando cada nó
    while (atual != NULL) {
        No *temp = atual;
        atual = atual->proximo;
        free(temp);
    }
    
    *cabeca = NULL;  // A lista agora aponta para nada
}

/**
 * @brief Função principal - demonstra o uso da lista encadeada
 */
int main() {
    No *lista = NULL;  // Lista começa vazia
    
    printf("=== Operações em Lista Encadeada ===\n\n");
    
    // Insere alguns valores no final
    printf("Inserindo valores no final: 10, 20, 30\n");
    inserir_final(&lista, 10);
    inserir_final(&lista, 20);
    inserir_final(&lista, 30);
    exibir(lista);
    printf("\n");
    
    // Insere um valor no início
    printf("Inserindo 5 no início\n");
    inserir_inicio(&lista, 5);
    exibir(lista);
    printf("\n");
    
    // Busca um valor
    printf("Buscando valor 20: %s\n", buscar(lista, 20) ? "Encontrado" : "Não encontrado");
    printf("Buscando valor 100: %s\n", buscar(lista, 100) ? "Encontrado" : "Não encontrado");
    printf("\n");
    
    // Remove do início
    printf("Removendo do início: valor %d\n", remover_inicio(&lista));
    exibir(lista);
    printf("\n");
    
    // Libera toda a memória
    printf("Liberando lista...\n");
    liberar_lista(&lista);
    exibir(lista);
    
    return 0;
}