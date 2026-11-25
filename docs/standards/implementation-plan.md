# Standard: Implementation Plan & Tasks (Redmine Plugin)

## Language and Style

* Write completely in English (`en-US`).
* Use a professional technical style, concisely, without unnecessary large code dumps.
* Keep names of classes, modules, methods, variables, tables, settings, routes, and files in English as in the code.
* Every technical decision must be grounded in requirements from the approved specification (`docs/spec/...`, `FR-###`).

---

## Implementation Plan Structure

### 1. Task Overview and Context

* Link to the specification in `docs/spec/` and list of implemented requirements (`FR-###`, user scenarios `P1`–`P3`).
* Brief summary of the technical approach and expected outcome.
* **Technical Context**: target Redmine versions (6.0 / 6.1 / 7.0), Ruby / Rails, DBMS (PostgreSQL + MySQL), load benchmark (~200k issues, ~10k open).

### 2. Research and Architectural Decisions (Phase 0: Research)

Before designing classes and tables, record the results of analyzing the Redmine and plugin codebase:

* which built-in Redmine core mechanisms are reused (`ApplicationController#find_issue`, `find_project`, `authorize`, `Issue#safe_attributes`, `WorkflowPermission`, existing locales in `redmine/config/locales/`, etc.);
* verification that there are no conflicts with other installed plugins (especially when using hooks, Deface overrides, and patches);
* for each non-trivial choice, record:
  * **Decision**: what was chosen;
  * **Rationale**: why it was chosen;
  * **Alternatives considered**: why alternative approaches were rejected.

### 3. Standards Compliance Check (Pre-Implementation Gates)

Mandatory checklist before detailing the implementation:

* [ ] **Gate 1 — Minimal Invasiveness (Extension Point Gate)**: the least invasive extension mechanism is selected in order of priority: `View/Controller Hook` → `Helper / Service / Query` → `Deface Override` → `Module#prepend Patch`. Direct modification of Redmine core and `alias_method` are not used.
* [ ] **Gate 2 — Reuse and Simplicity (Simplicity & Anti-Abstraction Gate)**: built-in `ApplicationController` methods and Redmine models are used without duplicate wrappers; there are no speculative abstractions "for the future" not required by current `FR-###`; the `lib/plugin_name/` structure is Zeitwerk-compatible.
* [ ] **Gate 3 — Security and Access Control (Permissions & Visibility Gate)**: all actions are protected by `permission`, queries respect `visible`, writes go through `safe_attributes`, and leakage of hidden fields (`hide_mail`, private notes, etc.) is prevented.
* [ ] **Gate 4 — Database and Scale (DB & Scale Gate)**: migrations use `ActiveRecord::Migration[5.2]` and `# frozen_string_literal: true`, are compatible with PostgreSQL and MySQL, explicitly define `null` and `default`, include necessary indexes, and prevent N+1 queries on datasets of ~200k issues.
* [ ] **Gate 5 — Localization, MCP, and Code Quality (I18n & Quality Gate)**: existing Redmine localization keys are reused, new keys are added to all 11 mandatory languages; new MCP tool names do not exceed 45 characters (`[a-z0-9_]`); cognitive complexity limits (≤ 15) and the ban on comments in application code are respected.

#### Complexity Tracking / Deviations

> Filled out **only** when core patches (`Module#prepend`), `Deface::Override`, custom SQL queries, or additional abstractions are present:

| Decision / Deviation | Why Necessary (reference to `FR-###`) | Why a Simpler Option (Hook / built-in core method) Was Insufficient |
| -------------------- | ------------------------------------- | ------------------------------------------------------------------- |
| `[e.g., Patch Issue]` | `[FR-003: intercept validation]` | `[The built-in hook runs after validation and cannot abort it]` |

### 4. Database Changes and Canonical Data Model

* New migrations (`db/migrate/...`, `ActiveRecord::Migration[5.2]`).
* New tables and columns with **canonical field constraints** (`Entity.field`: type, `null`, `default`, length limits, allowed values/enum, uniqueness).
* Changes to existing tables (without editing already merged or applied migrations).
* Indexes and foreign keys (taking PostgreSQL and MySQL compatibility into account).

### 5. Models and Business Logic

* New models in `app/models/plugin_name/` and modifications to existing models.
* Services, formatters, validators, serializers, and clients in `lib/plugin_name/` (organized by domain or class type).
* Hooks (`lib/plugin_name/hooks/`, explicit `require` in `lib/plugin_name.rb` outside `after_initialize`).
* Patches (`lib/plugin_name/patches/`, via `Module#prepend` with `unless CoreClass <= Patch` check inside `after_initialize`).
* Validations, `safe_attributes`, and permission checks.

### 6. Controllers, API/MCP Contracts, and UI

* New controllers and actions, reusing `ApplicationController` filters (`find_issue`, `find_project`, `authorize`).
* Routes (`config/routes.rb`).
* Views (`app/views/plugin_name/`), helpers (no DB queries), Deface overrides (`app/overrides/` with `original` checksum and markup extracted to a partial), frontend components (JS / Vue 3 Composition API).
* External interface contracts (HTTP route parameters, JSON responses, schemas, and ≤ 45-character limit for MCP tools).
* Menu items, project modules, administration pages, localization (`config/locales/*.yml` for 11 languages).

### 7. Settings and Configuration

* Plugin settings (`settings`: keys, default values, safe reading with `table_exists?('settings')` check).
* Permission registration (`permission`) and project modules (`project_module`).
* Plugin initialization (`init.rb` — only `Redmine::Plugin.register` declaration with `name` and `version` in the first lines and requiring `lib/plugin_name.rb`).
* Rake tasks (`lib/tasks/*.rake`), background jobs, Sidekiq, Redis (if needed).

### 8. Testing

* Unit tests (`test/unit/`) and functional tests (`test/functional/`) in **Minitest**, grouped by logical blocks with shared helpers extracted to `test/test_helper.rb`.
* Traceability of tests to the specification (`# SPEC: docs/spec/... (FR-###)`).
* Positive and negative scenarios (including checking `403`/`404` when permissions are missing, a module/setting is disabled, or objects belong to others or are not visible).
* Commands to run tests and RuboCop:
  * `bundle exec rake redmine:plugins:test NAME=plugin_name`
  * `bundle exec rails test plugins/plugin_name/test/...`
  * `bundle exec rubocop -c plugins/plugin_name/.rubocop.yml plugins/plugin_name`

---

## Task Breakdown into Executable Tasks

For sequential and controlled implementation, the plan is supplemented with a phased task checklist (either within the plan itself or in `tasks.md` when using `/speckit-tasks`):

### Task Format

Each task is formatted as a checklist line:

```text
- [ ] T001 [P?] [US# / FR-###] Action description with exact file path
```

* **`T001`, `T002`, ...** — sequential task number;
* **`[P]`** — added only if the task can be executed in parallel (touches different files and has no dependency on unfinished tasks);
* **`[US1]`, `[FR-001]`** — reference to the user story and/or functional requirement from the SPEC (for tasks tied to DB fields, also specify `Entity.field` and its canonical constraints);
* **File path** — exact relative path within the plugin directory.

### Phase Order

1. **Phase 1: Infrastructure and DB (Setup & Foundational)** — registration in `init.rb`, entry point `lib/plugin_name.rb`, migrations in `db/migrate/`, base settings, and permissions.
2. **Phase 2+: User Stories by Priority (`P1` MVP → `P2` → `P3`)** — within each scenario: models/services → controllers/routes/hooks/views/locales (11 languages) → Minitest unit and functional tests. Each scenario must be an independently verifiable increment.
3. **Final Phase: Quality Check and Convergence** — `rubocop` check, running all plugin tests, auditing the implementation against the specification (`Converge`), updating `docs/spec/00-general.md`, and adding an entry to `CHANGELOG.md`.

---

## Pre-Implementation Consistency Check (Pre-Implementation Analysis)

Before starting to code (`Implement`), the plan and task list are verified for consistency with the specification (`Analyze`):

* **Requirement coverage**: every `FR-###` requirement and every scenario from the SPEC is covered by at least one implementation task and one test scenario;
* **No unrequested tasks**: there are no tasks unrelated to SPEC requirements;
* **Data constraint consistency**: types, `null`, `default`, and validations of every `Entity.field` in tasks and models do not contradict the DB section and the SPEC;
* **Standards compliance**: all Pre-Implementation Gates have passed or are explicitly justified in the deviations table.
