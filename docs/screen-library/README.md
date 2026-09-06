# Mobile Screen Library

> Foundation: **Alan Mobile Design System (AMDS) v1.0**
> Standard: Android-first · iOS-compatible · Tablet-responsive · Light + Dark · WCAG 2.2 AA · Enterprise-grade
> Reusable across: HRIS · K3/Safety · Asset Management · Inventory · Approval Workflow · Monitoring · Field Ops · Attendance · Reporting · Business Dashboards · Internal Apps · SaaS

A production-ready library of **40+ screen templates** organized around **8 reusable archetypes**. Read [`00-framework.md`](00-framework.md) first — it holds the shared skeleton, the 8 fully-specified archetypes (each covering all required dimensions), the cross-platform implementation recommendations (Jetpack Compose · Flutter · React Native · SwiftUI), and the universal checklists. Each per-screen spec then documents only its **deltas + specifics**.

Screens are **reusable, never business-specific** — use placeholders: `[APP_NAME]` `[COMPANY_NAME]` `[USER_NAME]` `[DATA_NAME]` `[MODULE_NAME]` `[FEATURE_NAME]` `[ROLE_NAME]`.

## How to read a screen spec

1. Find the screen below → open its group file.
2. Note its **Archetype** → read that archetype in [`00-framework.md`](00-framework.md) §4 (≈80% of the spec).
3. Read the screen's own entry for the specific 20% (purpose, IA, fields/columns/actions, edge cases, per-platform notes).
4. Build with the AMDS tokens ([`../../design-tokens/`](../../design-tokens/README.md)) and components ([`../component-library/README.md`](../component-library/README.md)).
5. Verify against [`00-framework.md`](00-framework.md) §6 (States / Accessibility / Dark Mode / Tablet / DoD checklists).

Every screen entry provides: **Objective · User · Entry point · Information hierarchy · Layout structure · Component hierarchy · Primary/Secondary CTA · Navigation · Interaction · States (Loading · Empty · Success · Error · Offline · No-permission) · Accessibility · Animations · Dark mode behavior · Tablet layout adaptation · Developer notes (Compose/Flutter/RN/SwiftUI) · UX best practices.**

## The 8 archetypes ([`00-framework.md`](00-framework.md) §4)

| | Archetype | Screens that use it |
|---|---|---|
| A | **Focused Task** (auth / single-purpose) | Splash, Onboarding, Login, Register, Forgot Password, Reset Password, OTP, Biometric Auth, Change Password, Export, Contact Support |
| B | **Dashboard** (overview & orientation) | Executive, Operational, Analytics, Monitoring dashboards, Reports Dashboard |
| C | **List / Collection** | User List, Data List, Approval Inbox, Notification Center, Approval History, Reports catalog |
| D | **Detail / Record** | User Detail, Data Detail, Approval Detail, Notification Detail, Report Detail, My Profile |
| E | **Form / CRUD** | User Create/Edit, Create/Edit Form, Edit Profile, Change Password |
| F | **Confirmation / Decision** | Delete Confirmation, Approve/Reject/Request-Changes, sign-out, destructive bulk actions |
| G | **Settings List** | General · Appearance · Notification · Security · Language · About, Settings hub |
| H | **Content / Article** | FAQ, About Application, Contact Support (info), Approval History (timeline), Report narrative |

## Screen index

| Group | File | Screens |
|---|---|---|
| Framework | [`00-framework.md`](00-framework.md) | Skeleton · 8 archetypes · cross-platform impl · checklists |
| **Authentication** | [`01-authentication.md`](01-authentication.md) | Splash · Onboarding · Login · Register · Forgot Password · Reset Password · OTP Verification (Biometric Auth = §1.3 + [feature-library/09](../feature-library/09-platform.md)) |
| **Dashboard** | [`02-dashboard.md`](02-dashboard.md) | Executive · Operational · Analytics · Monitoring *(+ full worked spec: [`../specs/dashboard.md`](../specs/dashboard.md))* |
| **User Management** | [`03-user-management.md`](03-user-management.md) | User List · User Detail · User Create · User Edit (Role & Permission → [feature-library/01](../feature-library/01-identity.md)) |
| **Data Management** | [`04-data-management.md`](04-data-management.md) | Data List · Search · Filter · Data Detail · Create Form · Edit Form · Delete Confirmation · Bulk Action |
| **Approval** | [`05-approval-workflow.md`](05-approval-workflow.md) | Approval Inbox · Approval Detail · Approve · Reject · Request Changes · Approval History |
| **Notification** | [`06-notifications.md`](06-notifications.md) | Notification Center · Notification Detail · Read/Unread · Notification Settings |
| **Reporting** | [`07-reporting.md`](07-reporting.md) | Report Dashboard · Report List · Report Detail · Export · Filter |
| **Profile** | [`08-profile.md`](08-profile.md) | Profile · Edit Profile · Security · Change Password |
| **Settings** | [`09-settings.md`](09-settings.md) | General · Appearance · Notification · Security · Language · About |
| **Help Center** | [`10-help-center.md`](10-help-center.md) | FAQ · Contact Support · About Application |
| **Utility States** | [`11-utility-states.md`](11-utility-states.md) | Loading · Empty · Error · Offline · No Permission · Session Expired · Maintenance |
| Design patterns | [`dashboard-system.md`](dashboard-system.md) · [`form-design-system.md`](form-design-system.md) | Dashboard block kit; CRUD/approval/validation standards |

Copy-paste starting points: [`../../templates/`](../../templates/).

## Reusable engines (referenced throughout)

From the [Flutter starter kit](../specs/flutter-starter-kit.md) §8.1 — the same idea applies to Compose / RN / SwiftUI:

- **`RecordListConfig`** → every **List** screen (§4.C)
- **`RecordDetailConfig`** → every **Detail** screen (§4.D)
- **`FormSchema` / FormEngine** → every **Form** screen (§4.E)
- **`AmdsDialog.destructive`** → every **Confirmation** (§4.F)
- **`AmdsSettingRow`** → every **Settings** screen (§4.G)

Configure these per entity; do not rebuild them per screen.

## Related AMDS docs

- Foundations & tokens: [`../design-system/README.md`](../design-system/README.md), [`../../design-tokens/README.md`](../../design-tokens/README.md)
- Components: [`../component-library/README.md`](../component-library/README.md)
- Navigation patterns: [`../design-system/navigation-patterns.md`](../design-system/navigation-patterns.md)
- Motion: [`../design-system/motion.md`](../design-system/motion.md)
- Dashboards: [`dashboard-system.md`](dashboard-system.md)
- Forms: [`form-design-system.md`](form-design-system.md)
- Data tables: [`../component-library/data-display.md`](../component-library/data-display.md)
- Accessibility: [`../design-system/accessibility.md`](../design-system/accessibility.md)
- Dark mode: [`../design-system/dark-mode.md`](../design-system/dark-mode.md)
- Feature blueprints: [`../feature-library/README.md`](../feature-library/README.md)
- App architecture: [`../starter-template/README.md`](../starter-template/README.md)
