# 📦 Template Minimalist Clean Dashboard UI (Rails + Bootstrap 5)

Este pacote contém todos os componentes, estilos e templates extraídos do painel limpo e minimalista para você reutilizar rapidamente em qualquer projeto Ruby on Rails.

---

## 📁 Estrutura de Arquivos

```text
seu_projeto/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       └── application.bootstrap.scss   # Estilos SCSS completos (Design System)
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb         # Layout mestre responsivo
│       └── shared/
│           ├── _aside.html.erb              # Sidebar (Desktop fixa + Mobile Offcanvas)
│           └── _navbar.html.erb             # Barra superior limpa com menu de usuário
```

---

## 1. 🎨 Estilos Globais: `application.bootstrap.scss`

Cole no arquivo de estilos do seu projeto (geralmente `app/assets/stylesheets/application.bootstrap.scss`):

```scss
// Google Fonts - Inter
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

// Bootstrap Variables - Clean, Minimalist, Neutral Tone
$font-family-sans-serif: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
$font-size-base: 0.875rem; // 14px compact
$line-height-base: 1.5;

// Monochromatic / Subtle Neutral Palette
$primary: #18181b;          // Zinc 900
$primary-hover: #09090b;
$secondary: #71717a;        // Zinc 500
$success: #15803d;
$danger: #b91c1c;
$warning: #b45309;
$info: #0369a1;

$light: #f4f4f5;            // Zinc 100
$dark: #18181b;             // Zinc 900
$body-bg: #fafafa;          // Fundo limpo
$body-color: #27272a;       // Zinc 800

$border-color: #e4e4e7;     // Borda suave hairline
$border-radius-sm: 6px;
$border-radius: 8px;
$border-radius-lg: 10px;

$box-shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.04);
$box-shadow: 0 2px 8px -2px rgba(0, 0, 0, 0.05);

@import 'bootstrap/scss/bootstrap';
@import 'bootstrap-icons/font/bootstrap-icons';

// ----------------------------------------------------
// Global Resets & Minimal Base
// ----------------------------------------------------
*, *::before, *::after {
  box-sizing: border-box;
}

html, body {
  height: 100%;
  margin: 0;
  padding: 0;
  background-color: $body-bg;
  color: $body-color;
  font-family: $font-family-sans-serif;
  letter-spacing: -0.01em;
  -webkit-font-smoothing: antialiased;
}

a {
  color: inherit;
  text-decoration: none;
  transition: color 0.12s ease;
}

// ----------------------------------------------------
// Layout Architecture
// ----------------------------------------------------
.app-container {
  display: flex;
  min-height: 100vh;
  width: 100%;
}

// Sidebar
.app-sidebar {
  width: 240px;
  min-width: 240px;
  background: #ffffff;
  border-right: 1px solid #e4e4e7;
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 0;
  height: 100vh;
  z-index: 100;

  .sidebar-header {
    height: 56px;
    padding: 0 1.25rem;
    display: flex;
    align-items: center;
    gap: 0.625rem;
    border-bottom: 1px solid #f4f4f5;

    .brand-mark {
      width: 24px;
      height: 24px;
      background: #18181b;
      color: #ffffff;
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 0.75rem;
      font-weight: 700;
    }

    .brand-title {
      font-size: 0.875rem;
      font-weight: 600;
      color: #18181b;
    }
  }

  .sidebar-nav {
    padding: 1rem 0.75rem;
    flex-grow: 1;
    overflow-y: auto;

    .nav-label {
      font-size: 0.6875rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: #a1a1aa;
      padding: 0.5rem 0.75rem 0.25rem;
      margin-bottom: 0.25rem;
    }

    .nav-item {
      margin-bottom: 2px;
    }

    .nav-link {
      display: flex;
      align-items: center;
      gap: 0.625rem;
      padding: 0.5rem 0.75rem;
      font-size: 0.84rem;
      font-weight: 500;
      color: #52525b;
      border-radius: 6px;
      transition: all 0.12s ease;

      i {
        font-size: 1rem;
        color: #71717a;
      }

      &:hover {
        background-color: #f4f4f5;
        color: #18181b;
        i { color: #18181b; }
      }

      &.active {
        background-color: #f4f4f5;
        color: #18181b;
        font-weight: 600;
        i { color: #18181b; }
      }

      .badge-counter {
        margin-left: auto;
        font-size: 0.75rem;
        color: #71717a;
        background: #e4e4e7;
        padding: 1px 6px;
        border-radius: 10px;
      }
    }
  }

  .sidebar-footer {
    padding: 0.75rem;
    border-top: 1px solid #f4f4f5;

    .user-card {
      display: flex;
      align-items: center;
      gap: 0.625rem;
      padding: 0.5rem;
      border-radius: 6px;

      .user-avatar {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: #e4e4e7;
        color: #27272a;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.75rem;
        font-weight: 600;
        flex-shrink: 0;
      }

      .user-details {
        overflow: hidden;
        .email {
          font-size: 0.8125rem;
          font-weight: 500;
          color: #18181b;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
      }
    }
  }
}

// Main Content
.app-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

// Topbar
.app-topbar {
  height: 56px;
  background: #ffffff;
  border-bottom: 1px solid #e4e4e7;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.5rem;
  position: sticky;
  top: 0;
  z-index: 90;

  .topbar-left, .topbar-right {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }
}

// Content Container
.page-container {
  flex: 1;
  max-width: 1080px;
  width: 100%;
  margin: 0 auto;
  padding: 2rem 1.5rem;
}

// ----------------------------------------------------
// UI Components
// ----------------------------------------------------

// Metrics Cards
.metric-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;

  .metric-card {
    background: #ffffff;
    border: 1px solid #e4e4e7;
    border-radius: 8px;
    padding: 1rem 1.25rem;

    .metric-label {
      font-size: 0.75rem;
      font-weight: 500;
      color: #71717a;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      margin-bottom: 0.25rem;
    }

    .metric-num {
      font-size: 1.5rem;
      font-weight: 600;
      color: #18181b;
      line-height: 1.2;
    }
  }
}

// Minimal Table Card
.minimal-table-card {
  background: #ffffff;
  border: 1px solid #e4e4e7;
  border-radius: 8px;
  overflow: hidden;
}

.table.minimal-table {
  margin-bottom: 0;
  width: 100%;
  font-size: 0.84rem;

  thead th {
    background-color: #fafafa;
    border-bottom: 1px solid #e4e4e7;
    color: #71717a;
    font-weight: 500;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    padding: 0.625rem 1rem;
  }

  tbody tr {
    transition: background-color 0.1s ease;
    border-bottom: 1px solid #f4f4f5;

    &:hover { background-color: #fafafa; }
    &:last-child { border-bottom: none; }

    td {
      padding: 0.75rem 1rem;
      vertical-align: middle;
      color: #27272a;
    }
  }
}

// Buttons
.btn {
  font-size: 0.8125rem;
  font-weight: 500;
  border-radius: 6px;
  padding: 0.45rem 0.875rem;
  transition: all 0.12s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.375rem;
}

.btn-dark {
  background: #18181b;
  border-color: #18181b;
  color: #ffffff;

  &:hover {
    background: #09090b;
    border-color: #09090b;
    color: #ffffff;
  }
}

.btn-subtle {
  background: transparent;
  border: 1px solid #e4e4e7;
  color: #3f3f46;

  &:hover {
    background: #f4f4f5;
    border-color: #d4d4d8;
    color: #18181b;
  }
}

.btn-icon {
  width: 32px;
  height: 32px;
  padding: 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  background: transparent;
  border: 1px solid transparent;
  color: #71717a;

  &:hover {
    background: #f4f4f5;
    color: #18181b;
  }
}

// Forms
.form-control, .form-select {
  border-radius: 6px;
  border: 1px solid #d4d4d8;
  font-size: 0.875rem;
  padding: 0.5rem 0.75rem;
  background-color: #ffffff;

  &:focus {
    border-color: #18181b;
    box-shadow: 0 0 0 1px #18181b;
    outline: none;
  }
}

.form-label {
  font-size: 0.8125rem;
  font-weight: 500;
  color: #27272a;
  margin-bottom: 0.35rem;
}

// Auth Wrapper
.minimal-auth-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  background-color: #fafafa;

  .auth-box {
    width: 100%;
    max-width: 380px;
    background: #ffffff;
    border: 1px solid #e4e4e7;
    border-radius: 8px;
    padding: 2rem;
  }
}

// Responsive Breakpoints
@media (max-width: 991.98px) {
  .app-sidebar { display: none; }
  .app-topbar { padding: 0 1rem; }
  .page-container { padding: 1.25rem 1rem; }
  .metric-row { grid-template-columns: 1fr 1fr; gap: 0.75rem; }
}

@media (max-width: 575.98px) {
  .metric-row { grid-template-columns: 1fr; }
  .page-header-actions {
    flex-direction: column;
    align-items: stretch !important;
    gap: 0.75rem !important;
    .btn { width: 100%; }
  }
}
```

---

## 2. 🖥️ Layout Mestre: `app/views/layouts/application.html.erb`

```erb
<!DOCTYPE html>
<html lang="pt-BR">
  <head>
    <title><%= content_for(:title) || "App" %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= yield :head %>

    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>
  </head>

  <body>
    <% if respond_to?(:user_signed_in?) && user_signed_in? %>
      <div class="app-container">
        <%= render "shared/aside" %>

        <div class="app-content">
          <%= render "shared/navbar" %>

          <main class="page-container">
            <% if notice.present? %>
              <div class="alert alert-light border shadow-sm py-2 px-3 small mb-4 d-flex align-items-center justify-content-between" role="alert">
                <span class="text-dark"><%= notice %></span>
                <button type="button" class="btn-close small" data-bs-dismiss="alert" aria-label="Fechar" style="font-size: 0.65rem;"></button>
              </div>
            <% end %>

            <% if alert.present? %>
              <div class="alert alert-danger border-0 py-2 px-3 small mb-4 d-flex align-items-center justify-content-between" role="alert">
                <span><%= alert %></span>
                <button type="button" class="btn-close small" data-bs-dismiss="alert" aria-label="Fechar" style="font-size: 0.65rem;"></button>
              </div>
            <% end %>

            <%= yield %>
          </main>
        </div>
      </div>
    <% else %>
      <%# Layout para Auth / Telas de Login %>
      <div class="minimal-auth-wrapper">
        <div class="auth-box shadow-sm">
          <% if notice.present? %>
            <div class="alert alert-light border py-2 px-3 small mb-3 text-dark"><%= notice %></div>
          <% end %>
          <% if alert.present? %>
            <div class="alert alert-danger border-0 py-2 px-3 small mb-3"><%= alert %></div>
          <% end %>

          <%= yield %>
        </div>
      </div>
    <% end %>
  </body>
</html>
```

---

## 3. 📑 Sidebar Responsiva: `app/views/shared/_aside.html.erb`

```erb
<%# Mobile Offcanvas %>
<div class="offcanvas offcanvas-start border-end" tabindex="-1" id="sidebarOffcanvas" style="width: 260px;">
  <div class="offcanvas-header border-bottom py-3 px-3">
    <div class="d-flex align-items-center gap-2">
      <div class="brand-mark" style="width: 24px; height: 24px; background: #18181b; color: #fff; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 0.75rem; font-weight: 700;">A</div>
      <span class="fw-semibold text-dark">Meu App</span>
    </div>
    <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body p-2">
    <nav class="nav flex-column">
      <%= link_to root_path, class: "nav-link py-2 px-3 rounded text-secondary" do %>
        <i class="bi bi-grid me-2"></i> Início
      <% end %>
    </nav>
  </div>
</div>

<%# Desktop Sidebar %>
<aside class="app-sidebar d-none d-lg-flex">
  <div class="sidebar-header">
    <div class="brand-mark">A</div>
    <span class="brand-title">Meu App</span>
  </div>

  <div class="sidebar-nav">
    <div class="nav-label">Menu</div>
    <ul class="nav flex-column">
      <li class="nav-item">
        <%= link_to root_path, class: "nav-link active" do %>
          <i class="bi bi-grid"></i>
          <span>Dashboard</span>
        <% end %>
      </li>
    </ul>
  </div>

  <div class="sidebar-footer">
    <div class="user-card">
      <div class="user-avatar">U</div>
      <div class="user-details flex-grow-1">
        <div class="email"><%= current_user.email rescue "usuario@email.com" %></div>
      </div>
    </div>
  </div>
</aside>
```

---

## 4. 🔝 Topbar Limpa: `app/views/shared/_navbar.html.erb`

```erb
<header class="app-topbar">
  <div class="topbar-left">
    <button class="btn btn-icon d-lg-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#sidebarOffcanvas" aria-label="Abrir Menu">
      <i class="bi bi-list fs-5"></i>
    </button>
    <span class="fw-semibold text-dark d-lg-none">Meu App</span>
  </div>

  <div class="topbar-right">
    <% if respond_to?(:current_user) && current_user %>
      <div class="dropdown">
        <button class="btn btn-subtle btn-sm d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown">
          <span class="d-none d-sm-inline-block text-secondary small"><%= current_user.email %></span>
          <i class="bi bi-chevron-down text-muted" style="font-size: 0.7rem;"></i>
        </button>
        <ul class="dropdown-menu dropdown-menu-end border shadow-sm small py-1">
          <li><%= link_to "Sair", destroy_user_session_path, data: { turbo_method: :delete }, class: "dropdown-item py-1 text-danger" %></li>
        </ul>
      </div>
    <% end %>
  </div>
</header>
```

---

## 5. 📊 Exemplo de Página de Listagem (Index com Métricas + Tabela)

```erb
<div class="d-flex justify-content-between align-items-center mb-4 page-header-actions">
  <div>
    <h1 class="h5 mb-0 fw-semibold text-dark">Itens</h1>
    <p class="text-secondary small mb-0">Visão geral e listagem</p>
  </div>
  <div>
    <a href="#" class="btn btn-dark">
      <i class="bi bi-plus-lg"></i> Novo Item
    </a>
  </div>
</div>

<%# Métricas %>
<div class="metric-row">
  <div class="metric-card">
    <div class="metric-label">Total</div>
    <div class="metric-num">128</div>
  </div>
  <div class="metric-card">
    <div class="metric-label">Ativos</div>
    <div class="metric-num">94</div>
  </div>
</div>

<%# Tabela Clean %>
<div class="minimal-table-card">
  <div class="table-responsive">
    <table class="table minimal-table">
      <thead>
        <tr>
          <th>Nome</th>
          <th>Status</th>
          <th class="text-end">Ações</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td class="fw-medium text-dark">Exemplo de Item</td>
          <td class="text-secondary">Ativo</td>
          <td class="text-end">
            <button class="btn-icon"><i class="bi bi-pencil"></i></button>
            <button class="btn-icon text-danger"><i class="bi bi-trash"></i></button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
```
