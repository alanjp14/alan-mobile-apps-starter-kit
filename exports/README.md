# exports/

Generated, throwaway output — **not** source of truth, and (except this README + `.gitkeep`) **not** committed (`.gitignore`).

Use this folder for build/export artifacts produced from the repository:

| Artifact | Produced by |
|---|---|
| `amds-tokens-<version>.zip` | bundling `design-tokens/` for handoff to a team without repo access |
| `amds-docs-<version>.pdf` / `.html` | a single-file export of `docs/` for offline review or a stakeholder pack |
| `component-catalog/` | a static export of the Widgetbook/Storybook component gallery |
| `contrast-report-<theme>.json` | the output of the contrast lint per theme |
| `figma-tokens.json` | a Tokens Studio export snapshot |
| `validate-report.txt` | `node tool/validate.mjs` output, saved for a PR |

Nothing here should be referenced by `docs/`. If something in `exports/` becomes canonical, move it into `docs/`, `design-tokens/`, or `templates/`.
