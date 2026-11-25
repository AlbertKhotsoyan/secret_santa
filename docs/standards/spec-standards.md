# Specification Writing Standards for Redmine Plugins

## General Requirements

* All specifications are stored in `docs/spec/`.
* File format — Markdown (`.md`).
* Write specifications in English.
* A SPEC describes **system behavior and user value (WHAT and WHY)**, not implementation details (HOW).
* Specifications in `docs/spec/` serve as **Living Specs** of the plugin and are kept up to date whenever behavior changes.

## Directory Structure

Mandatory file:

```text
docs/spec/00-general.md
```

`00-general.md` must contain:

* brief description of the plugin;
* core operational workflows;
* table and description of all other specification files;
* target Redmine versions, compatibility constraints, and integration mechanisms used;
* commands for running, testing, and maintenance (`rake`, `rails test`, `rubocop`).

If there are many commands, extract them into a separate file:

```text
docs/spec/console-commands.md
```

## Specification Structure

Each feature specification (`docs/spec/01-*.md`, `02-*.md`, etc.) must contain the following sections:

### 1. Overview

Brief description of the feature and the context of its use in Redmine.

### 2. Purpose

What user or business problem the feature solves and what measurable outcome is expected.

### 3. Affected Areas

List of Redmine and plugin subsystems, for example:

* Issues
* Time Entries
* Workflow
* Permissions
* Settings
* API / MCP
* Cron / Sidekiq
* UI
* Localization
* Database

### 4. User Stories & Acceptance Scenarios

Scenarios are described from the perspective of Redmine roles (Administrator, Project Manager, Assignee, Issue Author, Anonymous/External User) and ordered by priority:

* **`P1` (Critical / MVP)** — foundational scenario without which the feature has no value;
* **`P2` (Primary)** — important operational workflows and settings;
* **`P3` (Additional)** — auxiliary capabilities and convenience features.

Each scenario must be **independently verifiable** and include acceptance criteria in **Given / When / Then** format:

* **Given** `[initial state of the project, settings, roles, and entities]`, **When** `[user or system action]`, **Then** `[expected observable outcome]`.

### 5. Functional Requirements and Business Rules (`FR-###`)

Detailed operational rules for the feature. For end-to-end traceability across the SPEC, Implementation Plan, task list, and automated tests, key requirements are assigned stable identifiers (`FR-001`, `FR-002`, ...):

* activation/deactivation rules (global plugin settings, project module);
* access control and data visibility matrix (`permission`, `visible`);
* calculation rules, validations, state transitions, and side effects (issue `Journal`, notifications, field recalculations).

#### Marking Ambiguities (`[NEEDS CLARIFICATION]`)

When drafting or updating a SPEC, silently guessing ambiguous business rules is prohibited:

* if a requirement admits multiple interpretations affecting scope, access control, or UX, mark it with `[NEEDS CLARIFICATION: specific question]`;
* no more than **3 markers** per document (priority: functional scope > security and permissions > UX > details);
* for standard Redmine behavior, use sensible defaults and explicitly record them in the "Assumptions & Scope Boundaries" section;
* before proceeding to the Implementation Plan, all `[NEEDS CLARIFICATION]` markers must be resolved and replaced with approved rules.

### 6. Key Entities and Data *(include if the feature stores or modifies data)*

Description of domain entities, their semantic attributes, relationships, lifecycle, and canonical business constraints (requiredness, uniqueness, value limits, default values) — without SQL code or binding to ActiveRecord methods.

### 7. Edge Cases

Non-standard scenarios and constraints mandatory for Redmine:

* object (issue, project, user, record) does not exist or is not visible to the current user (`visible`);
* global plugin setting is disabled or the plugin module is disabled in the project;
* closed or archived project;
* user lacks permission when sending a direct HTTP/API/MCP request;
* disabled standard tracker fields (`disabled_core_fields`) or required workflow custom fields;
* concurrent modification of a record by another user (`Optimistic Locking` / `lock_version`);
* operation on large data volumes (~200k issues, ~10k open).

### 8. Error Handling

System behavior upon failures and invalid input:

* which actions are rolled back (transactionality, no spurious `Journal` entries);
* which HTTP status codes are returned (`403 Forbidden`, `404 Not Found`, `422 Unprocessable Entity`);
* which localized messages are displayed to the user (`flash[:error]`, form errors, API/MCP response).

### 9. Assumptions & Scope Boundaries

* recorded default assumptions about the environment and Redmine behavior;
* what is explicitly **Out of Scope** for the current specification, to prevent implementing unrequested features (`unrequested`).

### 10. Test Scenarios

Minimum set of positive and negative scenarios for automated verification in Minitest (unit and functional), covering `FR-###` requirements, the access control matrix, and edge cases.

## What Must Not Be in a SPEC

Do not include in functional specifications:

* Ruby classes and modules;
* internal method names and private logic;
* code directory structure;
* raw SQL queries and migration code;
* implementation code snippets.

A SPEC answers the question:

> **What must work and by what rules?**

not:

> **How exactly to write it in code?** (that is the job of the `Implementation Plan`).

## Modifying Existing Functionality and Recording Clarifications

* When changing existing behavior, you must **update the existing SPEC** in `docs/spec/`, maintaining it as the single up-to-date source of truth.
* Create a new SPEC file only for a new standalone functional area of the plugin (and add a link to it in `docs/spec/00-general.md`).
* When conducting a clarification session (`Clarify`), incorporate the user's answers immediately into the relevant SPEC sections (replacing outdated or ambiguous phrasing so no contradictions remain).

## Specification Quality Checklist ("Unit Tests for Requirements")

Before approving a SPEC and moving to planning (`Implementation Plan`), verify the specification against the following requirements quality criteria:

* [ ] **Completeness**: all required sections are filled out; no `[NEEDS CLARIFICATION]` markers remain; permissions, settings, and localization are defined.
* [ ] **Clarity**: no vague phrasing ("fast", "convenient", "properly", "as needed") without exact conditions and criteria.
* [ ] **Testability**: every `FR-###` requirement and `Given / When / Then` scenario can be unambiguously verified by a Minitest automated test.
* [ ] **No Implementation Leak**: the SPEC contains no Ruby/JS/SQL code or low-level implementation details.
* [ ] **Coverage**: primary scenarios (`P1`–`P3`), negative permission scenarios (`403`/`404`), concurrent editing conflicts, and Redmine constraints are accounted for.
* [ ] **Consistency**: terminology is uniform within the file and does not contradict `docs/spec/00-general.md` or adjacent plugin specifications.

## Definition of Ready

A SPEC is considered complete if all items on the quality checklist are satisfied and an `Implementation Plan` can be designed and implemented from the specification without further assumptions.
