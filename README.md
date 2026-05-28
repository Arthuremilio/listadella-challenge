# Listadella - Flutter Challenge

Aplicativo mobile desenvolvido em Flutter para gerenciamento de listas de compras.

O projeto permite que o usuário realize login ou cadastro, visualize suas listas, crie novas listas, acesse os produtos de cada lista, adicione produtos, filtre por categoria, ordene itens e altere o status dos produtos entre pendente e comprado.

## Funcionalidades

- Login de usuário
- Cadastro de usuário
- Controle de autenticação com token
- Renovação automática do token quando necessário
- Listagem de listas do usuário
- Criação de novas listas de compras
- Listagem de produtos por lista
- Adição de produtos
- Remoção de produtos
- Alteração de status entre comprado e pendente
- Filtro de produtos por categoria
- Ordenação de produtos por:
  - Pendentes primeiro
  - Comprados primeiro
  - Nome A-Z
  - Nome Z-A
- Tratamento de estados de carregamento, erro e vazio
- Feedback visual para ações do usuário
- Navegação entre telas
- Componentização de widgets
- Organização por features

## Tecnologias utilizadas

- Flutter
- Dart
- Provider
- HTTP
- REST API
- Material Design

## Arquitetura do projeto

O projeto foi organizado por features, separando responsabilidades por domínio da aplicação.

```txt
lib/
  core/
    assets/
    providers/
    routes/
    widgets/

  features/
    auth/
      pages/
      providers/
      widgets/

    lists/
      models/
      pages/
      providers/
      widgets/

    products/
      models/
      pages/
      providers/
      widgets/
```

## Principais módulos

### Auth

Responsável pelo fluxo de autenticação do usuário, incluindo login, cadastro e redirecionamento após autenticação.

Principais responsabilidades:

- Exibir formulário de login e cadastro
- Validar campos de e-mail e senha
- Validar confirmação de senha no cadastro
- Enviar dados para autenticação
- Armazenar o ID do usuário autenticado
- Redirecionar o usuário para a tela de listas

### Lists

Responsável pela listagem e criação das listas de compras.

Principais responsabilidades:

- Buscar listas do usuário na API
- Exibir estado de carregamento
- Exibir estado vazio
- Exibir erros de forma padronizada
- Criar uma nova lista
- Atualizar a listagem após criação
- Navegar para a tela de produtos da lista selecionada

### Products

Responsável pelo gerenciamento dos produtos de uma lista.

Principais responsabilidades:

- Exibir produtos da lista selecionada
- Adicionar produtos
- Remover produtos
- Alterar status entre pendente e comprado
- Filtrar produtos por categoria
- Ordenar produtos por nome ou status
- Exibir feedback visual para ações do usuário

### Core

Contém recursos compartilhados da aplicação.

Principais responsabilidades:

- Providers globais
- Rotas da aplicação
- Widgets reutilizáveis
- Assets compartilhados

## Fluxo da aplicação

```txt
Login/Cadastro
↓
Listas do usuário
↓
Produtos da lista
↓
Adicionar, remover, filtrar, ordenar ou marcar produtos
```

## Gerenciamento de estado

O projeto utiliza `Provider` para gerenciamento de estado.

Foram criados providers específicos para responsabilidades diferentes:

```txt
Auth
UserProvider
TokenProvider
ListsProvider
ProductProvider
```

Essa separação facilita a manutenção do código e evita concentrar todas as regras em uma única classe.

## Tratamento de token

O projeto utiliza um `TokenProvider` para centralizar o controle do token da API.

Antes de realizar requisições protegidas, o app chama:

```dart
final token = await tokenProvider.getValidToken();
```

Esse método verifica se existe um token válido. Caso o token esteja expirado ou ausente, um novo token é solicitado automaticamente antes da requisição.

Fluxo simplificado:

```txt
Verifica se existe token
↓
Confere se ainda está válido
↓
Se estiver válido, reutiliza
↓
Se estiver expirado ou ausente, busca um novo token
```

## Consumo da API

O aplicativo consome uma API REST para realizar as principais operações do sistema.

Principais operações utilizadas:

- Autenticação
- Cadastro de usuário
- Login
- Busca de listas do usuário
- Criação de listas
- Busca de categorias
- Adição de produtos
- Remoção de produtos
- Alteração do status do produto

## Tratamento de erros

O projeto possui um componente reutilizável para exibição de erros:

```txt
error_dialog.dart
```

As telas utilizam esse componente para apresentar mensagens de erro de forma padronizada ao usuário.

Além disso, os providers mantêm estados de erro para permitir que as telas exibam mensagens quando necessário.

## Estados tratados

O projeto trata os principais estados esperados em telas que consomem dados:

- Carregamento
- Erro
- Lista vazia
- Conteúdo carregado

Exemplo de fluxo visual:

```txt
Loading
↓
Erro ou vazio
↓
Conteúdo
```

## Feedback visual

O app exibe feedback visual para ações do usuário utilizando:

- `SnackBar` para ações concluídas com sucesso
- `AlertDialog` para erros
- `CircularProgressIndicator` para carregamento
- Mensagens informativas para estados vazios
- Validação visual em dialogs

Exemplos de feedback:

- Lista criada com sucesso
- Produto adicionado com sucesso
- Produto removido com sucesso
- Produto marcado como comprado
- Produto marcado como pendente

## Padrão de nomenclatura

O projeto segue os seguintes padrões:

- Arquivos em `snake_case`
- Classes em `UpperCamelCase`
- Métodos e variáveis em `lowerCamelCase`
- Models internos em inglês

Exemplo de model interno:

```dart
class ProductModel {
  final String name;
  final String category;
  final int check;
}
```

Mesmo com os models em inglês, as chaves recebidas da API são mantidas conforme o retorno original:

```dart
name: json['nome']?.toString() ?? ''
category: json['categoria']?.toString() ?? ''
```

## Estrutura de navegação

```txt
AuthPage
↓
ListsPage
↓
ProductPage
```

O fluxo principal da aplicação é:

1. Usuário acessa a tela de autenticação.
2. Usuário realiza login ou cadastro.
3. Após autenticação, o app redireciona para a tela de listas.
4. O usuário seleciona uma lista.
5. O app exibe os produtos da lista selecionada.

## Requisitos técnicos atendidos

- Flutter 3.x / Dart 3.x
- Consumo de API REST
- Tratamento de estados de carregamento, erro e vazio
- Navegação entre telas
- Feedback visual para ações do usuário
- Gerenciamento de estado com Provider
- Componentização de widgets
- Organização por features
- Padronização de nomenclatura
- Separação de responsabilidades por domínio

## Dependências principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider:
  http:
```

## Como executar o projeto

Clone o repositório:

```bash
git clone https://github.com/seu-usuario/listadella-flutter-challenge.git
```

Acesse a pasta do projeto:

```bash
cd listadella-flutter-challenge
```

Instale as dependências:

```bash
flutter pub get
```

Execute o projeto:

```bash
flutter run
```

## Observações

Este projeto foi desenvolvido como parte de um desafio prático, com foco em consumo de API, gerenciamento de estado, componentização, organização de código e boas práticas no desenvolvimento Flutter.

## Autor

Desenvolvido por Arthur Fonseca.
