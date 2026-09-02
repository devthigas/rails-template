# 🚀 Rails Application Template

Template customizado para inicialização de projetos **Ruby on Rails 8** com a stack moderna pré-configurada e **geradores automáticos de scaffold**.

---

## 🛠️ Stack Incluída

- **Asset Pipeline / JavaScript:** `esbuild` (`jsbundling-rails`)
- **Estilização CSS:** `Bootstrap 5` (`cssbundling-rails`)
- **Autenticação:** `Devise` (configurado e pronto para uso)
- **Autorização:** `Pundit` (incluído no `ApplicationController`)
- **Formulários:** `Simple Form` (com gerador configurado para Bootstrap)
- **Geradores Customizados:**
  - 🔗 `nested_resource:scaffold` (Scaffold aninhado Pai -> Filho)
  - 👤 `devise_resource:scaffold` (Scaffold associado a um usuário Devise)

---

## 📥 Como Usar

### 1. Criando uma nova aplicação diretamente via GitHub

Você pode usar o template diretamente ao criar uma nova aplicação Rails:

```bash
rails new meu_app -j esbuild --css bootstrap -m https://raw.githubusercontent.com/devthigas/rails-template/main/template.rb
```

### 2. Configurando um Atalho / Alias no Terminal (Opcional)

Para facilitar a criação de novos projetos sem precisar digitar a URL completa, adicione a função abaixo ao seu arquivo `~/.bashrc` ou `~/.zshrc`:

```bash
# Alias para criar projetos com o template
rails-new-app() {
  if [ -z "$1" ]; then
    echo "Uso: rails-new-app <nome_do_projeto> [opções adicionais]"
    return 1
  fi
  rails new "$1" -j esbuild --css bootstrap -m https://raw.githubusercontent.com/devthigas/rails-template/main/template.rb "${@:2}"
}
```

Após recarregar o terminal (`source ~/.bashrc`), você pode criar um projeto apenas executando:

```bash
rails-new-app meu_projeto
```

---

## ⚙️ Geradores Customizados Incluídos

O template instala automaticamente no seu projeto dois geradores em `lib/generators`:

---

### 1. 🔗 Gerador de Recursos Aninhados (`nested_resource:scaffold`)

Gera uma estrutura completa de CRUD para um modelo **filho** aninhado sob um modelo **pai** (relação 1:N).

#### Sintaxe:
```bash
bin/rails generate nested_resource:scaffold <ModeloPai> <ModeloFilho> <campo1:tipo> <campo2:tipo> ...
```

#### Exemplo:
```bash
bin/rails generate nested_resource:scaffold Band Song title:string duration:integer
```

#### O que é gerado:
- **Migration:** `db/migrate/..._create_songs.rb` com chave estrangeira `band_id`.
- **Model Filho (`Song`):** contém `belongs_to :band`.
- **Model Pai (`Band`):** injeta `has_many :songs, dependent: :destroy`.
- **Controller (`SongsController`):**
  - Carrega o pai via `before_action :set_band` (`Band.find(params[:band_id])`).
  - Restringe as rotas e ações ao recurso pai (`@band.songs.build`, etc.).
- **Views Bootstrap + SimpleForm:** `index`, `show`, `new`, `edit`, `_form` e partial do filho.
- **Routes:** adiciona a rota aninhada em `config/routes.rb`:
  ```ruby
  resources :bands do
    resources :songs
  end
  ```

---

### 2. 👤 Gerador de Recurso Devise (`devise_resource:scaffold`)

Gera um CRUD completo para um recurso associado diretamente a um **usuário autenticado do Devise** (ex: `User`, `Admin`, `Member`).

#### Sintaxe:
```bash
bin/rails generate devise_resource:scaffold <ModeloDevise> <ModeloRecurso> <campo1:tipo> <campo2:tipo> ...
```

#### Exemplo:
```bash
bin/rails generate devise_resource:scaffold User Post title:string content:text
```

#### O que é gerado:
- **Migration:** `db/migrate/..._create_posts.rb` com referência `t.references :user, null: false, foreign_key: true`.
- **Model do Recurso (`Post`):** contém `belongs_to :user`.
- **Model Devise (`User`):** injeta `has_many :posts, dependent: :destroy`.
- **Controller Segurado (`PostsController`):**
  - Exige autenticação automática (`before_action :authenticate_user!`).
  - Scoping de segurança total: busca e cria registros exclusivamente através do usuário logado (`current_user.posts`):
    ```ruby
    def index
      @posts = current_user.posts
    end

    def set_post
      @post = current_user.posts.find(params[:id])
    end
    ```
- **Views Bootstrap + SimpleForm:** interface limpa e responsiva para o recurso.
- **Routes:** adiciona `resources :posts` em `config/routes.rb`.

---

## 📜 Licença

Este projeto está sob a licença [MIT](LICENSE).
