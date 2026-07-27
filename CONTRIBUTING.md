# Contributing to Nerve

Thanks for helping improve Nerve. Keep changes focused, preserve compatibility
unless the change is intentionally documented as breaking, and include tests
for framework behavior.

## Before submitting

1. Format and lint first-party Luau.
2. Build both the package and Studio test place.
3. Run the Studio specifications.
4. Build the Moonwave documentation.
5. Update the relevant guide whenever behavior or public API changes.

See [Testing and validation](docs/testing.md) for the commands and test runner.

Do not edit generated dependency contents casually. Dependency updates should
change their declared versions, lock data, materialization process, notices,
and documentation together.

By contributing, you agree that your contribution is licensed under Nerve's
[MIT License](LICENSE).
