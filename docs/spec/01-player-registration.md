# Participant Registration and Gift Preferences

## 1. Overview

This specification defines how authenticated Redmine users view the Secret Santa participant list, register themselves as participants, manage their personal gift preferences (preferred gifts and gifts to avoid), and remove their participant profile when they no longer wish to participate or after the event concludes.

## 2. Purpose

Allow Redmine users to opt into a Secret Santa event and communicate their gift preferences privately to their assigned Secret Santa giver without exposing those preferences to other participants or administrators in the web UI.

## 3. Affected Areas

* **UI:** Top menu navigation (`Secret Santa`), main dashboard participants section, participant creation and editing forms.
* **Permissions & Access Control:** Authentication requirement for all screens; self-only access for creating and opening the edit form; owner-or-administrator access for updating and deleting a participant record.
* **Database:** Participant records linked 1-to-1 with Redmine users, plus assignment dependency checks on deletion.
* **Localization:** Labels, form fields, hints, and error messages for participant management.

## 4. User Stories & Acceptance Scenarios

### US-1 (`P1` — Critical / MVP): Self-Registration as a Secret Santa Participant

* **Given** an authenticated Redmine user who does not yet have a Secret Santa participant profile, **When** they open the Secret Santa main page, **Then** they see a hint inviting them to create a participant profile and a "Create a participant" button.
* **Given** an authenticated Redmine user on the new participant form, **When** they submit their preferred gifts and gifts to avoid (each up to 2,000 characters), **Then** a participant profile linked to their Redmine user account is created, they are redirected to the Secret Santa main page with a creation success notice, and the "Create a participant" button is no longer shown to them.

### US-2 (`P1` — Critical / MVP): Viewing the Participants List with Gift Privacy

* **Given** an authenticated Redmine user (regular user or administrator), **When** they view the Secret Santa main page, **Then** they see the list of registered participants ordered from newest to oldest showing only each participant's full name, email address, and allowed action links—without exposing any participant's preferred or avoided gifts.

### US-3 (`P2` — Primary): Updating Own Gift Preferences

* **Given** an authenticated user who is registered as a participant, **When** they click "Edit" on their row in the participants list and submit updated gift preferences within the 2,000-character limit, **Then** their preferences are updated and they are redirected to the Secret Santa main page with an update success notice.
* **Given** an authenticated user (including an administrator), **When** they attempt to open the edit form URL for another user's participant profile, **Then** they are redirected to the Secret Santa main page without seeing the other user's preferences.

### US-4 (`P2` — Primary): Deleting a Participant Profile

* **Given** a registered participant who is not part of any active game assignment, **When** the participant themselves (or a Redmine administrator) deletes the participant record, **Then** the participant profile is removed from the system and the user is redirected to the Secret Santa main page with a deletion success notice.
* **Given** a registered participant who is currently assigned as a giver in one or more game assignments, **When** the participant or an administrator attempts to delete that participant record, **Then** deletion is blocked, an error message displays the number of assignments the participant belongs to and instructs to delete the game(s) first, and the participant record remains intact.

### US-5 (`P3` — Additional): Account Email Presence Guidance

* **Given** an authenticated user whose Redmine account has an email address configured, **When** they open the participant creation or edit form, **Then** the form displays their email address (`Your email address: <address>`).
* **Given** an authenticated user whose Redmine account has no email address configured, **When** they open the participant creation or edit form, **Then** the form displays a warning hint prompting them to add an email address to their account in order to play.

## 5. Functional Requirements and Business Rules

* **FR-001 (Authentication Requirement):** All Secret Santa dashboard and participant actions require an authenticated Redmine user session. Unauthenticated requests must be redirected to the Redmine sign-in page.
* **FR-002 (One Participant Profile per User):** A Redmine user may have at most one participant record. The participant identifier matches the current authenticated user's identifier and is always assigned from the active user session rather than request parameters.
* **FR-003 (Participants List Ordering and Empty State):** On the Secret Santa main page, registered participants are listed in descending order of creation timestamp. When no participants are registered, a standard "No data to display" placeholder is rendered instead of the table.
* **FR-004 (Registration Prompt Visibility):** The hint and "Create a participant" button on the main page are displayed only when no participant record exists for the current authenticated user.
* **FR-005 (Gift Preference Length Constraints):** Both the preferred gifts field and the gifts to avoid field are optional free-text fields with a maximum length of 2,000 characters each.
* **FR-006 (Gift Preference Confidentiality in UI):** A participant's preferred gifts and gifts to avoid must never be rendered in the participants list table or be accessible through the edit form to any other user (including administrators).
* **FR-007 (Action Authorization Matrix):**
  * **View participants list (name & email):** Any authenticated user.
  * **Open new/create participant form:** Any authenticated user for their own account.
  * **Open edit participant form:** Strictly the participant who owns the profile (other users, including administrators, are redirected to the Secret Santa main page; no "Edit" link is rendered for other users' rows).
  * **Submit update for a participant:** The profile owner or a Redmine administrator; any other authenticated user receives `403 Forbidden`.
  * **Delete a participant:** The profile owner or a Redmine administrator (and the "Delete" link with confirmation dialog is rendered only for the owner or an administrator); any other authenticated user receives `403 Forbidden`.
* **FR-008 (Deletion Guard on Active Assignments):** Before deleting a participant record, the system checks how many game assignments reference that participant as a giver. If the count is greater than zero, deletion is aborted and a localized flash error message is shown with the exact assignment count.

## 6. Key Entities and Data

### Participant (`Player`)

Represents a Redmine user registered to participate in Secret Santa games.

| Attribute | Business Meaning & Canonical Constraints |
|-----------|------------------------------------------|
| Identifier (`id`) | Primary identifier and 1-to-1 reference to the Redmine `User` entity. Required, unique integer. Cascading delete if the referenced Redmine user is removed. |
| Preferred Gifts (`want_to_get`) | Optional text describing gifts the participant would like to receive. Maximum length: 2,000 characters. Nullable. |
| Gifts to Avoid (`dont_want_to_get`) | Optional text describing gifts the participant does not want to receive. Maximum length: 2,000 characters. Nullable. |
| Timestamps (`created_at`, `updated_at`) | Record creation and last modification timestamps. Used to order the participants list from newest to oldest. |

## 7. Edge Cases

* **Unauthenticated guest access:** Visiting the Secret Santa dashboard or any participant endpoint without logging in redirects to the Redmine login page.
* **Non-existent participant ID:** Requesting edit, update, or delete for a participant ID that does not exist raises a not-found error.
* **Duplicate registration attempt:** If a user who already has a participant record submits a second creation request, uniqueness validation prevents creating a duplicate record and re-renders the new participant form.
* **Text exceeding 2,000 characters:** Submitting 2,001 or more characters in either gift preference field fails validation and re-renders the form without saving.
* **User without an email address:** A user whose Redmine account lacks an email address is shown an informational warning on the participant form (`hint_add_an_email_to_account`), though saving the participant profile itself is not blocked.
* **Unauthorized update/delete via direct HTTP request:** A non-admin user sending a `PATCH`/`PUT` or `DELETE` request targeting another user's participant ID receives a `403 Forbidden` response.
* **Deleting a Redmine user account:** Removing a user from Redmine core automatically cascades deletion to their Secret Santa participant profile and associated game assignments at the database level.

## 8. Error Handling

* **Validation failure on create/update:** No database changes are persisted; the `new` or `edit` template is re-rendered with the unsaved entity state.
* **Unauthorized update or delete (`403 Forbidden`):** When a non-owner, non-administrator sends a direct update or delete request, the system halts execution and renders Redmine's standard `403 Forbidden` page.
* **Unauthorized edit form navigation:** When a user navigates to the edit page of another user's participant profile, the system redirects to the Secret Santa main page (`302 Found`).
* **Blocked deletion due to active assignments:** When a participant is referenced as a giver in one or more assignments, no deletion occurs; the system sets `flash[:error]` to `error_participated_to_assignment` (interpolating `assignments_count`) and redirects to the Secret Santa main page.
* **Unexpected deletion failure:** If destroying a participant record fails for any model validation/callback reason, `flash[:error]` displays `error_player_deletion_failed` followed by the full error messages, and the user is redirected to the Secret Santa main page.

## 9. Assumptions & Scope Boundaries

### Assumptions

* Secret Santa participation is global across the Redmine instance rather than scoped to individual Redmine projects.
* User names and email addresses are managed in Redmine's core user account settings (`My account`), not edited inside the Secret Santa plugin.

### Out of Scope

* Per-game participant opt-in (all registered participants in the system are included when an administrator runs a draw).
* Custom permissions in Redmine's Roles and Permissions matrix (access is governed by login status, profile ownership, and Redmine administrator status).
* Viewing other participants' gift preferences in the web interface.

## 10. Test Scenarios

1. **Unauthenticated access rejected (`FR-001`):** Sending `GET /secret_santa` or `GET /secret_santa_players/new` as an anonymous user redirects to the login page.
2. **Self-registration creates participant linked to current user (`FR-002`, `FR-005`):** Authenticated user submits `POST /secret_santa_players` with valid preferences; participant record is created with `id == User.current.id` and redirects to `/secret_santa`.
3. **Duplicate registration rejected (`FR-002`):** Authenticated user who already has a participant record submits `POST /secret_santa_players` again; duplicate record is not persisted.
4. **Gift preference 2,000-character limit enforced (`FR-005`):** Submitting `want_to_get` or `dont_want_to_get` with 2,001 characters fails validation; 2,000 characters succeeds.
5. **Participants list hides preferences and shows proper action links (`FR-003`, `FR-004`, `FR-006`, `FR-007`):** Regular user sees "Edit" and "Delete" only on their own row, no action links on other users' rows, and no gift preference text anywhere on `/secret_santa`. Administrator sees "Delete" on all rows and "Edit" only on their own row.
6. **Edit form access restricted to profile owner (`FR-006`, `FR-007`):** Requesting `GET /secret_santa_players/:other_id/edit` as another regular user or as an administrator redirects to `/secret_santa`.
7. **Update authorization enforced (`FR-007`):** Profile owner or administrator can update preferences via `PATCH /secret_santa_players/:id`; another non-admin user receives `403 Forbidden`.
8. **Delete authorization enforced (`FR-007`):** Profile owner or administrator can delete an unassigned participant via `DELETE /secret_santa_players/:id`; another non-admin user receives `403 Forbidden`.
9. **Deletion blocked when participant has active assignments (`FR-008`):** Attempting `DELETE /secret_santa_players/:id` when the participant is a giver in an assignment does not remove the participant and sets `flash[:error]` with the assignment count.

## Specification Quality Checklist

* [x] **Completeness**: All required sections are filled out; no `[NEEDS CLARIFICATION]` markers remain; permissions, constraints, and localization behaviors are defined.
* [x] **Clarity**: Exact character limits (2,000), ordering (newest to oldest), and role rules are specified unambiguously.
* [x] **Testability**: Every `FR-001`–`FR-008` requirement and `Given / When / Then` scenario can be verified by Minitest unit and functional tests.
* [x] **No Implementation Leak**: Contains no Ruby code snippets, raw SQL, or internal private method details.
* [x] **Coverage**: Covers `P1`–`P3` scenarios, `403` / redirect negative authorization scenarios, validation limits, and cascading/referential constraints.
* [x] **Consistency**: Terminology matches `00-general.md` and `02-game-management-and-draw.md`.
