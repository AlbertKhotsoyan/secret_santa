# DB Standards for Redmine

## 1. General Principles

* All database schema changes must be performed through migrations.
* Each schema change must be structured as a separate migration.
* Do not modify existing migration files if they have been merged into a shared branch or already applied in any environment.
* If modifying an existing migration is still necessary — ask the user first. Acceptable options: leave the file unchanged or implement the fix in a new migration.
* Migrations must be as simple and predictable as possible.
* Changes must be compatible with both PostgreSQL and MySQL.
* Do not use DBMS features that only work in a single database engine.
* Target load benchmark when designing queries and indexes: around ~200k issues, ~10k open.

## 2. Migration Version

All migrations must use:

```ruby
# frozen_string_literal: true

class CreateExampleTable < ActiveRecord::Migration[5.2]
end
```

Mandatory requirements:

* use `ActiveRecord::Migration[5.2]`;
* add `# frozen_string_literal: true` as the first line of the file;
* do not use other migration versions without an explicit need.

## 3. Creating Tables

When creating tables, you must:

* explicitly specify column types;
* explicitly specify `null`;
* explicitly specify `default` if the column can have a default value;
* create indexes for frequently used search conditions and associations.

Example:

```ruby
create_table :plugin_name_rules do |table|
  table.string  :name, null: false, default: ''
  table.integer :position, null: false, default: 0
  table.boolean :active, null: false, default: true

  table.timestamps null: false
end
```

Unacceptable:

```ruby
create_table :plugin_name_rules do |table|
  table.string :name
  table.boolean :active
end
```

## 4. Default Values

Explicitly define behavior for all columns.

Preferred:

```ruby
table.string  :name, null: false, default: ''
table.text    :description
table.integer :position, null: false, default: 0
table.boolean :active, null: false, default: true
```

Do not leave default behavior implicit.

It is especially important to set `default` for:

* boolean;
* integer counters;
* statuses;
* sort order / position fields;
* activity flags.

## 5. Table Associations

Associations must work identically in PostgreSQL and MySQL.

Preferred:

```ruby
table.integer :project_id, null: false
table.integer :user_id, null: false

add_index :plugin_name_rules, :project_id
add_index :plugin_name_rules, :user_id
```

or

```ruby
t.references :project, null: false
```

if compatible with the target Redmine version.

Before adding foreign keys, verify support in the target PostgreSQL and MySQL versions.

## 6. Indexes

Create indexes for:

* foreign keys;
* search columns;
* filter columns;
* sort columns;
* unique constraints.

Example:

```ruby
add_index :plugin_name_rules, :project_id
add_index :plugin_name_rules, [:project_id, :active]
add_index :plugin_name_rules, :name, unique: true
```

Do not create indexes without a reason.

## 7. PostgreSQL and MySQL Compatibility

All migrations must be verified for compatibility with both DBMSs.

Prohibited:

* PostgreSQL-specific SQL;
* MySQL-specific SQL;
* data types missing in one of the DBMSs;
* DBMS functions without verifying compatibility.

Prefer ActiveRecord features over raw SQL.

Bad:

```ruby
execute 'ALTER TABLE ... USING gin (...)'
```

Good:

```ruby
add_index ...
```

## 8. Data Modification

Modifying data inside migrations is allowed only when necessary.

If data migration is required:

* use models inside a migration with caution;
* do not depend on the current application state;
* avoid complex business logic.

A migration must remain functional years after it is created.

## 9. Migration Reversibility

Migrations should be reversible whenever possible.

Preferred:

```ruby
def up
end

def down
end
```

or

```ruby
change
```

if the operation is completely reversible.

## 10. Naming

Tables:

```text
plugin_name_rules
plugin_name_logs
```

Columns:

```text
project_id
user_id
rule_id
created_at
updated_at
```

Follow standard Rails and Redmine conventions.

Do not use abbreviations or ambiguous names.

## 11. Performance

Before adding a new table or column, evaluate:

* data volume after several years of operation;
* need for indexes;
* read frequency;
* write frequency;
* impact on existing Redmine queries.

Any schema change must account for performance on large Redmine installations with 200,000+ issues.

## 12. Checklist

Before creating a migration, ensure that:

* `# frozen_string_literal: true` is used;
* `ActiveRecord::Migration[5.2]` is used;
* `null` constraints are defined;
* `default` values are defined where necessary;
* required indexes are added;
* the migration works in PostgreSQL;
* the migration works in MySQL;
* vendor-specific SQL is absent;
* Rails and Redmine naming conventions are followed.

## 13. Modifying Existing Migrations

Already created migration files are considered immutable by default.

Editing an existing migration is prohibited if it:

* has already been merged into a shared branch (`dev`, `main`, etc.);
* has already been applied in any environment (local, staging, production).

Even if a migration has not yet been merged and exists only in a feature branch, it is still preferable not to edit it retroactively.

To modify the schema after an initial migration, create a new migration file.

If editing an existing migration file seems necessary — ask the user first and agree on one of the options:

* leave the migration unchanged;
* implement the change in a new migration file.
