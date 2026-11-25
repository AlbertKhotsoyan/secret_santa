# Changelog

## [1.0.4] - 2026-11-26
### Added
- Snowfall effect (`secret_santa_snow.js`) and decorative snowflake, snow/icicle, and Christmas tree vector sprites across `/secret_santa`, `/secret_santa_games`, and `/secret_santa_players`;
### Improved
- Styled `SecretSantaMailer` HTML email template with winter header, letter card, and recipient locale support;
### Fixed
- Validate assignment cycle integrity (`SecretSanta::Game#valid_assignments_cycle?`) before sending emails and check both `giver_id` and `receiver_id` in `SecretSanta::Assignment.count_for_player` to guard against cascaded user deletions;
- Use `deliver_later` with per-recipient error handling in `SecretSanta::Game#send_santa_emails` so a delivery error on one recipient does not abort remaining emails or cause a 500 error;
- Redirect already-registered participants away from `/secret_santa_players/new` and `POST /secret_santa_players`;
- Render absolute links (`only_path: false`) inside `SecretSantaMailer` HTML email messages;
- Restrict unimplemented `index`/`show` resource routes in `config/routes.rb`;

## [1.0.3] - 2026-11-25
### Added
- Default letter message template with template variables when creating a new game;
- Plugin stylesheet (`secret_santa.css`) and updated ERB views compatible with Redmine default themes and `ux_next` (light and dark modes);
### Improved
- Unified `label_email_information` across all 11 locale files and updated Russian localization (`Тайный Дед Мороз`);

## [1.0.2] - 2026-11-25
### Improved
- Refactored models, controllers, mailer, helpers, views, Minitest test suite, and 11-language localizations to comply with Redmine plugin standards;

## [1.0.1] - 2025-11-27
### Fixed
- Error deleting a participant while participating in assignments;
### Improved
- UI
