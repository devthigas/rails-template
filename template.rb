# Template para criação de projetos Rails
# Stack: esbuild, Bootstrap, Devise, Pundit e SimpleForm

# Adiciona Gems necessárias
gem "devise"
gem "pundit"
gem "simple_form"

after_bundle do
  # 1. Configurar SimpleForm com suporte a Bootstrap
  generate "simple_form:install", "--bootstrap"

  # 2. Configurar Devise
  generate "devise:install"

  # 3. Configurar Pundit
  generate "pundit:install"

  # 4. Incluir Pundit::Authorization no ApplicationController
  inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
    "  include Pundit::Authorization\n"
  end

  # 5. Adicionar tratamento padrão para Pundit::NotAuthorizedError (opcional)
  append_to_file "app/controllers/application_controller.rb" do
    <<~RUBY

      # Trata exceções do Pundit (descomente para ativar por padrão)
      # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      #
      # private
      #
      # def user_not_authorized
      #   flash[:alert] = "Você não tem permissão para realizar esta ação."
      #   redirect_back(fallback_location: root_path)
      # end
    RUBY
  end

  # 6. (Opcional) Gerar model User do Devise
  # generate "devise User"

  # =========================================================================
  # 7. Instalar gerador de recursos aninhados (nested_resource)
  #
  # Uso:
  #   rails g nested_resource:scaffold Parent Child field1:type field2:type
  #
  # Exemplos:
  #   rails g nested_resource:scaffold Band Song title:string duration:integer
  #   rails g nested_resource:scaffold User Post title:string body:text
  #   rails g nested_resource:scaffold Category Product name:string price:decimal
  #
  # Isso gera:
  #   - Migration para o modelo filho com foreign_key
  #   - Model filho com belongs_to + model pai com has_many
  #   - Controller com ações aninhadas
  #   - Views com SimpleForm + Bootstrap
  #   - Rotas configuradas automaticamente
  # =========================================================================

  # --- Gerador principal ---
  create_file "lib/generators/nested_resource/scaffold_generator.rb" do
    <<~'RUBYW'
      # frozen_string_literal: true

      require "rails/generators"
      require "rails/generators/active_record"

      module NestedResource
        class ScaffoldGenerator < Rails::Generators::NamedBase
          source_root File.expand_path("templates", __dir__)

          argument :child_model, type: :string, desc: "Modelo filho (ex: Song)"
          argument :fields, type: :array, default: [], banner: "field:type"

          # --- Helpers para o pai ---

          def parent_model
            name
          end

          def parent_instance
            parent_model.underscore
          end

          def parent_instance_var
            "@#{parent_instance}"
          end

          def child_instance_var
            "@#{child_instance}"
          end

          def parent_path
            parent_model.underscore.pluralize
          end

          def parent_class
            parent_model.classify
          end

          # --- Helpers para o filho ---

          def child_instance
            child_model.underscore
          end

          def child_path
            child_model.underscore.pluralize
          end

          def child_class
            child_model.classify
          end

          # --- Helpers para campos ---

          def fields_with_types
            fields.map do |f|
              field_name, field_type = f.split(":")
              { name: field_name, type: field_type || "string" }
            end
          end

          def permitted_params
            fields.map { |f| ":#{f.split(':').first}" }.join(", ")
          end

          # --- Gerar todos os arquivos ---

          def generate_all
            template_migration
            template_model
            template_parent_model
            template_controller
            template_views
            template_routes
            say "\n✅ Recursos aninhados criados com sucesso!", :green
            say "Rota adicionada em config/routes.rb", :green
          end

          private

          def template_migration
            timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
            template "migration.rb.erb",
                     "db/migrate/#{timestamp}_create_#{child_path}.rb"
          end

          def template_model
            template "model.rb.erb", "app/models/#{child_instance}.rb"
          end

          def template_parent_model
            path = "app/models/#{parent_instance}.rb"
            if File.exist?(File.join(destination_root, path))
              say "  Model #{parent_class} já existe, adicionando relação...", :yellow
              inject_into_class path, parent_class do
                "  has_many :#{child_path}, dependent: :destroy\n"
              end
            else
              template "parent_model.rb.erb", path
            end
          end

          def template_controller
            template "controller.rb.erb",
                     "app/controllers/#{child_path}_controller.rb"
          end

          def template_views
            empty_directory "app/views/#{child_path}"

            template "views/index.html.erb",
                     "app/views/#{child_path}/index.html.erb"
            template "views/show.html.erb",
                     "app/views/#{child_path}/show.html.erb"
            template "views/new.html.erb",
                     "app/views/#{child_path}/new.html.erb"
            template "views/edit.html.erb",
                     "app/views/#{child_path}/edit.html.erb"
            template "views/_form.html.erb",
                     "app/views/#{child_path}/_form.html.erb"
            template "views/_child.html.erb",
                     "app/views/#{child_path}/_#{child_instance}.html.erb"
          end

          def template_routes
            routes_file = "config/routes.rb"
            routes_content = File.read(File.join(destination_root, routes_file))

            if routes_content.include?("resources :#{parent_path}")
              say "  Rota para #{parent_path} já existe, verifique manualmente", :yellow
            else
              route "resources :#{parent_path} do\n    resources :#{child_path}\n  end"
            end
          rescue Errno::ENOENT
            say "  Não foi possível ler routes.rb", :red
          end
        end
      end
    RUBYW
  end

  # --- Templates ERB ---

  create_file "lib/generators/nested_resource/templates/migration.rb.erb" do
    <<~'ERBDOC'
      class Create<%= child_path.camelize %> < ActiveRecord::Migration<%= "[#{ActiveRecord::Migration.current_version}]" %>
        def change
          create_table :<%= child_path %> do |t|
      <% fields_with_types.each do |field| -%>
            t.<%= field[:type] %> :<%= field[:name] %>
      <% end -%>
            t.references :<%= parent_instance %>, null: false, foreign_key: true

            t.timestamps
          end
        end
      end
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/model.rb.erb" do
    <<~'ERBDOC'
      class <%= child_class %> < ApplicationRecord
        belongs_to :<%= parent_instance %>
      end
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/parent_model.rb.erb" do
    <<~'ERBDOC'
      class <%= parent_class %> < ApplicationRecord
        has_many :<%= child_path %>, dependent: :destroy
      end
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/controller.rb.erb" do
    <<~'ERBDOC'
      class <%= child_path.camelize %>Controller < ApplicationController
        before_action :set_<%= parent_instance %>
        before_action :set_<%= child_instance %>, only: %i[show edit update destroy]

        def index
          @<%= child_path %> = <%= parent_instance_var %>.<%= child_path %>
        end

        def show; end

        def new
          @<%= child_instance %> = <%= parent_instance_var %>.<%= child_path %>.build
        end

        def edit; end

        def create
          @<%= child_instance %> = <%= parent_instance_var %>.<%= child_path %>.build(<%= child_instance %>_params)

          if @<%= child_instance %>.save
            redirect_to [<%= parent_instance_var %>, @<%= child_instance %>], notice: "<%= child_class %> criado com sucesso."
          else
            render :new, status: :unprocessable_entity
          end
        end

        def update
          if @<%= child_instance %>.update(<%= child_instance %>_params)
            redirect_to [<%= parent_instance_var %>, @<%= child_instance %>], notice: "<%= child_class %> atualizado com sucesso."
          else
            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          @<%= child_instance %>.destroy!
          redirect_to <%= parent_instance %>_<%= child_path %>_url(<%= parent_instance_var %>), status: :see_other, notice: "<%= child_class %> removido com sucesso."
        end

        private

        def set_<%= parent_instance %>
          <%= parent_instance_var %> = <%= parent_class %>.find(params[:<%= parent_instance %>_id])
        end

        def set_<%= child_instance %>
          @<%= child_instance %> = <%= parent_instance_var %>.<%= child_path %>.find(params[:id])
        end

        def <%= child_instance %>_params
          params.require(:<%= child_instance %>).permit(<%= permitted_params %>)
        end
      end
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/views/index.html.erb" do
    <<~'ERBDOC'
      <h1><%= child_path.camelize %></h1>

      <div id="<%= child_path %>">
        <%% @<%= child_path %>.each do |<%= child_instance %>| %>
          <div class="mb-3 p-3 border rounded">
            <%%= render "<%= child_instance %>", <%= child_instance %>: <%= child_instance %> %>
            <div class="mt-2">
              <%%= link_to "Ver", [<%= parent_instance_var %>, <%= child_instance %>], class: "btn btn-sm btn-outline-secondary" %>
              <%%= link_to "Editar", edit_<%= parent_instance %>_<%= child_instance %>_path(<%= parent_instance_var %>, <%= child_instance %>), class: "btn btn-sm btn-outline-primary" %>
              <%%= link_to "Excluir", [<%= parent_instance_var %>, <%= child_instance %>], data: { turbo_method: :delete, turbo_confirm: "Tem certeza?" }, class: "btn btn-sm btn-outline-danger" %>
            </div>
          </div>
        <%% end %>
      </div>

      <%%= link_to "Novo(a) <%= child_class %>", new_<%= parent_instance %>_<%= child_instance %>_path(<%= parent_instance_var %>), class: "btn btn-primary" %>
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/views/show.html.erb" do
    <<~'ERBDOC'
      <h1><%= child_class %></h1>

      <%%= render @<%= child_instance %> %>

      <div class="mt-3">
        <%%= link_to "Editar", edit_<%= parent_instance %>_<%= child_instance %>_path(<%= parent_instance_var %>, @<%= child_instance %>), class: "btn btn-outline-primary" %>
        <%%= link_to "Voltar", <%= parent_instance %>_<%= child_path %>_path(<%= parent_instance_var %>), class: "btn btn-outline-secondary" %>
      </div>
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/views/new.html.erb" do
    <<~'ERBDOC'
      <h1>Novo(a) <%= child_class %></h1>

      <%%= render "form", <%= child_instance %>: @<%= child_instance %> %>

      <div class="mt-3">
        <%%= link_to "Voltar", <%= parent_instance %>_<%= child_path %>_path(<%= parent_instance_var %>), class: "btn btn-outline-secondary" %>
      </div>
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/views/edit.html.erb" do
    <<~'ERBDOC'
      <h1>Editando <%= child_class %></h1>

      <%%= render "form", <%= child_instance %>: @<%= child_instance %> %>

      <div class="mt-3">
        <%%= link_to "Ver", [<%= parent_instance_var %>, @<%= child_instance %>], class: "btn btn-outline-secondary" %>
        <%%= link_to "Voltar", <%= parent_instance %>_<%= child_path %>_path(<%= parent_instance_var %>), class: "btn btn-outline-secondary" %>
      </div>
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/views/_form.html.erb" do
    <<~'ERBDOC'
      <%%= simple_form_for([@<%= parent_instance %>, @<%= child_instance %>]) do |f| %>
        <%% if @<%= child_instance %>.errors.any? %>
          <div class="alert alert-danger">
            <h5><%%= pluralize(@<%= child_instance %>.errors.count, "error") %> impediram este registro:</h5>
            <ul class="mb-0">
              <%% @<%= child_instance %>.errors.full_messages.each do |message| %>
                <li><%%= message %></li>
              <%% end %>
            </ul>
          </div>
        <%% end %>

      <% fields_with_types.each do |field| -%>
        <%%= f.input :<%= field[:name] %> %>
      <% end -%>

        <%%= f.button :submit, class: "btn btn-primary" %>
      <%% end %>
    ERBDOC
  end

  create_file "lib/generators/nested_resource/templates/views/_child.html.erb" do
    <<~'ERBDOC'
      <div class="<%= child_instance %>">
      <% fields_with_types.each do |field| -%>
        <p>
          <strong><%= field[:name].titleize %>:</strong>
          <%%= <%= child_instance %>.<%= field[:name] %> %>
        </p>
      <% end -%>
      </div>
    ERBDOC
  end

  # =========================================================================
  # 8. Instalar gerador de recurso Devise (devise_resource)
  #
  # Uso:
  #   rails g devise_resource:scaffold DeviseModel ResourceModel field1:type field2:type
  #
  # Exemplo:
  #   rails g devise_resource:scaffold User Post title:string body:text
  # =========================================================================

  create_file "lib/generators/devise_resource/scaffold_generator.rb" do
    <<~'RUBYW'
      # frozen_string_literal: true

      require "rails/generators"
      require "rails/generators/active_record"

      module DeviseResource
        class ScaffoldGenerator < Rails::Generators::NamedBase
          source_root File.expand_path("templates", __dir__)

          argument :resource_model, type: :string, desc: "Modelo do recurso a ser criado (ex: Post)"
          argument :fields, type: :array, default: [], banner: "field:type"

          # --- Helpers para o modelo Devise ---

          def devise_model
            name
          end

          def devise_instance
            devise_model.underscore
          end

          def devise_instance_var
            "@#{devise_instance}"
          end

          def devise_class
            devise_model.classify
          end

          def current_devise_user
            "current_#{devise_instance}"
          end

          def authenticate_devise_user!
            "authenticate_#{devise_instance}!"
          end

          # --- Helpers para o recurso (scaffold) ---

          def resource_instance
            resource_model.underscore
          end

          def resource_path
            resource_model.underscore.pluralize
          end

          def resource_class
            resource_model.classify
          end

          def resource_instance_var
            "@#{resource_instance}"
          end

          def resource_plural_var
            "@#{resource_path}"
          end

          # --- Helpers para campos ---

          def fields_with_types
            fields.map do |f|
              field_name, field_type = f.split(":")
              { name: field_name, type: field_type || "string" }
            end
          end

          def permitted_params
            fields.map { |f| ":#{f.split(':').first}" }.join(", ")
          end

          # --- Gerar todos os arquivos ---

          def generate_all
            template_migration
            template_model
            update_devise_model
            template_controller
            template_views
            template_routes
            say "\n✅ Recurso Devise '#{resource_class}' criado com sucesso para o usuário '#{devise_class}'!", :green
            say "Rota 'resources :#{resource_path}' adicionada em config/routes.rb", :green
          end

          private

          def template_migration
            timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
            template "migration.rb.erb",
                     "db/migrate/#{timestamp}_create_#{resource_path}.rb"
          end

          def template_model
            template "model.rb.erb", "app/models/#{resource_instance}.rb"
          end

          def update_devise_model
            path = "app/models/#{devise_instance}.rb"
            if File.exist?(File.join(destination_root, path))
              say "  Model Devise #{devise_class} encontrado. Adicionando associação has_many :#{resource_path}...", :yellow
              inject_into_class path, devise_class do
                "  has_many :#{resource_path}, dependent: :destroy\n"
              end
            else
              say "  Model #{devise_class} não encontrado em #{path}. Lembre-se de adicionar 'has_many :#{resource_path}, dependent: :destroy' no model Devise.", :red
            end
          end

          def template_controller
            template "controller.rb.erb",
                     "app/controllers/#{resource_path}_controller.rb"
          end

          def template_views
            empty_directory "app/views/#{resource_path}"

            template "views/index.html.erb",
                     "app/views/#{resource_path}/index.html.erb"
            template "views/show.html.erb",
                     "app/views/#{resource_path}/show.html.erb"
            template "views/new.html.erb",
                     "app/views/#{resource_path}/new.html.erb"
            template "views/edit.html.erb",
                     "app/views/#{resource_path}/edit.html.erb"
            template "views/_form.html.erb",
                     "app/views/#{resource_path}/_form.html.erb"
            template "views/_resource.html.erb",
                     "app/views/#{resource_path}/_#{resource_instance}.html.erb"
          end

          def template_routes
            routes_file = "config/routes.rb"
            routes_content = File.read(File.join(destination_root, routes_file))

            if routes_content.include?("resources :#{resource_path}")
              say "  Rota para #{resource_path} já existe em routes.rb", :yellow
            else
              route "resources :#{resource_path}"
            end
          rescue Errno::ENOENT
            say "  Não foi possível ler routes.rb", :red
          end
        end
      end
    RUBYW
  end

  create_file "lib/generators/devise_resource/templates/migration.rb.erb" do
    <<~'ERBDOC'
      class Create<%= resource_path.camelize %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
        def change
          create_table :<%= resource_path %> do |t|
            t.references :<%= devise_instance %>, null: false, foreign_key: true
      <% fields_with_types.each do |field| -%>
            t.<%= field[:type] %> :<%= field[:name] %>
      <% end -%>

            t.timestamps
          end
        end
      end
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/model.rb.erb" do
    <<~'ERBDOC'
      class <%= resource_class %> < ApplicationRecord
        belongs_to :<%= devise_instance %>
      end
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/controller.rb.erb" do
    <<~'ERBDOC'
      class <%= resource_path.camelize %>Controller < ApplicationController
        before_action :<%= authenticate_devise_user! %>
        before_action :set_<%= resource_instance %>, only: %i[show edit update destroy]

        def index
          <%= resource_plural_var %> = <%= current_devise_user %>.<%= resource_path %>
        end

        def show; end

        def new
          <%= resource_instance_var %> = <%= current_devise_user %>.<%= resource_path %>.build
        end

        def edit; end

        def create
          <%= resource_instance_var %> = <%= current_devise_user %>.<%= resource_path %>.build(<%= resource_instance %>_params)

          if <%= resource_instance_var %>.save
            redirect_to <%= resource_instance_var %>, notice: "<%= resource_class %> criado com sucesso."
          else
            render :new, status: :unprocessable_entity
          end
        end

        def update
          if <%= resource_instance_var %>.update(<%= resource_instance %>_params)
            redirect_to <%= resource_instance_var %>, notice: "<%= resource_class %> atualizado com sucesso."
          else
            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          <%= resource_instance_var %>.destroy!
          redirect_to <%= resource_path %>_url, status: :see_other, notice: "<%= resource_class %> removido com sucesso."
        end

        private

        def set_<%= resource_instance %>
          <%= resource_instance_var %> = <%= current_devise_user %>.<%= resource_path %>.find(params[:id])
        end

        def <%= resource_instance %>_params
          params.require(:<%= resource_instance %>).permit(<%= permitted_params %>)
        end
      end
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/views/index.html.erb" do
    <<~'ERBDOC'
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1><%= resource_path.humanize %></h1>
        <%%= link_to "Novo(a) <%= resource_class %>", new_<%= resource_instance %>_path, class: "btn btn-primary" %>
      </div>

      <div id="<%= resource_path %>">
        <%% <%= resource_plural_var %>.each do |<%= resource_instance %>| %>
          <div class="card mb-3">
            <div class="card-body">
              <%%= render "<%= resource_instance %>", <%= resource_instance %>: <%= resource_instance %> %>
              <div class="mt-3">
                <%%= link_to "Ver", <%= resource_instance %>, class: "btn btn-sm btn-outline-secondary" %>
                <%%= link_to "Editar", edit_<%= resource_instance %>_path(<%= resource_instance %>), class: "btn btn-sm btn-outline-primary" %>
                <%%= link_to "Excluir", <%= resource_instance %>, data: { turbo_method: :delete, turbo_confirm: "Tem certeza?" }, class: "btn btn-sm btn-outline-danger" %>
              </div>
            </div>
          </div>
        <%% end %>
      </div>
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/views/show.html.erb" do
    <<~'ERBDOC'
      <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h2><%= resource_class %> #<%%= <%= resource_instance_var %>.id %></h2>
          <div>
            <%%= link_to "Editar", edit_<%= resource_instance %>_path(<%= resource_instance_var %>), class: "btn btn-outline-primary btn-sm" %>
            <%%= link_to "Voltar", <%= resource_path %>_path, class: "btn btn-outline-secondary btn-sm" %>
          </div>
        </div>
        <div class="card-body">
          <%%= render <%= resource_instance_var %> %>
        </div>
      </div>
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/views/new.html.erb" do
    <<~'ERBDOC'
      <h1>Novo(a) <%= resource_class %></h1>

      <div class="card p-4 mb-3">
        <%%= render "form", <%= resource_instance %>: <%= resource_instance_var %> %>
      </div>

      <%%= link_to "Voltar para <%= resource_path.humanize %>", <%= resource_path %>_path, class: "btn btn-secondary mt-2" %>
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/views/edit.html.erb" do
    <<~'ERBDOC'
      <h1>Editar <%= resource_class %></h1>

      <div class="card p-4 mb-3">
        <%%= render "form", <%= resource_instance %>: <%= resource_instance_var %> %>
      </div>

      <%%= link_to "Ver", <%= resource_instance_var %>, class: "btn btn-outline-primary mt-2 me-2" %>
      <%%= link_to "Voltar para <%= resource_path.humanize %>", <%= resource_path %>_path, class: "btn btn-secondary mt-2" %>
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/views/_form.html.erb" do
    <<~'ERBDOC'
      <%%= simple_form_for(<%= resource_instance %>) do |f| %>
        <%% if <%= resource_instance %>.errors.any? %>
          <div class="alert alert-danger">
            <h5><%%= pluralize(<%= resource_instance %>.errors.count, "erro") %> impediram este registro de ser salvo:</h5>
            <ul class="mb-0">
              <%% <%= resource_instance %>.errors.full_messages.each do |message| %>
                <li><%%= message %></li>
              <%% end %>
            </ul>
          </div>
        <%% end %>

      <% fields_with_types.each do |field| -%>
        <%%= f.input :<%= field[:name] %> %>
      <% end -%>

        <%%= f.button :submit, class: "btn btn-primary mt-3" %>
      <%% end %>
    ERBDOC
  end

  create_file "lib/generators/devise_resource/templates/views/_resource.html.erb" do
    <<~'ERBDOC'
      <div id="<%%= dom_id <%= resource_instance %> %>">
      <% fields_with_types.each do |field| -%>
        <p>
          <strong><%= field[:name].humanize %>:</strong>
          <%%= <%= resource_instance %>.<%= field[:name] %> %>
        </p>
      <% end -%>
      </div>
    ERBDOC
  end

  # 9. Git initial commit
  git :init
  git add: "."
  git commit: %( -m "Initial commit: Rails com esbuild, Bootstrap, Devise, Pundit e SimpleForm" )

  say "\n========================================================", :green
  say " Projeto Rails configurado com sucesso!", :green
  say " Stack: esbuild, Bootstrap, Devise, Pundit, SimpleForm", :green
  say " Geradores: nested_resource:scaffold, devise_resource:scaffold", :green
  say "========================================================", :green
  say "\nExemplos de uso:", :cyan
  say "  rails g nested_resource:scaffold Band Song title:string duration:integer", :cyan
  say "  rails g devise_resource:scaffold User Post title:string body:text", :cyan
  say "\n"
end
