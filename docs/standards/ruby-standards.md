# Ruby Standards for Redmine

## 1. General Principles

* Write simple and predictable code.
* Prefer explicitness over magic.
* Avoid duplication, but do not extract code into abstractions without a real need.
* Do not copy blocks of code across methods, classes, or files. Identical `if`/`case` branches and identical methods are not allowed — unify them.
* Code must be easy to maintain 6–12 months from now, not just today.

## 2. Naming

* Names of classes, methods, modules, variables, and constants must be meaningful.
* Do not use meaningless abbreviations unless they are widely accepted across the project.
* Loop local variables must have descriptive names rather than single characters.

    * Good: `issue`, `time_entry`, `journal_entry`, `permission_name`
    * Bad: `i`, `x`, `t`, `e`

## 3. Code Style

* Prefer early returns from a method over deep nesting.
* Keep methods short and make each method perform a single task.
* Do not use complex ternary expressions if the condition reads worse than a regular `if`. Nested ternary operators are prohibited.
* Method cognitive complexity must not exceed 15. If exceeded, extract parts into well-named helper methods.
* Do not nest control flow structures deeper than 3 levels.
* Do not write "clever" code if it is harder to read.
* Use `freeze` for immutable strings and arrays where appropriate.

## 4. Ruby Methods

* A method must perform a single, well-defined task.
* Give methods names that describe the action or the return value.
* Use `?` for predicate methods returning a boolean value.
* Use `!` only when a method has more dangerous behavior or a safer non-`!` counterpart exists.
* Do not use `get_` and `set_` prefixes unnecessarily:

  * `user_name`, not `get_user_name`;
  * `user_name=`, not `set_user_name`.
* Avoid long methods. If a method contains several distinct stages, extract them into separate methods or services.
* Limit the number of arguments to at most 7. When many parameters are needed, use keyword arguments or a parameter object.
* Prefer keyword arguments for optional parameters and boolean flags.
* Do not use non-obvious positional boolean arguments:

```ruby
import(records, validate: true)
```

instead of:

```ruby
import(records, true)
```

* Do not mutate method arguments without an explicit need. If a method mutates a passed object, that must be clear from its purpose.
* Do not use a single method both to perform an action and to return an unrelated result.
* Use early `return` statements to reduce conditional nesting.
* Do not rescue `StandardError` unnecessarily and never rescue `Exception`. Rescue only errors that the method can genuinely handle; any caught error must either be handled or logged.
* Never hide errors with an empty `rescue`.
* Do not use exceptions for normal control flow.
* Place private methods below `private`.
* Do not call private methods via `self`, except for setter methods where Ruby requires it.
* Do not use `send` when a normal method call or `public_send` suffices.
* Do not define methods dynamically without a real need.
* Do not store temporary method state in instance variables if it should not live longer than a single call.
* Use `nil` only as a deliberate value. Do not return different unrelated result types unnecessarily.
* Reflect side effects explicitly in method names: `save`, `update`, `send`, `delete`, `sync`.
* Use blocks only where they genuinely improve readability.

## 5. Collections and Iterations

* Choose the most readable iteration construct, not the shortest one.
* Do not overcomplicate method chains if they are hard to read without breaking them into intermediate variables.
* If logic inside `each`, `map`, `select`, or `reject` becomes non-trivial, extract it into a separate method.
* Keep performance and data size in mind when working with collections.

## 6. Conditional Logic

* Conditional expressions must be simple and readable.
* Avoid overly nested `if`/`unless` statements.
* Prefer positive conditions when negation hurts comprehension.
* Never use `unless` with `else`.

## 7. Errors and Exceptions

* Use exceptions only for genuine error conditions.
* Do not swallow exceptions without a reason.
* Return a clear result or user-facing message when handling errors.
* Do not use exceptions as a regular control-flow mechanism.

## 8. Nil and Safe Navigation

* Check for `nil` explicitly when it improves readability.
* Use safe navigation (`&.`) only where it simplifies the code.
* Do not mask real bugs through excessive use of `&.`.

## 9. Constants and Strings

* Extract repeated values into constants.
* A string literal repeated **3 or more times** in a single file must be extracted into a constant. Sonar usually ignores short literals (up to ~10 characters: `'status'`, `'false'`); always extract longer ones — CSS selectors, setting keys, URLs, messages.
* This rule applies to tests as well: selectors in `assert_select`, setting keys, parameter values.
* Declare constants at the top of the class or module; the name must reflect meaning rather than value. Build composite values from base constants instead of copying the common substring. Freeze interpolated constants with `.freeze`.
* Check for repetitions before writing a third identical literal, not after a Sonar warning.

Bad:

```ruby
assert_select 'div.ux-compact-card', 1
assert_select 'div.ux-compact-card', 0
assert_select 'div.ux-compact-card div.status.attribute', 1
```

Good:

```ruby
COMPACT_CARD = 'div.ux-compact-card'
SWITCHER = 'div.ux-issue-attributes-switcher'
NORMAL_MODE = "#{SWITCHER}[data-compact-card-mode=normal]".freeze

assert_select COMPACT_CARD, 1
assert_select NORMAL_MODE, 1
assert_select "#{COMPACT_CARD} div.status.attribute", 1
```

* Do not hardcode user-facing strings that may change unnecessarily.
* Do not use magic numbers when a value has domain meaning and can be named.

## 10. Comments

* Code is written without comments. Meaning must be clear from the names of classes, methods, variables, and tests.
* If code is unclear without an explanation — rename or extract a method/constant rather than adding a comment.
* The only permitted comments are magic comments (`# frozen_string_literal: true`, RuboCop directives) and SPEC references in tests (`# SPEC: docs/spec/...`, see `00-rules.md`, Rule 2).
* Do not add comments to existing code; when modifying code that has a comment — remove the comment.

## 11. Dead and Debug Code

* Do not leave commented-out code.
* Do not leave unused variables, parameters, or private methods.
* Do not leave a `TODO` without an issue number.
* Do not leave empty methods or blocks. If a body is intentionally empty — reflect that in the method name.
* Do not leave debug output: `puts`, `p`, `pp`, `binding.irb`, `debugger`.
