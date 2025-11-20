Secret Santa Redmine plugin
---------------------------

1) Install: copy folder to plugins/secret_santa
2) Run migrations:
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
3) Restart Redmine

Use:

- Top menu -> Secret Santa
- Create a game: choose group (group must have at least 2 users with emails)
- Open game -> Run draw -> Send emails