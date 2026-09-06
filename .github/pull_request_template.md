<!-- AMDS — see docs/governance.md §9 -->

## What & why

<!-- One or two sentences. Link the request/issue. -->

## Type

- [ ] Foundation / token change
- [ ] New / changed component
- [ ] New / changed screen template
- [ ] New / changed feature blueprint
- [ ] Starter-template / architecture doc
- [ ] Prompt / tooling
- [ ] Fix / docs / chore

## Checklist

- [ ] `npm run validate` passes (0 errors)
- [ ] No hard-coded colors / dimensions / user-facing strings — semantic tokens + placeholders (`[APP_NAME]`, `[MODULE_NAME]`, …) only
- [ ] Light **and** dark covered
- [ ] Accessibility addressed (contrast, 44dp targets, role/name/state, focus, reduced-motion, 200% text, RTL)
- [ ] Responsive: phone / small tablet / large tablet
- [ ] All states where relevant: Loading · Empty · Success · Error · Offline · No-permission
- [ ] Motion uses tokens (100–400ms) + a reduced-motion equivalent
- [ ] Cross-platform notes: Jetpack Compose · Flutter · React Native (· SwiftUI where useful)
- [ ] Every cross-reference updated (searched the repo for the changed term)
- [ ] `CHANGELOG.md` entry added
- [ ] Relevant Definition-of-Done checklist ticked (governance §4–5, screen-library/00-framework §6.5, feature-library/00-framework §4)

## Notes for reviewers

<!-- Anything that needs a closer look, trade-offs, follow-ups. -->
