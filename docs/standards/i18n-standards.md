# I18n Standards for Redmine

## General Principles

* All user-facing text must be extracted to localization files — hardcoding strings in Ruby code, controllers, models, helpers, and views is prohibited.
* Retrieve translations through standard Redmine/Rails mechanisms: `l`, `I18n.t`.
* Every new key must be present simultaneously across all mandatory languages (see "Mandatory Languages").

## Mandatory Languages

Every new key is translated into the following languages:

| Code  | Language               |
|-------|------------------------|
| en    | English                |
| fr    | French                 |
| ja    | Japanese               |
| de    | German                 |
| es    | Spanish                |
| pt-BR | Brazilian Portuguese   |
| ru    | Russian                |
| pl    | Polish                 |
| zh    | Simplified Chinese     |
| ko    | Korean                 |
| it    | Italian                |

Localization files are placed in `plugins/plugin_name/config/locales/` named `{code}.yml` (for example, `pt-BR.yml`).

## Priority: Reuse Before Creation

Before adding a new key, you must check:

1. `redmine/config/locales/en.yml` and `ru.yml`
2. Other files in `redmine/config/locales/`
3. The plugin's own localization files

If a suitable translation is found — reuse it. Create a key in `plugins/plugin_name/config/locales/` only if it does not exist in Redmine. Duplicating existing Redmine translations is considered a violation of the standard.

## Key Naming

Follow the Redmine style:

```yaml
# Correct
label_workflow_rule
field_rule_type
notice_rule_created
error_invalid_rule
permission_manage_workflow_rules

# Incorrect
workflow_rule_label
aw_rule_type
my_custom_rule_name
```

A key reflects its purpose, not its implementation.

## Interpolation

Use interpolation for dynamic values, not concatenation:

```yaml
notice_rule_executed: "Rule %{rule_name} executed successfully"
```

```ruby
# Correct
l(:notice_rule_executed, rule_name: rule.name)

# Incorrect
"Rule #{rule.name} executed successfully"
```

## Phrasing

* **EN:** concise, matching the style of existing Redmine translations, consistent terminology across the entire plugin.
* **RU:** neutral technical style without colloquialisms, consistent translation of terms.
* **Other languages:** translated from EN; consistent terminology across the entire plugin, matching the style of existing Redmine translations for the respective language.
