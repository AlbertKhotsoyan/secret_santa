# Development Rules

## Standards

You must adhere to the standards from the [`standards/`](standards/) directory:

| File                                                       | Description                                                                                                    |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [implementation-plan.md](standards/implementation-plan.md) | Format and language of the Implementation Plan for Redmine plugin tasks                                        |
| [redmine-standards.md](standards/redmine-standards.md)     | General rules for Redmine plugin development: structure, hooks, Deface overrides, patches, permissions, settings |
| [ror-standards.md](standards/ror-standards.md)             | Rails / Ruby on Rails standards: controllers, models, views, callbacks, RuboCop, SonarQube                     |
| [ruby-standards.md](standards/ruby-standards.md)           | Pure Ruby standards: style, naming, methods, composition, collections, errors, services                        |
| [vue-standards.md](standards/vue-standards.md)             | Vue / frontend standards: components, props, emits, state, API, naming                                         |
| [spec-standards.md](standards/spec-standards.md)           | Rules for writing and structuring tests and specifications                                                     |
| [i18n-standards.md](standards/i18n-standards.md)           | Localization standards: translation keys, string formats, pluralization                                        |
| [db-standards.md](standards/db-standards.md)               | Standards for migrations, indexes, associations, and data manipulation                                         |

---

# Development Rules for Redmine Plugins

## SPEC-FIRST Mode (Spec-Driven Development / SDD)

You operate in a specification-driven development process (SDD / Spec-Kit approach).

**The specification is the single source of truth. The code in a Redmine plugin is merely an implementation of the approved SPEC and Implementation Plan.**

### Development Process Stages (SDD Pipeline)

Any task affecting plugin behavior goes through the following stages:

1. **Specify** — analyzing the request and creating/updating a specification in `docs/spec/` according to [`spec-standards.md`](standards/spec-standards.md) with prioritized scenarios (`P1`, `P2`, `P3`), requirement identifiers (`FR-###`), and verification against the requirements quality checklist.
2. **Clarify** — identifying ambiguities and gaps in requirements, formulating targeted questions for the user (with a recommended option and a trade-off/impact table), and recording decisions directly in the SPEC.
3. **Plan & Tasks** — developing a technical plan and a step-by-step task list according to [`implementation-plan.md`](standards/implementation-plan.md) with mandatory verification of architectural gates (Standards / Constitution Gates).
4. **Analyze** — cross-checking `SPEC ↔ Implementation Plan ↔ Tasks ↔ Standards` before writing code: ensuring 100% task coverage for `FR-###` requirements, consistency of DB field constraints, and absence of terminology discrepancies.
5. **Implement** — step-by-step writing of code, migrations, localizations (in 11 languages), and Minitest automated tests strictly according to the approved plan and standards.
6. **Converge** — final audit of the written code and tests against the `SPEC`, `Implementation Plan`, and standards, resolving discrepancies (`missing`, `partial`, `contradicts`, `unrequested`), and updating `CHANGELOG.md`.

---

## Rule 1 — Do Not Write Code Immediately and Resolve Ambiguities

If a task involves changing:

* plugin behavior;
* API / MCP tools;
* UI / views / JS / Vue;
* hooks;
* view overrides (Deface);
* patches;
* permissions;
* settings;
* routes;
* localization;
* migrations and DB schema;
* performance;
* compatibility with Redmine versions;

then **generating code immediately is prohibited**.

You must:

1. Analyze the request and check it across completeness categories (functional boundaries, roles and permissions, data model and lifecycle, UX and errors, impact on Redmine core and other plugins, performance at ~200k issues).
2. If information is insufficient — do not guess critical behavior:
   * mark ambiguous places with `[NEEDS CLARIFICATION: specific question]` (when drafting a SPEC) or ask the user for clarification immediately;
   * prioritize questions by impact: **functional boundaries (Scope) > security and permissions (Permissions) > UX and error handling > technical details**;
   * ask **no more than 3–5 key questions** per iteration;
   * for each multi-option question, propose a **recommended option** with brief rationale and a table of alternatives (`Option | Description | Consequences`).
3. Create or update the specification in `docs/spec/` following `spec-standards.md`, integrating the user's answers into the relevant SPEC sections.
4. Prepare the Implementation Plan and task list following `implementation-plan.md`, run the consistency check (`Analyze`), and wait for user approval.
5. Proceed to writing code (`Implement`) only after confirmation.

---

## Rule 2 — Code Must Match the SPEC (Traceability)

Every change in the code must directly correspond to an approved specification and `FR-###` requirements.

* If a change is not covered by a test referencing the SPEC (`# SPEC: docs/spec/...` or `# SPEC: docs/spec/... (FR-001)`) or the implementation goes beyond its scope (`unrequested`), such a change is considered invalid.
* In application code (not in tests), SPEC references are not left as comments — code is written without comments (see `ruby-standards.md`, §10).
* Model field and DB table constraints in code and migrations must strictly match the canonical description in the SPEC and Implementation Plan (type, `null`, `default`, length limits, uniqueness, allowed values).

---

## Rule 3 — When the SPEC Does Not Need Updating

The SPEC may be skipped only if the change:

* does not affect plugin behavior;
* is a pure refactoring;
* does not change public contracts;
* does not change business logic;
* does not change permissions, settings, locales, migrations, routes, hooks, or patches.

If in doubt — a SPEC is mandatory.

---

## Rule 4 — Do Not Invent Architecture (Standards & Gate Check)

If an architectural decision is not described in the SPEC or Implementation Plan, you must not make assumptions or implement it "the usual way".

For Redmine, this is especially important for:

* choosing an extension point in order of priority: **Hook → Helper/Service/Query → Deface Override → Patch (`Module#prepend`)**;
* where logic is stored: model, service, helper;
* how permissions are registered and how built-in `ApplicationController` methods (`find_issue`, `find_project`, `authorize`) are used;
* settings structure and safe boot-time reading (`table_exists?('settings')`);
* how translations are updated (checking existing Redmine core keys and translating into all 11 mandatory languages);
* migration format (`ActiveRecord::Migration[5.2]`, compatibility with PostgreSQL and MySQL);
* compatibility approach for Redmine 6.0, 6.1, 7.0.

Any necessary complexity (core patch, Deface override, custom query) must be explicitly justified in the "Complexity Tracking / Deviations" section of the Implementation Plan. If a decision is undefined — ask the user for clarification.

---

## Rule 5 — Automated Tests

### New Tests

New automated tests can be written without separate approval. This is not considered a behavior change. When implementing new functionality, tests are designed before or alongside the code based on the acceptance scenarios from the SPEC.

### Modifying Existing Tests

Modifying existing tests requires approval.

You must:

1. Explain why the current test needs to be changed.
2. Show exactly what will be changed.
3. Wait for explicit confirmation.
4. Only then edit the test.

Reason: existing tests lock in the expected behavior of the Redmine plugin.

---

## Rule 6 — Redmine Specifics Are Mandatory

The SPEC and Implementation Plan for a Redmine plugin must explicitly account for:

* compatibility with the target Redmine version;
* hooks and extension points;
* view overrides (Deface);
* patches and overrides;
* permissions, visibility (`visible`), and `safe_attributes`;
* plugin settings;
* routes and controllers;
* localization (11 mandatory languages);
* migrations and DB schema (PostgreSQL + MySQL);
* query performance (targeted at ~200k issues);
* impact on existing plugins and Redmine core.

---

## Prohibited

* writing code before the SPEC is approved;
* inventing business logic or guessing ambiguous requirements without clarification;
* adding speculative functionality "for the future" (`unrequested`) not tied to SPEC requirements;
* changing architecture without a specification and implementation plan;
* ignoring edge cases and negative permission scenarios;
* violating the `SPEC → CLARIFY → PLAN/TASKS → ANALYZE → IMPLEMENT → CONVERGE` sequence;
* modifying existing automated tests without explaining the reason and getting confirmation;
* making hidden changes in a Redmine plugin under the guise of refactoring.

---

## Allowed

* proposing solution options with a recommended choice and a consequences table;
* discussing architecture and extension points before approving the SPEC and plan;
* clarifying requirements using the ambiguity taxonomy;
* checking artifact consistency (`SPEC`, `Plan`, `Tasks`) and auditing code (`Converge`);
* writing new automated tests with `# SPEC: docs/spec/...` references;
* drafting and revising the SPEC and Implementation Plan based on discussion outcomes.

---

## Rule 7 — CHANGELOG.md

* update `CHANGELOG.md` after completing task implementation;
* follow the existing `CHANGELOG.md` format;
* write concisely, without listing all internal changes;
* one task = one entry in `CHANGELOG`;
* if a task includes many technical changes (refactoring, fixes, validation, logging, API changes, descriptions, internal architecture, etc.), combine them into a single entry describing the resulting functionality;
* `CHANGELOG` must reflect changes noticeable to the user or plugin developer, not the implementation history;
* use `Added`, `Improved`, or `Fixed` sections depending on the nature of the change;
* extract the issue number from the current git branch name (`git status`). If there is no number, leave the square brackets empty.

Example:

```
branch_name - feature-33586
```

Result:

```
[33586]
```

Example `CHANGELOG.md`:

```md
# Changelog

## [Unreleased]

### Added
- Compatibility with Redmine 6.1 [33282];

### Improved
- Performance: Async Email/Webhooks actions on issue and time entry save [33269];

## [1.0.5] - 2026-05-12

### Added
- Issue’s project change in automatic actions [32636];

### Improved
- Action Send email via text field instead of user list [32477];

### Fixed
- Condition filter parameters are now required [32767];
```

Example of combining multiple changes within a single task:

Before:

```md
### Added
- MCP HTTP server [33810];
- Core MCP tools [33810];
- Extension API [33810];
- Validation [33810];
- Audit log [33810];
```

Should be:

```md
### Added
- Initial implementation of the MCP plugin with HTTP server, core tools, extension API, validation, permissions, and audit logging [33810];
```

---

## Rule 8 — Implementation Convergence Check

Before completing a task, you must perform a final audit of the code, localizations, migrations, and automated tests against the approved `SPEC`, `Implementation Plan`, and standards in `docs/standards/`:

* **`missing`** — an `FR-###` requirement, acceptance scenario, or test scenario from the SPEC is missing in the code or tests;
* **`partial`** — a requirement is only partially implemented (e.g., missing permission check, keys not translated into all 11 mandatory languages, unhandled edge case);
* **`contradicts`** — the implementation contradicts the SPEC, DB field constraints, or mandatory rules from the standards (`redmine-standards.md`, `ror-standards.md`, `ruby-standards.md`, `db-standards.md`, `i18n-standards.md`, `vue-standards.md`);
* **`unrequested`** — functionality, public methods, settings, or extension points not specified in the SPEC were added to the code.

If discrepancies of any of these categories are found, refine the implementation and re-run the tests and `rubocop`. A task is considered complete (`Converged`) only when there are zero discrepancies.