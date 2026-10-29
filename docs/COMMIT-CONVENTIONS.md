# Commit Message Conventions

The repository uses concise, reviewable GitHub commit messages.

## Format

- Use an imperative subject line of 50 characters or fewer.
- Leave one blank line after the subject.
- Use a short body when context or rationale is useful.
- Wrap body lines at 72 characters or fewer.
- Keep one logical change per commit.
- Do not include credentials, tokens, generated build output, or unrelated formatting changes.

## Examples

```text
Document requirements and SDLC governance

Add the SRS and lifecycle report with requirement traceability.
Keep the architecture aligned with the OAuth deployment boundary.
```

```text
Optimize dashboard provider listeners

Listen only to the provider fields rendered by each shell widget.
Avoid rebuilding navigation and static header elements on telemetry ticks.
```

Commit messages are part of the review record. A clear subject should explain the outcome, while the body should explain why the change exists when the subject is not enough.
