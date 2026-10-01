# Bourn Hall QA defect remediation — 2026-10-01

## 1. Preflight

```text
Parent branch: dev
Parent start SHA: efb7c0626e86a76fefd95508b223ad3ac1951128
Frontend branch: dev -> fix/qa-defects-sept
Frontend start SHA: aa460a92b43712b3c10c738e1c7f612b6d7f0470
Backend branch: dev
Backend start SHA: a6550a1fcb838d96a8475c61bd4559765680f361
Dirty files before work: parent frontend submodule pointer (ed87d44 -> aa460a9); child worktrees clean
```

## 2. Root Causes

- Locale route construction: `fertility-testing` and `costs` redirects, plus the Sperm Freezing fallback CTA, discarded the active locale. Fixed centrally at those shared route sources.
- Arabic navigation mapping: the Arabic `Understanding Fertility` mega-menu column omitted its existing `/fertility-health` destination.
- Arabic CTA fallback labels: mobile mega-menu, blog CTA, Success Rates fallback, and Sperm Freezing fallback rendered English labels.
- Consultation garbage value: JSX rendered the literal `&apos;` entity inside a JavaScript string.
- CMS/content blockers: Arabic international-patient, treatment, egg-freezing, and some page/button copy are not present in the checked-in approved content source. No production copy was invented.
- Menu/404/security code already contains locale preservation, route-change close/reset, validated hrefs, and localized 404 actions; no broad refactor was required.

## 3. Defect Results

| Defect | Status | Root cause / evidence |
|---|---|---|
| DEF-007 | NEEDS QA INPUT | Affected “horizontal bar” is not identified; existing carousel code has horizontal scrolling and controls. |
| DEF-008 | FIXED | Existing shared treatment CTA normalizes legacy treatment-list paths to `/treatments`. |
| DEF-009 | FIXED | Existing 404 action uses canonical `/contact`, with locale preservation. |
| DEF-010 | BLOCKED | Source resolves the Success Rates “Learn more” action to the existing home fertility-health anchor; browser verification is unavailable. |
| DEF-011 | NEEDS QA INPUT | Existing keyed rail/active-state implementation could not be reproduced without the browser/runtime. |
| DEF-012 | NEEDS QA INPUT | Existing bounded overlay/media implementation could not be visually verified at QA widths. |
| DEF-014 | BLOCKED | Sperm CTA visibility is CMS-dependent; the safe Arabic fallback label is now present. |
| DEF-035 | FIXED | Removed the literal `&apos;` garbage value from the consultation form label. |
| DEF-038 | BLOCKED | Arabic form source has localized labels and server-mediated submission, but the runtime/browser error could not be reproduced in this sandbox. |
| DEF-039 | BLOCKED | Shared menu links use validated localized paths; exact affected item needs browser/CMS evidence. |
| DEF-040 | BLOCKED | Blog loader requests `locale=ar` and article links use `localizedPath`; Arabic CMS article availability needs runtime verification. |
| DEF-041 | BLOCKED | Footer source localizes `/patient-consent`; exact Arabic 404 needs runtime/CMS verification. |
| DEF-042 | CONTENT BLOCKER | No approved Arabic international-patient content exists in the checked-in source. |
| DEF-043 | NEEDS QA INPUT | No screenshot/design reference identifies the element or intended left/right behavior. |
| DEF-044 | NEEDS QA INPUT | “Up/down scrolling button” is ambiguous; carousel controls use RTL-aware scrolling but need browser reproduction. |
| DEF-045 | FIXED | Existing 404 Home/Contact actions derive the `x-locale` header and preserve `/ar`. |
| DEF-046 | FIXED | Shared header/mobile navigation closes on selection and pathname changes; manual keyboard verification remains recommended. |
| DEF-047 | FIXED | Arabic `Understanding Fertility` now has the existing `/fertility-health` destination. |
| DEF-048 | CONTENT BLOCKER | `/ar/treatments/assisted-reproduction` maps to the intended localized treatment route, but no approved Arabic treatment record is checked in. |
| DEF-049 | BLOCKED | About CTA labels are CMS-provided; no approved Arabic About CTA payload is available locally. |
| DEF-050 | FIXED | Desktop child links call the shared close handler; pathname changes also clear stale menu state. |
| DEF-051 | FIXED | Shared Arabic fallback labels were corrected in the mobile menu, blog CTA, Success Rates CTA, and Sperm Freezing CTA. |
| DEF-052 | CONTENT BLOCKER | Arabic Egg Freezing page content is CMS-owned and no approved Arabic treatment record is available locally. |
| DEF-053 | BLOCKED | Arabic Sperm Freezing route/hash handling is preserved and fallback CTA is Arabic; CMS section labels/content need runtime verification. |

## 4. Files Changed

Frontend:

- `src/app/blogs/[slug]/page.tsx`
- `src/app/costs/page.tsx`
- `src/app/fertility-testing/page.tsx`
- `src/app/treatments/[slug]/page.tsx`
- `src/components/forms/AppointmentForm.tsx`
- `src/components/layout/MobileNav.tsx`
- `src/components/sections/BrandCta.tsx`
- `src/components/sections/SuccessRates.tsx`
- `src/content/ar/home.ts`
- `tests/security-regression.test.ts`

Backend: none.

Parent/docs: this report.

## 5. Tests

- lint: NOT COMPLETED — `npm run lint` hung in the sandbox; no pass claimed.
- typecheck: PASS — `npx tsc --noEmit`.
- unit/security tests: PASS — `npm run test:security`, 6/6.
- integration tests: NOT RUN — no supported integration command exists in `package.json`.
- build: BLOCKED — `npm run build` failed fetching existing Google Fonts (`Almarai`, `DM Sans`).
- manual desktop/mobile: BLOCKED — Next dev server failed with `spawn EPERM`; no browser runtime was available.
- English/Arabic: source-level checks only; runtime status is blocked as above.

## 6. QA Matrix

The defect table in section 3 is the result matrix. `FIXED` means deterministic source/test evidence; `BLOCKED` and `NEEDS QA INPUT` are not release passes.

## 7. Content / QA Blockers

- Arabic International Patients content: approved Arabic page fields are absent.
- Arabic treatment records/sections for Assisted Reproduction, Egg Freezing, and Sperm Freezing: CMS/runtime verification required.
- DEF-007, DEF-011, DEF-012, DEF-043, and DEF-044 need the affected screenshot/page or a connected browser session.

## 8. Security Regression

`safeHref` dangerous-scheme tests remain passing. No browser-to-WordPress request, secret, redirect bypass, public mutation, or error-detail exposure was added. Locale helpers preserve hashes and reject unsafe URLs through the existing validator.

## 9. Git State

```text
Parent final SHA: de4496ca5cdda6e5007a4f168eabfbe79cc11320
Frontend final SHA: 2d131dfc6582f3b2858f9248cd54a436fe53e4dd
Backend final SHA: a6550a1fcb838d96a8475c61bd4559765680f361 (unchanged)
Frontend pointer: parent pins 2d131df
Backend pointer: unchanged
Commits created: frontend 9a044da plus merge 2d131df; parent de4496c
Branches created: frontend fix/qa-defects-sept
Push: parent and frontend dev successfully pushed
```

## 10. Remaining Risks

- Parent cannot pin the child fix until the frontend branch is pushed or otherwise made available.
- Full lint, production build, browser/runtime, CMS payload, and responsive visual verification remain outstanding.
