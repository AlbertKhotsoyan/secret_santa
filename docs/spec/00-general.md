# Secret Santa — General Specification

## Description

**Secret Santa** is a Redmine plugin that enables users to organize and participate in Secret Santa gift-exchange events directly inside Redmine.

Authenticated Redmine users register as participants and specify their personal gift preferences (gifts they would like to receive and gifts they would prefer to avoid). Redmine administrators create and manage Secret Santa games, configure customizable email subject and body templates using dynamic placeholders, run the randomized gift-exchange draw across all registered participants, and send personalized assignment notification emails to participants.

To protect participant privacy, gift preferences are never displayed in the Redmine web interface to other users or administrators—they are only injected into the personalized email sent directly to the assigned Secret Santa giver. Once emails are delivered, participants and administrators can delete participant profiles and game records so that personal preferences and assignment pairings are stored only for the duration of the event.

## Core Operational Workflow

1. **Navigation and Dashboard Access.** Upon installation, the plugin adds a **Secret Santa** item to the end of Redmine's top navigation menu. Any authenticated user can open the Secret Santa dashboard.
2. **Participant Registration.** An authenticated user registers as a participant for their own Redmine account and optionally fills in preferred gifts and gifts to avoid (up to 2,000 characters each). The registration form also informs the user of their current Redmine account email address or prompts them to add one if missing.
3. **Game Creation.** A Redmine administrator creates a Secret Santa game by defining an email subject and a wiki-formatted letter body containing template placeholders (`((Giver_name))`, `((Receiver_name))`, `((Receiver_preferred_gifts))`, `((Receiver_avoid_these_gifts))`).
4. **Running the Draw.** On the game details page, the administrator runs the draw. Provided at least 2 participants are registered, the system shuffles all registered participants into a single closed cycle so that every participant gives a gift to one other participant, receives a gift from one participant, and is never assigned to themselves. If new participants register later, the administrator can re-run the draw to regenerate assignments.
5. **Sending Notification Emails.** Once the draw is finalized, the administrator triggers email delivery. Each assigned giver receives an individualized HTML email at their Redmine account email address containing their assigned receiver's name and gift preferences.
6. **Post-Event Cleanup.** After notifications are sent, the administrator can delete the game (which removes all assignment pairings), and participants or administrators can delete participant records to remove gift preferences from the database.

## Specification Files

| File | Description |
|------|-------------|
| [01-player-registration.md](01-player-registration.md) | Participant registration, gift preference management, privacy rules, and participant deletion constraints (`FR-001`–`FR-008`) |
| [02-game-management-and-draw.md](02-game-management-and-draw.md) | Administrator game lifecycle, cyclic draw algorithm, template variable substitution, and email delivery (`FR-101`–`FR-109`) |

## Target Redmine Versions and Compatibility

* **Supported Redmine versions:** Redmine 5.0, 5.1, 6.0, 6.1, 7.0.
* **Database compatibility:** PostgreSQL and MySQL (migrations use standard schema definitions, foreign keys with cascading deletes, and unique composite indexing).
* **Integration mechanisms:**
  * **Top Menu Extension:** Registers `:secret_santa` in Redmine's `:top_menu`.
  * **Authentication & Access Control:** Uses Redmine's standard login verification and administrator role check (`admin?`) along with owner checks for participant profile actions.
  * **Email Delivery & Wiki Formatting:** Integrates with Redmine's mailer infrastructure and wiki text formatting (`textilizable` and wiki toolbar) for composing and rendering Secret Santa letters.
  * **No Core Overrides or Patches:** Does not patch Redmine core classes or use Deface view overrides, ensuring zero conflict with other installed plugins.
* **Locales included in the repository:** English (`en`), Russian (`ru`), German (`de`).

## Running, Testing, and Maintenance Commands

Execute all commands from the Redmine root directory (`redmine/`):

### Apply Plugin Migrations

```bash
bundle exec rake redmine:plugins:migrate NAME=secret_santa
```

### Roll Back Plugin Migrations

```bash
bundle exec rake redmine:plugins:migrate NAME=secret_santa VERSION=0
```

### Run All Plugin Automated Tests

```bash
bundle exec rake redmine:plugins:test NAME=secret_santa
```

### Run a Specific Test File

```bash
bundle exec rails test plugins/secret_santa/test/unit/secret_santa_test.rb
```

### Run RuboCop Linter

```bash
bundle exec rubocop -c plugins/secret_santa/.rubocop.yml plugins/secret_santa
```
