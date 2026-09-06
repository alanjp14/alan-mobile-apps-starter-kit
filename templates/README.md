# templates/

Copy-paste **starting points** for building a screen or flow in a new `[APP_NAME]`. Each is a filled-in skeleton — replace the placeholders, keep the structure, delete what you don't need.

| Folder | Contains |
|---|---|
| [`dashboard/`](dashboard/) | Operational / executive / monitoring dashboard skeletons |
| [`authentication/`](authentication/) | Login, register, forgot/reset, OTP flow skeletons |
| [`crud/`](crud/) | List · Detail · Create/Edit Form · Delete confirmation for `[DATA_NAME]` |
| [`approval/`](approval/) | Approval inbox · approval detail · decision flow |
| [`profile/`](profile/) | Profile · edit profile · security |
| [`monitoring/`](monitoring/) | Real-time status board / NOC dashboard |

## How to use

1. Copy the relevant `*.md` into your product design file / feature ticket.
2. Replace every placeholder: `[APP_NAME]` `[COMPANY_NAME]` `[USER_NAME]` `[DATA_NAME]` `[MODULE_NAME]` `[FEATURE_NAME]` `[ROLE_NAME]`.
3. Follow the linked **archetype** in [`../docs/screen-library/00-framework.md`](../docs/screen-library/00-framework.md) for the parts the skeleton doesn't spell out (all states, a11y, motion, tablet).
4. Pull components from [`../docs/component-library/`](../docs/component-library/README.md); wire the feature per its blueprint in [`../docs/feature-library/`](../docs/feature-library/README.md).

## Rules

- Templates are **reusable and business-agnostic** — placeholders only, no real product names or data.
- Every screen a template describes must still implement all states (Loading · Empty · Success · Error · Offline · No-permission), dark mode, tablet adaptation, and accessibility — the template points to the archetype for those.
- Tokens only; no hard-coded colors/dimensions.
