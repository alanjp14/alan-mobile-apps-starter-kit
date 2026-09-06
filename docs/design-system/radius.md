# Border Radius

> Part of the [Alan Mobile Design System](README.md) · Foundations.
> Tokens: [`design-tokens/radius.json`](../../design-tokens/radius.json).

---

## 1. Scale

| Token | Value | Use |
|---|---|---|
| `radius.xs` | 4 | Tag, checkbox, small chip, nested inner elements, image thumb |
| `radius.sm` | 8 | Input field, small button, menu item, snackbar |
| `radius.md` | 12 | **Default.** Button, compact card, dropdown, tooltip, segmented control |
| `radius.lg` | 16 | Standard card, KPI card, dialog on phone, list container |
| `radius.xl` | 24 | Bottom sheet top corners, modal, large feature card |
| `radius.2xl` | 32 | Marketing card, onboarding illustration frame |
| `radius.full` | 9999 | Pill button, avatar, FAB, switch track, badge dot, pill chips |

## 2. Rules

- **One radius family per screen** — don't mix 12 and 16 cards side by side.
- **Nested corners:** inner radius = outer − padding, min `xs`. A `lg` (16) card with `space.4` (16) padding → inner elements `xs`–`sm`.
- Bottom sheets and drawers are rounded on the **leading / top edges only**.
- Full-bleed images inside a card inherit the card's radius on the corners they touch.
- iOS may use continuous ("squircle") corner curves where the platform supports it; Android / Flutter use standard rounded. Reconcile visually **via the token**, not per-platform overrides.

## 3. Do / Don't

**Do** — use `md` as the default; keep one family per view; round sheets on the top edges only.
**Don't** — mix radius families in one view; apply `full` to rectangular content cards; hard-code corner values.
