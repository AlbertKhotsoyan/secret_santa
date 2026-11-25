# Redmine Plugin Standards

## 1. General Principles

* The plugin must be compatible with the target Redmine and Ruby on Rails versions specified in the project.
* Changes must be minimal and localized. Direct modification of Redmine core source code is prohibited; only hooks, patches, and extension mechanisms may be used.
* The plugin structure must be predictable and repeatable across all project modules.
* Code must be readable, testable, and free of duplication.

## 2. Plugin Structure

* Use the standard Redmine plugin directory structure:

  * `init.rb`
  * `lib/plugin_name/`
  * `app/controllers/`
  * `app/helpers/plugin_name/`
  * `app/models/plugin_name/`
  * `app/views/plugin_name/`
  * `app/overrides/`
  * `config/routes.rb`
  * `db/migrate/`
  * `test/`
* Name files and directories consistently, without arbitrary abbreviations.
* Separate logic by responsibility whenever possible: models, services, helpers, views, migrations.
* Patches, hooks, and services go in `lib/`.
* Models, controllers, views, and view overrides go in `app/`.
* Controllers have no namespace; models and other components live under the `PluginName::` module.
* Routes go in `config/routes.rb`.
* `init.rb` is only for plugin registration (`Redmine::Plugin.register`: name, version, permissions, menu, settings). No heavy logic, side effects, or lists of `require` / `require_relative` (except a single `require` of the entry point `lib/plugin_name.rb` at the end of the file, if that is the project convention).
* Move code loading (`require`, patches, hooks, services) into the entry point `lib/plugin_name.rb` and files under `lib/plugin_name/`.
* In `lib/plugin_name.rb`:
  * **hooks** — load via an explicit `require` of the hook file, not by referencing a Zeitwerk constant and not inside `after_initialize`;
  * **patches** and code with side effects on core classes — place inside `Rails.application.config.after_initialize`;
  * do not replace `after_initialize` with `to_prepare` without a separate decision in the SPEC.
* View overrides (Deface) reside in `app/overrides/` and are picked up by Deface automatically — no separate `require` in `init.rb` / `lib/plugin_name.rb` is needed.
* At the top of `init.rb`, `name` and `version` must be visible in the first lines of the file; otherwise, CI plugin verification may fail.

### Organizing `lib/plugin_name/`

Code in `lib/plugin_name/` must be structured so that the purpose of classes is clear from their path and the directory layout complies with Zeitwerk.

#### General Rules

* Do not place standalone classes and modules **haphazardly** at the root of `lib/plugin_name/`.
* Place new classes into an appropriate subdirectory by default.
* The file path must match the constant name:

  * `lib/plugin_name/hooks/example_hook.rb` → `PluginName::Hooks::ExampleHook`
  * `lib/plugin_name/services/import_service.rb` → `PluginName::Services::ImportService`

#### Structure

Group code:

1. **By domain/subsystem** — if it forms a cohesive functional area.
2. **By class type** — if there is no distinct domain.

Domain directories are preferred.

#### Standard Directories

Use standard groups:

* `services/`, `clients/`, `serializers/`, `formatters/`
* `builders/`, `correctors/`, `validators/`, `queries/`

Do not create a new directory without a real need — it should group multiple classes or an anticipated extension.

#### Root of `lib/plugin_name/`

Only entry points and infrastructure are allowed at the root:

* `settings.rb`
* `mcp.rb`

They must be thin: registration, wiring, facades. Business logic belongs in subdirectories.

#### Rake Tasks

* Place tasks only in `lib/tasks/*.rake`.
* Use the plugin's namespace. Do not rename already published task names without an explicit need (used by cron and client commands).
* Specify `desc` for every public task.
* If a task uses models, settings, or other Rails/Redmine components, depend on `:environment`.
* A `.rake` file must be a thin entry point: parse parameters, call a service, and output the result. Place business logic in plugin classes.
* Use command-line arguments (`ARGV`) for parameters and flags, not environment variables (`ENV`). Use environment variables only for application configuration (e.g., `RAILS_ENV`, API keys).
* Validate required parameters before execution begins and terminate with a clear error message if invalid.
* Do not log secrets, tokens, or other confidential data.
* Make tasks idempotent whenever possible.
* For tasks that may run concurrently (e.g., via cron), provide protection against simultaneous execution if necessary.

#### Example Structure

```text
lib/
  plugin_name.rb
  plugin_name/
    settings.rb
    mcp.rb
    hooks/
    patches/
    services/
    clients/
    serializers/
    formatters/
    builders/
    outline/
      client.rb
      document_serializer.rb
      error_mapper.rb
  tasks/
    example.rake
```

## 3. Naming

* Names of classes, modules, methods, and constants must be meaningful and reflect their purpose.
* Name constants and event flags following a consistent pattern.
* Use stable and clear identifiers for setting keys, permissions, and translations.
* Do not use ambiguous abbreviations except those widely accepted in the project.

### MCP Tool Names

* The full tool name in `tools/list` is constructed as `redmine_<plugin_id without leading redmine_>_<name>`: `plugin_id :redmine_advanced_checklists` + `name: 'rename_item'` → `redmine_advanced_checklists_rename_item`.
* Full name — **no longer than 45 characters**, only `[a-z0-9_]`. The MCP client prepends a server prefix (`mcp__redmine__`, `mcp__redmine-cinet__` — up to 19 characters), and LLM providers limit function names to 64 characters; otherwise, the client rejects **all** tools from the server.
* Redmine MCP refuses to register a tool longer than 46 characters (logging an error), but do not rely on that — the limit for new tools is 45.
* Calculate the length before writing code: `45 − prefix length` = maximum length for the short `name`. Example: prefix `redmine_advanced_checklists_` is 28 characters, leaving 17 for `name`.
* Short `name` — `<verb>_<entity>` without repeating the plugin name: `create_item`, not `create_checklist_item` in the checklists plugin.
* Renaming a published tool is allowed only with `aliases: ['old_name']` so the old name continues to work; record new names in the plugin's SPEC.
* A plugin test must verify that all of its tools fit within 45 characters.

## 4. Hooks

* Use Redmine hooks to extend the UI and business logic whenever possible without patches.
* A hook must be isolated and perform a single, well-defined task.
* Do not overload a hook with extra logic; extract complex processing into dedicated services.
* Hook handlers must work gracefully when expected data is absent.
* Place hook files in `lib/plugin_name/hooks/` under the `PluginName::Hooks::` module (Zeitwerk-compatible).
* In the entry point `lib/plugin_name.rb`, load hooks via an explicit `require` of the file path, for example:

```ruby
require "#{File.dirname(__FILE__)}/plugin_name/hooks/views_layouts_hook"
```

* Do not load hooks via a "bare" constant reference (`PluginName::Hooks::SomeHook`) instead of `require`.
* Do not place hook `require` statements inside `after_initialize` — hooks must register when the plugin loads; reserve `after_initialize` for patches.

## 5. View Overrides (Deface)

* Use Deface for targeted insertions into core views when no suitable view hook exists or when a hook does not provide the required position in the template.
* Prefer a Redmine hook if it covers the scenario; use Deface when you need to inject into a specific spot in a template.
* For Deface, add the `redmine_plugin_kit` dependency to the plugin's `Gemfile` (pulls in Deface and shared override infrastructure):

```ruby
gem 'redmine_plugin_kit'
```

* Place files in `app/overrides/`. Deface loads them automatically; do not duplicate loading via `require` in `init.rb` or `lib/plugin_name.rb`.
* One file per logical override (or a few closely related overrides for the same screen).
* Structure as a module calling `Deface::Override.new(...)`.
* Specify: `virtual_path` (core template), unique `name`, position (`insert_after` / `insert_before` / `replace`, etc.), `original` (checksum of the original fragment to verify compatibility with the Redmine version).
* Extract markup into a plugin partial via `partial: 'plugin_name/...'`. Use `text:` only for short insertions or conditional `render`.
* Keep business logic out of the override: use a helper/settings for display conditions and services for complex processing.

Example:

```ruby
module ExampleViewInjection
  Deface::Override.new(
    virtual_path: 'issues/show',
    name: 'plugin_name_example_injection',
    insert_after: 'div.contextual',
    original: 'checksum_of_original_fragment',
    partial: 'plugin_name/example_partial'
  )
end
```

Example with a condition via `text:`:

```ruby
module ExampleConditionalInjection
  Deface::Override.new(
    virtual_path: 'search/index',
    name: 'plugin_name_conditional_injection',
    insert_after: 'h2',
    original: 'checksum_of_original_fragment',
    text: <<~ERB
      <%= render partial: 'plugin_name/example_partial' if PluginNameHelper.show_example? %>
    ERB
  )
end
```

## 6. Patches

* Apply patches only when hooks, helpers, view overrides, or query extensions are insufficient.
* Patches must be targeted and avoid affecting unrelated behavior.
* When overriding methods, preserve compatibility with Redmine's original logic.
* Override existing methods only via `Module#prepend` and calling `super`.
* Do not use `alias_method`, `alias`, or `alias_method_chain` (`method_with_*` / `method_without_*`) to override methods.
* Structure each patch as a module attached to the class via `prepend`; the overridden method keeps the same name as the original and calls `super`. Override class methods using a separate module via `base.singleton_class.prepend(ClassMethods)`.
* Call `super` with the same signature as the original method (`super` without parentheses forwards arguments and block as-is); if the original result is not needed — document the rationale in the SPEC, not in a code comment.
* Prefix new methods that do not override core methods with the plugin name; they may be added to the same prepended module.
* Add associations, validations, scopes, callbacks, and other class DSL macros via `base.class_eval` inside `self.prepended(base)`.
* Do not reopen Redmine core classes directly — only via a patch module.
* Patches must be idempotent and loaded once: check `RedmineClass <= Patch` before `prepend` (do not use `ancestors.include?` — it is forbidden by RuboCop `Performance/AncestorsInclude`).
* If another plugin patches the same method via `alias_method`, mixing `prepend` and an alias chain can cause infinite recursion (`SystemStackError`) — verify such conflicts with tests alongside installed plugins and document them in the plugin's documentation.

Example:

```ruby
module PluginName
  module Patches
    module RedmineClassPatch
      def self.prepended(base)
        base.class_eval do
          has_many :plugin_name_items, dependent: :destroy
        end
      end

      def method_name(*args)
        result = super
        # ...
        result
      end

      def plugin_name_helper_method
        # ...
      end
    end
  end
end

# rubocop:disable Style/IfUnlessModifier
unless RedmineClass <= PluginName::Patches::RedmineClassPatch
  RedmineClass.prepend(PluginName::Patches::RedmineClassPatch)
end
# rubocop:enable Style/IfUnlessModifier
```

## 7. Permissions

* All user actions must be protected by access permissions.
* Every new controller action must have a corresponding permission.
* Group permissions logically and name them by purpose rather than implementation.
* Enforce permission checks at both the controller level and the view level where appropriate.
* Never rely solely on hiding buttons in the UI.
* The plugin must not bypass Redmine's access control model: respect the same permissions, object visibility (`visible` / `visible_*`), and core restrictions (`safe_attributes`, assignable/addable lists).
* Having permission to perform an operation does not grant access to all associated data. Verify sensitive inclusions (watchers, private notes, email addresses, etc.) using separate permissions or core helpers.
* Response fields must not expose more than Redmine's UI/API exposes under the same permissions (e.g., `hide_mail`).
* Do not perform global searches or return users/PII without an explicit admin- or project-scoped permission.
* Errors must not allow distinguishing between "object does not exist" and "object exists but is inaccessible" if Redmine core does not distinguish them in an analogous scenario (or deliberately unify responses).
* Negative tests for permissions and data exposure are mandatory for tools/APIs that read or modify users, watchers, time entries on behalf of others, attachments, etc.

## 8. Settings

* Plugin settings must be minimal, clear, and documented.
* Each setting must have a meaningful key, a default value, and an expected type.
* Break complex settings down into several simple ones.
* Validate settings upon saving.
* Setting values must not break plugin operation when missing or given invalid input.
* When reading `Setting` / `Setting.plugin_*` during load time (`after_initialize`, class loading, boot-time code), first check that the `settings` table exists. In CI, the table might not exist yet (`db:drop` / `db:create` before `db:migrate`), which would otherwise raise `Table '….settings' doesn't exist`.
* Access settings from menus and UI via deferred `proc` blocks or runtime calls rather than at plugin registration time.

Example of safely reading settings:

```ruby
def plugin_settings
  return {} unless ActiveRecord::Base.connection.table_exists?('settings')

  Setting.plugin_example || {}
end
```

## 9. Controllers, Helpers, and Views

* Controllers must contain only orchestration logic, without heavy business logic.
* Extract data preparation for rendering into models, services, or presenters.
* Views must be simple and free of complex computations.
* Forms must validate input data and display errors to the user.

### Core `ApplicationController` Methods

* Do not duplicate object-loading and authorization methods in the plugin that already exist in Redmine's `ApplicationController`.
* For loading an issue by `:id`, use the built-in `find_issue` (`before_action :find_issue`) rather than a custom implementation via `Issue.visible.find` / `Issue.find` + `render_404`.
* Similarly, prefer built-in core helpers when they cover the scenario: `find_project`, `find_project_by_project_id`, `find_issues`, `authorize`, `authorize_global`, `require_login`, etc.
* Override such a method in a plugin controller only when **deliberately different** behavior is required; otherwise, preserve the behavior and error semantics of Redmine core (e.g., `Unauthorized` for an existing but non-visible issue instead of masking it as `404`).

### Helpers

* Helpers are intended solely for data transformation and view presentation concepts: formatting, rendering composite UI elements, and conditional markup.
* Database queries inside helpers are prohibited. All DB queries must be encapsulated in models and passed to helpers as already prepared data.
* A helper must not know where data comes from — only how to display it.

## 10. Migrations and Data

* Each database schema change must be structured as a separate migration.
* Migrations must be reversible whenever possible.
* New columns, indexes, and associations must be created with performance and data integrity in mind.
* Do not modify data unnecessarily within the same migrations that alter the schema if doing so complicates maintenance.

## 11. Testing

* Write tests in **Minitest** — no other test frameworks are used.
* Allowed test types: **unit** (models, services, helpers) and **functional** (controllers).
* System and integration tests are not needed.
* Every significant feature must have tests.
* Critical scenarios must be covered by automated tests.
* Tests must be isolated and not depend on random system state.
* When modifying patches, hooks, view overrides, and permissions, tests are mandatory.
* New code (models, helpers, services, controllers, overrides) must be covered by tests in the same merge request.

### Organizing Test Files

* Do not create a new test file for every small feature or individual scenario.
* Keep tests for a single **logical block** (domain, service, controller, import) in a **single file**; add new `test` blocks to the existing file if it covers the same area.
* Create a new file only if the block differs substantially (a different controller or domain) or the existing file has grown too large to maintain comfortably.
* Use subdirectories under `test/unit/` and `test/functional/` grouped by domain or scenario type (e.g., `test/unit/models/`, `test/functional/import/`).
* Name files after the **model, service, or controller**, not after individual methods or scenarios. Add new tests for the same area to the existing file rather than creating another narrowly named file alongside it.

### Test Helper Methods

* Place shared test helper methods (setting up users, roles, permissions, fixtures, response assertions) in `test/test_helper.rb` on the plugin's base test class rather than in individual test files.
* Do not duplicate identical environment setup across every `*_test.rb`.
* Within a test file, extract common setup into `setup` or private helpers rather than copying it across tests — SonarQube flags duplication in tests as well.
* Combine tests that differ only in input values by iterating over cases or calling a shared helper.
* Keep only test scenarios (`test` blocks) and local logic used exclusively by that file inside a specific test file.
* Prefer existing Redmine fixtures for users, roles, and project members; do not create records in tests when suitable fixture data already exists.

Example structure:

```text
test/
  unit/
    models/
      issue_test.rb
      time_entry_test.rb
    services/
      import_service_test.rb
  functional/
    issues/
      issues_controller_test.rb
    import/
      import_controller_test.rb
```

## 12. Compatibility and Maintenance

* Changes must respect backward compatibility when required by the project.
* Before adding new behavior, check its impact on existing plugins and extensions.
* Code must be maintainable without deep knowledge of internal implementation details.
* Any non-trivial decision must be clear from the code structure and naming.

## 13. Documentation

* New public plugin capabilities must be briefly documented.
* Provide explanations for settings, permissions, and non-standard scenarios.
* Code is written without comments (see `ruby-standards.md`, §10); explanations belong in `README.md` and `docs/spec/`.
