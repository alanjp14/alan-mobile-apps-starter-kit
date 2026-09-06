# AMDS Reusable AI Prompt Library

Copy-paste prompts for driving future design + engineering work on `[COMPANY_NAME]` mobile apps with an AI agent (Claude, Gemini, Antigravity, Cursor, …).

Each prompt is self-contained and follows the same structure:

| Section | Purpose |
|---|---|
| **Role** | Who the AI should act as |
| **Context** | What AMDS is and where the source of truth lives |
| **Inputs** | What you must provide before running |
| **Rules** | Hard constraints the output must obey |
| **Expected output** | Exact deliverables and format |
| **Validation** | Checks the AI must run before finishing |
| **Acceptance criteria** | A checklist you use to accept or reject the result |

## Prompts

| File | Use it to… |
|---|---|
| [`mobile-design-system.md`](mobile-design-system.md) | Create or extend the AMDS design system / foundations / tokens |
| [`component-library-generator.md`](component-library-generator.md) | Specify a new component (or a set) to AMDS standards |
| [`screen-library-generator.md`](screen-library-generator.md) | Produce a reusable screen template / pattern |
| [`feature-template-library.md`](feature-template-library.md) | Produce a full feature blueprint (biz flow → data → API → state → security → scale) |
| [`mobile-app-starter-template.md`](mobile-app-starter-template.md) | Scaffold or document a new app's architecture from this template |
| [`ux-audit.md`](ux-audit.md) | Audit an existing design or build against AMDS |

## How to use

1. Open the prompt file, copy its whole contents.
2. Fill in the `Inputs` block at the top with your specifics (screen name, feature name, platform, brand, …).
3. Paste into your AI agent, along with (or a link to) the relevant AMDS docs the prompt references.
4. When the agent finishes, run `node tool/validate.mjs` and walk the prompt's **Acceptance criteria**.
5. Review the diff. Commit per [governance.md §9](../docs/governance.md).

## Rules for every prompt run

- **Inspect before modifying.** The agent must read existing files, understand their purpose, preserve useful content, and improve only when necessary.
- **Never invent business UI as the core.** Everything stays reusable; use placeholders: `[APP_NAME]` `[COMPANY_NAME]` `[USER_NAME]` `[DATA_NAME]` `[MODULE_NAME]` `[FEATURE_NAME]` `[ROLE_NAME]`.
- **Token-driven.** No hard-coded colors, dimensions, or user-facing strings.
- **All states.** Loading · Empty · Success · Error · Offline · No-permission — every time.
- **Cross-platform.** Provide Jetpack Compose / Flutter / React Native (+ SwiftUI where useful) mappings, not one-platform code.
- **Accessible + dark mode + responsive** are part of "done", not follow-ups.
- **Consistency over volume.** Follow the terminology, structure, and conventions already in this repo.
