# Bourn Hall Defect Remediation Report

Validation date: 2026-09-25  
Parent branch: `fix/qa-defect-remediation`  
Frontend branch: `fix/qa-defect-remediation`  
Backend branch: `dev` (no backend change required)

The local Next.js runtime was verified at `http://localhost:3000`. The supplied WordPress dev REST endpoint returned HTTP 200 for the `home` page and `accreditation-cap` page. The checked-in frontend `.env` points runtime reads at `brounhall-wp.local`, so local content/runtime evidence is reported separately from the supplied hosted endpoint.

| Defect | Status | Reproduced Before Fix | Root Cause | Files Changed | Validation Evidence | Automated Test | Notes |
|---|---|---:|---|---|---|---|---|
| DEF-001 | FIXED / ALREADY RESOLVED | No | Existing server-mediated handler validates input, origin, rate limits, signs upstream requests, and redacts payloads. | — | Synthetic valid POST returned 200; invalid same-origin payload returned 400; invalid origin returned 403. Server logs contained request IDs/status only. | `test:security` | No real patient data used. |
| DEF-002 | FIXED / ALREADY RESOLVED | No | Current heading is `Book a Consultation`; stale text is absent from source/runtime checks. | — | `rg` and runtime route check. | — | — |
| DEF-003 | FIXED / ALREADY RESOLVED | No | CTA uses the shared semantic `Button`/`Link` path with `/treatments`. | — | `/treatments` returned 200; keyboard-capable anchor semantics present. | — | — |
| DEF-004 | NOT REPRODUCIBLE | No | Current implementation uses a labelled YouTube modal with poster/play fallback; browser codec/CORS playback was not available in this environment. | — | Source/runtime inspection only. | — | Manual Chrome desktop and Android Chrome playback remains required. |
| DEF-005 | BLOCKED / NEEDS PRODUCT OR CONTENT CLARIFICATION | Yes, report does not identify the two items | The workbook does not identify the highlighted items, so approved content cannot be selected safely. | — | No unique item identity in the defect description or current source. | — | Provide the two item IDs/URLs. |
| DEF-006 | FIXED / ALREADY RESOLVED | No | Shared treatment TOC applies `!text-white` and `aria-current="location"` to the active item. | — | `TreatmentToc.tsx` inspection. | — | — |
| DEF-007 | FIXED / ALREADY RESOLVED | No | Shared carousel has overflow rail, pointer/touch axis detection, dots, and controls. | — | `Carousel.tsx` and `TreatmentsShowcase.tsx` inspection. | — | Manual touch check remains useful. |
| DEF-008 | FIXED / ALREADY RESOLVED | No | View-all CTA normalizes legacy treatment-list values to `/treatments`. | — | `/treatments` returned 200. | — | — |
| DEF-009 | FIXED / ALREADY RESOLVED | No | Error page uses `/contact`; consultation remains `/book-appointment`. | — | Both routes returned 200; `not-found.tsx` inspected. | — | — |
| DEF-010 | BLOCKED / NEEDS PRODUCT OR CONTENT CLARIFICATION | Yes | Hosted CMS home content supplies `/fertility-health`, but this frontend has no such route and the approved replacement is not specified. | — | `/fertility-health` is absent from app routes; hosted home payload contains that href. | — | Confirm whether it should map to the home anchor or a treatment page. |
| DEF-011 | NOT REPRODUCIBLE | No | Current treatment rail computes active dots from scroll position and renders a stable keyed card rail. | — | Source inspection; no browser automation installed. | — | Manual desktop/mobile carousel QA remains required. |
| DEF-012 | NOT REPRODUCIBLE | No | Current overlay sections reserve media dimensions and use bounded text containers. | — | Source inspection only. | — | Manual Edge/Android viewport QA remains required. |
| DEF-013 | FIXED / ALREADY RESOLVED | No | Shared/home mapping converts legacy `/treatments/fertility-testing` to `/treatments/female-fertility`. | — | `/treatments/female-fertility` returned 200; mapping present in `home.ts`. | `test:security` covers safe href behavior | — |
| DEF-014 | FIXED / ALREADY RESOLVED | No | Current treatment cards and hero actions always render visible labels; Sperm Freezing page returned 200. | — | Runtime/source checks found labelled controls and no blank action label. | — | — |
| DEF-015 | FIXED / ALREADY RESOLVED | No | Canonical route is implemented through the treatment fallback/CMS loader. | — | `/treatments/embryo-freezing` returned 200. | — | — |
| DEF-016 | FIXED / ALREADY RESOLVED | No | Header, desktop nav, mega menu, and mobile nav close on route activation; pathname changes also reset state. | — | `Header.tsx`, `DesktopNav.tsx`, `MobileNav.tsx` inspection. | — | Manual focus check remains required. |
| DEF-017 | BLOCKED / NEEDS PRODUCT OR CONTENT CLARIFICATION | Yes | Hosted CMS `accreditation-cap` contains `????` placeholder titles and `#` hrefs for four news cards. | — | Hosted endpoint response confirmed placeholder content and non-destination links; `/about/cap-accreditation` returned 200. | — | Requires approved Arabic titles and published URLs in CMS. |
| DEF-018 | FIXED / ALREADY RESOLVED | No | Shared outline button variant includes border styling. | — | `Button.tsx` inspected. | — | — |
| DEF-019 | NOT REPRODUCIBLE | No | No Safari 18 or Playwright WebKit runtime was available; current Lenis configuration permits nested horizontal scrolling. | — | Source inspection only. | — | Manual Safari/WebKit coverage remains required. |
| DEF-020 | FIXED IN THIS BRANCH | Yes | CMS supplied legacy `/fertility-treatments/fertility-preservation/*` links while frontend routes are `/treatments/*`. | `frontend/src/lib/security/link-safety.ts` | Before: all three legacy URLs returned 404. After normalization, preservation cards resolve to canonical `/treatments/egg-freezing`, `/treatments/sperm-freezing`, and `/treatments/embryo-freezing`, each returning 200. | `tests/security-regression.test.ts` | Shared URL mapper fix; no page-specific patch. |
| DEF-021 | NOT REPRODUCIBLE | No | Down-arrow handler uses Lenis/native scroll and media components reserve dimensions. | — | `Hero.tsx`, `SmoothScroll.tsx`, and image component inspection. | — | Manual image-load/anchor QA remains required. |
| DEF-022 | FIXED IN THIS BRANCH | Yes | Same legacy CMS preservation URL contract as DEF-020. | `frontend/src/lib/security/link-safety.ts` | Egg Freezing canonical route returned 200 after mapper normalization. | `tests/security-regression.test.ts` | — |
| DEF-023 | BLOCKED / NEEDS PRODUCT OR CONTENT CLARIFICATION | Yes, behavior is heading-only | “Understanding Fertility” has child links but no approved parent destination. | — | Desktop/mobile nav intentionally render it as a non-link heading. | — | Confirm whether parent should navigate or remain a submenu label. |
| DEF-024 | NOT REPRODUCIBLE | No | Header/footer use centralized content and shared link rendering; no single inaccessible target was identified. | — | `Header.tsx`, `Footer.tsx`, and route checks. | — | Need exact link or screenshot for targeted reproduction. |
| DEF-025 | NOT REPRODUCIBLE | No | Horizontal rails explicitly distinguish x/y gestures and restore touch classes after drag. | — | `Carousel.tsx` and `TreatmentsShowcase.tsx` inspection. | — | Manual Android gesture sequence remains required. |
| DEF-026 | FIXED IN THIS BRANCH | Yes | `RelatedBlogs` called `router.push()` when its pinned scroll progress reached 99%, and disabled the next card while pinned. | `frontend/src/components/sections/RelatedBlogs.tsx` | Removed automatic navigation; card link remains explicit and usable. | Production build + TypeScript | WebKit/mobile scroll test still recommended when browser tooling is available. |
| DEF-027 | FIXED / ALREADY RESOLVED | No | Privacy TOC active item uses the shared white active-state token and location state. | — | `TreatmentToc.tsx` inspection. | — | — |
| DEF-028 | FIXED / ALREADY RESOLVED | No | TOC title is rendered independently from section selection, so changing active section does not hide it. | — | `TreatmentToc.tsx` inspection. | — | — |
| DEF-029 | BLOCKED / NEEDS PRODUCT OR CONTENT CLARIFICATION | Yes | Current footer points to `/patient-consent` and `/patient-complaints`; canonical targets supplied by QA are `/consent/` and `/patients-complaints/`, but neither canonical route/content exists in the current frontend or hosted page REST response. | — | Local: `/patient-consent`, `/consent`, and `/patients-complaints` returned 404; `/patient-complaints` returned 200. Hosted REST returned no consent/complaints page records. | — | Requires approved Consent content and route ownership before changing footer links. |
| DEF-030 | NOT REPRODUCIBLE | No | No mismatched repeated title was identified in current route/source inspection. | — | Treatment/page title mapping inspected. | — | Need exact route/screenshot if still present. |
| DEF-031 | NOT REPRODUCIBLE | No | No mobile-only global uppercase rule affecting the reported titles was identified. | — | `globals.css` and title components inspected. | — | Manual 390px viewport check remains required. |

## Validation commands

- `npm ci` — completed previously from the lockfile.
- `npm run test:security` — passed, 3 tests.
- `npx tsc --noEmit` — passed.
- `npm run build` — passed; existing middleware deprecation and image-quality warnings remain.
- `npm run lint` — failed on 13 pre-existing errors and 4 warnings in untouched files (React effect lint rules, `NavigationProgress`, and an unused variable); no error was reported in the changed files.
- Runtime route checks — treatment canonical routes, `/contact`, `/book-appointment`, `/about/cap-accreditation`, `/privacy`, and `/patient-complaints` returned 200; known missing routes are recorded above.
- WordPress REST — supplied hosted `home` and `accreditation-cap` endpoints returned 200; hosted content exposed the CAP placeholders and legacy preservation links.

## Security and compatibility

- No new browser-to-WordPress request was introduced.
- No secrets or patient PII were added or logged; appointment validation used synthetic QA data only.
- No backend code was changed; backend remains on the published `dev` SHA `07ed4621dc1cad588426cf47a41ba62f78949804`.
- Frontend child changes are published on `origin/fix/qa-defect-remediation` at `10d8bc5c248bbe20da9f9594b3d239b0d530eed2`.
- The parent pins those tested child SHAs below. The pre-existing untracked parent `.gitignore` is intentionally not part of this change.

## Remaining manual QA

Safari/WebKit scroll, Android horizontal-to-vertical gesture recovery, video playback, visual responsive defects, keyboard menu focus, and the consultation browser flow should be rerun with browser automation/manual devices before release.

## Tested pointers

- Frontend: `10d8bc5c248bbe20da9f9594b3d239b0d530eed2`
- Backend: `07ed4621dc1cad588426cf47a41ba62f78949804`
- Parent: updated after child validation; live WordPress/browser evidence remains environment-blocked in the current sandbox.
