# Game Management, Draw, and Notification Emails

## 1. Overview

This specification defines how Redmine administrators create and manage Secret Santa games, configure email subject and body templates using dynamic placeholders, execute and re-run the randomized gift-exchange draw across registered participants, and send personalized HTML notification emails to every participant.

## 2. Purpose

Enable Redmine administrators to conduct a complete Secret Santa draw and notify every participant of their assigned gift recipient and gift preferences automatically by email, without anyone—including the administrator—needing to manually pair participants or view private gift preferences in the web UI.

## 3. Affected Areas

* **UI:** Secret Santa dashboard games list (admin-only), game creation/edit form with Redmine wiki toolbar, game details screen with draw and email delivery actions.
* **Permissions & Access Control:** Strictly restricted to Redmine administrators (`admin?`).
* **Mailer / Notifications:** Personalized HTML emails formatted with Redmine wiki markup and placeholder substitution.
* **Database:** Game records and giver-to-receiver assignment records with cascading deletion.
* **Localization:** Game management labels, template variable hints, draw/email status notices, and error messages.

## 4. User Stories & Acceptance Scenarios

### US-1 (`P1` — Critical / MVP): Creating and Managing a Secret Santa Game

* **Given** a logged-in Redmine administrator on the Secret Santa main page, **When** they click "Create" in the games section and submit a game with a non-empty subject and an optional letter body, **Then** the game is saved and the administrator is redirected to the game's details page with a creation success notice.
* **Given** a logged-in non-administrator user on the Secret Santa main page, **When** they view the page or attempt to access any game URL directly, **Then** the games section is not rendered on the main page and any direct request to a game endpoint redirects to the Secret Santa main page.

### US-2 (`P1` — Critical / MVP): Running the Secret Santa Draw

* **Given** a game exists and at least 2 participants are registered in the system, **When** the administrator clicks "Add all registered participants and draw" (or "Update participants list") on the game details page, **Then** the system generates a cyclic assignment pairing covering all registered participants such that every participant is a giver once, every participant is a receiver once, and no participant is assigned to themselves, and redirects to the game details page with the notice "The draw was successful".
* **Given** a game exists and fewer than 2 participants are registered in the system, **When** the administrator triggers the draw, **Then** no assignments are saved and the administrator is redirected to the game details page with the error message "Not enough participants".

### US-3 (`P1` — Critical / MVP): Sending Personalized Notification Emails

* **Given** a game with completed draw assignments, **When** the administrator clicks "Send letters" and confirms the prompt, **Then** an individual HTML email is sent to each giver's Redmine email address with all template placeholders replaced by that giver's and their assigned receiver's data, and the administrator is redirected to the game details page with the notice "Letters sent successfully".
* **Given** a game with no draw assignments, **When** the administrator sends a request to the email delivery action, **Then** no emails are sent and the administrator is redirected to the game details page with the error message "No assignments found. Draw first".

### US-4 (`P2` — Primary): Re-Running the Draw When Participants Change

* **Given** a game that already has draw assignments, **When** new participants register (or existing ones are removed) and the administrator clicks "Update participants list", **Then** all previous assignments for that game are deleted and replaced with a fresh draw across all currently registered participants.

### US-5 (`P3` — Additional): Deleting a Game After Event Completion

* **Given** an existing game (with or without assignments), **When** the administrator deletes the game from the games list, **Then** the game and all of its assignments are permanently deleted, freeing the participants to delete their participant profiles, and the administrator is redirected to the Secret Santa main page with a deletion success notice.

## 5. Functional Requirements and Business Rules

* **FR-101 (Administrator-Only Access):** Only authenticated Redmine administrators may view the games section on the dashboard or execute any game action (`show`, `new`, `create`, `edit`, `update`, `destroy`, `draw`, `send_emails`). Authenticated non-administrators attempting to invoke any game action are redirected to the Secret Santa main page. Unauthenticated users are redirected to the login page.
* **FR-102 (Game Validation and Ordering):** A game requires a non-empty subject (`name`). The letter body (`message`) is optional and supports Redmine wiki formatting. On the Secret Santa main page, games are listed in descending order of creation timestamp, or a "No data to display" message is shown when no games exist.
* **FR-103 (Minimum Participants for Draw):** A draw requires at least 2 registered participants in the system. If fewer than 2 participants exist, the draw is aborted with a localized error (`error_not_enough_players`).
* **FR-104 (Single-Cycle Derangement Draw Algorithm):** When a draw runs with $N \ge 2$ registered participants:
  1. All registered participants are randomly shuffled.
  2. Each participant at position $k$ in the shuffled list is assigned as the giver for the participant at position $(k + 1) \bmod N$.
  3. All previous assignments for the game are cleared and replaced with the newly generated assignments.
  This guarantees a single closed cycle where every participant gives to exactly one distinct participant, receives from exactly one distinct participant, and never gives to themselves.
* **FR-105 (Game Details View Privacy):** On the game details page, after a draw has been completed, the participants section lists each assigned giver's name and email address (`Name (email)`). It must not display who is assigned to whom (receiver pairings) or any participant's gift preferences.
* **FR-106 (Template Variable Substitution):** When generating a notification email for an assignment, the following placeholders are replaced in both the game's subject (`name`) and letter body (`message`):
  * `((Giver_name))` → full name of the giver's Redmine user account.
  * `((Receiver_name))` → full name of the receiver's Redmine user account.
  * `((Receiver_preferred_gifts))` → the receiver's preferred gifts text, or `-` if blank/empty.
  * `((Receiver_avoid_these_gifts))` → the receiver's avoided gifts text, or `-` if blank/empty.
* **FR-107 (Wiki-Formatted HTML Email Delivery):** Notification emails are delivered synchronously to each giver's Redmine account email address as HTML rendered through Redmine's wiki formatter (`textilizable`).
* **FR-108 (Precondition for Sending Emails):** Triggering email delivery on a game that has zero assignments must not send any emails and must display the localized error `error_no_assignment_found`.
* **FR-109 (Cascading Deletion of Assignments):** Deleting a game automatically deletes all assignments belonging to that game. Deleting a participant (or their underlying Redmine user) cascades deletion to any assignments referencing that participant at the database level.

## 6. Key Entities and Data

### Game (`Game`)

Represents a Secret Santa event managed by a Redmine administrator.

| Attribute | Business Meaning & Canonical Constraints |
|-----------|------------------------------------------|
| Identifier (`id`) | Auto-incremented primary identifier. |
| Subject (`name`) | Required string (`null: false`). Used as the game's display title in the UI and as the email subject template (supports template placeholders). |
| Letter (`message`) | Optional text (`nullable`). Used as the email body template with wiki formatting and template placeholders. |
| Timestamps (`created_at`, `updated_at`) | Creation and modification timestamps. Used to order games from newest to oldest. |

### Assignment (`Assignment`)

Represents a directed pairing of a gift giver and a gift receiver within a specific Secret Santa game.

| Attribute | Business Meaning & Canonical Constraints |
|-----------|------------------------------------------|
| Identifier (`id`) | Auto-incremented primary identifier. |
| Game Reference (`secret_santa_game_id`) | Required reference to the `Game` entity (`null: false`). Deleted automatically when the parent game is deleted. |
| Giver Reference (`giver_id`) | Required reference to the giver `Participant` entity (`null: false`). Unique per game (`[secret_santa_game_id, giver_id]` unique constraint). Cascading delete if the giver participant is removed. |
| Receiver Reference (`receiver_id`) | Required reference to the receiver `Participant` entity (`null: false`). Cascading delete if the receiver participant is removed. |
| Timestamps (`created_at`, `updated_at`) | Creation and modification timestamps. |

## 7. Edge Cases

* **Draw with 0 or 1 registered participant:** Draw raises an insufficient-participants condition, leaves existing assignments untouched, and displays `error_not_enough_players`.
* **Receiver has blank or whitespace-only gift preferences:** Placeholders `((Receiver_preferred_gifts))` and `((Receiver_avoid_these_gifts))` evaluate to `-` in the generated email so the recipient never sees raw placeholder tokens or empty gaps.
* **Game with empty letter body (`message` is `nil` or empty):** Email delivery still succeeds without error, rendering an empty formatted body and substituting placeholders in the subject line.
* **Multiple games active simultaneously:** Assignments are scoped to a specific game; running a draw or deleting one game does not alter assignments belonging to another game.
* **Non-existent game ID:** Requesting `show`, `edit`, `update`, `destroy`, `draw`, or `send_emails` for a non-existent game ID raises a record-not-found error.
* **Unexpected exception during draw:** If any unexpected runtime or database error occurs while creating assignments, the controller catches the exception and displays a localized failure prefix followed by the error message in `flash[:error]`.

## 8. Error Handling

* **Missing game subject on create/update:** Validation fails, no changes are saved, and the `new` or `edit` form is re-rendered.
* **Non-administrator access to game endpoints:** All requests from authenticated non-admin users are intercepted before action execution and redirected (`302 Found`) to the Secret Santa main page (`/secret_santa`).
* **Insufficient participants on draw:** Caught and reported via `flash[:error] = l(:error_not_enough_players)`, redirecting back to the game details page.
* **Unexpected error on draw:** Caught and reported via `flash[:error] = "#{l(:error_draw_failed)}: #{e.message}"`, redirecting back to the game details page.
* **Sending emails before draw:** No emails are dispatched; `flash[:error] = l(:error_no_assignment_found)` is set, redirecting back to the game details page.

## 9. Assumptions & Scope Boundaries

### Assumptions

* Redmine's outgoing email (`ActionMailer` / SMTP) is configured in the host Redmine instance so that synchronous email delivery succeeds.
* Every participating user has a valid email address configured in their Redmine profile prior to the administrator sending notifications.

### Out of Scope

* Asynchronous background job queueing for email delivery (emails are sent synchronously during the `send_emails` request).
* Selective inclusion/exclusion of specific registered participants per game (the draw always includes all registered participants).
* Exclusion rules or blacklists between specific pairs of participants.
* Tracking whether emails have already been sent for a given game (administrators can trigger "Send letters" more than once if needed, and are advised in documentation to delete the game afterward).

## 10. Test Scenarios

1. **Administrator access control (`FR-101`):** Non-admin user requesting any action on `SecretSantaGamesController` (`show`, `new`, `create`, `edit`, `update`, `destroy`, `draw`, `send_emails`) is redirected to `/secret_santa`.
2. **Game creation and validation (`FR-102`):** Administrator creates a game with a valid `name` and `message` (succeeds and redirects to game show page); submitting an empty `name` fails validation and re-renders `new`.
3. **Draw blocked with fewer than 2 participants (`FR-103`):** With 0 or 1 registered participant, `POST /secret_santa_games/:id/draw` creates 0 assignments and sets `flash[:error]` to `error_not_enough_players`.
4. **Draw creates valid cyclic derangement with 2+ participants (`FR-104`):** With $N \ge 2$ registered participants, `POST /secret_santa_games/:id/draw` creates exactly $N$ assignments where the set of givers equals the set of receivers, equals all $N$ participants, and no assignment has `giver_id == receiver_id`.
5. **Re-running draw replaces previous assignments (`FR-104`):** Running `draw` a second time after adding a new participant replaces the old assignments with a new set of $N + 1$ assignments without duplicate `(game, giver)` pairs.
6. **Game details screen hides receiver pairings (`FR-105`):** Viewing `GET /secret_santa_games/:id` after a draw lists giver names and emails but does not render receiver names alongside givers or any gift preferences.
7. **Sending emails fails when no assignments exist (`FR-108`):** `POST /secret_santa_games/:id/send_emails` on a game without assignments sends 0 emails and sets `flash[:error]` to `error_no_assignment_found`.
8. **Sending emails substitutes all placeholders and fallback values (`FR-106`, `FR-107`):** `POST /secret_santa_games/:id/send_emails` on a drawn game delivers one email per assignment to each giver's email address with `((Giver_name))`, `((Receiver_name))`, `((Receiver_preferred_gifts))`, and `((Receiver_avoid_these_gifts))` (or `-` when blank) replaced in both subject and body.
9. **Deleting a game cascades to its assignments (`FR-109`):** `DELETE /secret_santa_games/:id` deletes the game and all associated assignment records, allowing previously assigned participants to be deleted afterward.

## Specification Quality Checklist

* [x] **Completeness**: All required sections are filled out; no `[NEEDS CLARIFICATION]` markers remain; permissions, draw rules, template placeholders, and error behaviors are defined.
* [x] **Clarity**: Draw preconditions ($N \ge 2$), cyclic pairing invariants, placeholder names, and fallback values (`-`) are explicitly specified.
* [x] **Testability**: Every `FR-101`–`FR-109` requirement and `Given / When / Then` scenario can be directly verified by Minitest unit and functional tests.
* [x] **No Implementation Leak**: Describes domain entities, invariants, and observable behavior without raw SQL or implementation code dumps.
* [x] **Coverage**: Covers `P1`–`P3` scenarios, non-admin access rejection, insufficient participants, blank gift fallbacks, and cascading deletes.
* [x] **Consistency**: Terminology and constraints align with `00-general.md` and `01-player-registration.md`.
