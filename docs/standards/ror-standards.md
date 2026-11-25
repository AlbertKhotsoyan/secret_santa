# RoR Standards for Redmine

## 1. General Principles

* The plugin must extend Redmine without modifying core whenever possible.
* Prefer explicit, simple logic over magic and non-obvious callbacks.
* Code must be predictable for long-term maintenance: minimal side effects, minimal coupling, and clear boundaries of responsibility.
* Always verify new behavior for compatibility with the target Redmine version and existing plugins first.

## 2. Code Structure

* Separate logic by layer: controller, model, service, helper, view.
* Keep only orchestration logic in controllers: loading data, checking permissions, selecting the response.
* Extract complex calculations, data preparation, and business rules out of controllers into models or services.
* Do not duplicate identical logic across multiple places; extract shared code into `lib/`, services, or concerns.

## 3. ActiveRecord and SQL

* Avoid unnecessary database queries; check for N+1 issues and eager-load associations where appropriate.
* Use `joins`, `includes`, `preload`, `select`, and `pluck` deliberately rather than out of habit.
* Do not build complex SQL inside views or controllers.
* For large datasets, avoid loading entire collections into memory unnecessarily.
* Migrations and queries must be compatible with the project's target DBMSs.

## 4. Controllers

* Each action must have a clear purpose and a single primary scenario.
* Verify permissions and the presence of required objects before executing an action.
* Do not mix parameter handling, business logic, and response formatting in one place.
* Use standard Redmine response formats where appropriate.
* Do not copy Redmine `ApplicationController` methods (`find_issue`, `find_project`, `authorize`, etc.) into the plugin — see [redmine-standards.md](redmine-standards.md) §9.

## 5. Models and Callbacks

* Use callbacks only when they cannot be avoided.
* Do not place complex business logic or external requests inside callbacks.
* Validations must reflect business rules, not just DB constraints.
* Name model associations and methods meaningfully without creating ambiguity.

## 6. Services and Patterns

* Extract recurring scenarios into services rather than scattering them across controllers and models.
* A service must solve a single task and have clear inputs and outputs.
* Do not make services overly "fat"; split them if their boundaries of responsibility grow.

## 7. Views

* Do not place complex business logic in `.html.erb` or `.slim` templates.
* Keep only data display, simple conditions, and helper calls in views.
* Avoid deeply nested conditionals and repeated markup fragments.
* Use partials for recurring blocks.

## 8. Access Control and Security

* Any action that modifies data must be protected by a permission.
* Do not rely solely on hiding buttons in the UI.
* Validate input parameters and never trust data from forms or URLs.
* Do not store secrets (passwords, tokens, keys) in code, views, or the repository.
* Do not inject user data into HTML without escaping: use `html_safe` / `raw` only for known-safe markup.
* Load external resources only over `https://`.
* When writing through models, use `safe_attributes` (or the core equivalent) rather than direct attribute assignment that bypasses permission checks.
* Restrict queries for users and related entities using core scopes (`visible`, `addable_*`, `assignable_*`) rather than `Model.find` / `Model.active` by arbitrary ID.

## 9. Hooks, Patches, and Extensions

* Use Redmine hooks, helpers, concerns, and extension points first.
* Apply patches only if no other sustainable mechanism exists.
* Patches must be targeted and easy to read.
* Do not copy large chunks of Redmine core source code unnecessarily.

## 10. Errors and Exceptions

* Errors must be clear to both the user and the logs.
* Do not swallow exceptions without a reason.
* Handle external integrations and unstable operations explicitly.
* The user interface must not crash when optional data is missing.

## 11. Localization

* Extract all user-facing strings into translation files.
* Do not hardcode text in templates or Ruby code if the string is visible to the user.
* Translation keys must be stable and meaningful.

## 12. RuboCop

* The plugin's Ruby code must comply with RuboCop.
* Use the plugin's configuration: `.rubocop.yml` at the plugin root.
* Do not use Redmine core's `.rubocop.yml` to check plugin code.
* New and modified files must not introduce RuboCop offenses; use `rubocop:disable` only sparingly and with a clear reason (as in patch examples).

## 13. What RuboCop Should Not Replace

This document defines rules that RuboCop typically cannot enforce automatically:

* architectural boundaries between layers;
* appropriateness of callbacks, services, and patches;
* SQL quality and query count;
* correctness of permissions and security;
* readability and maintainability of business logic;
* using Redmine hooks instead of unnecessary overrides.

## 14. Pre-Push Checklist

* [ ] No string literals repeated 3+ times in the same file (including tests).
* [ ] No copy-pasted blocks of code or tests — shared logic is extracted to helpers or `setup`.
* [ ] No commented-out code, debug output, or `TODO` without an issue number.
* [ ] No empty `rescue` / `catch` blocks or unused variables and parameters.
* [ ] Methods are short, nesting is no deeper than 3 levels, and there are no nested ternary operators.
* [ ] New code is covered by tests and all tests pass.
* [ ] `rubocop` reports no offenses.
