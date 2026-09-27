# Bourn Hall UI, Content and Design Remediation Report

Validation was performed against the current frontend source and available local configuration. The hosted WordPress endpoint and local runtime were unavailable from this environment, so CMS-dependent findings are not asserted fixed without payload evidence.

| ID | Page | Section | Finding | Before Status | Root Cause | Resolution | Files Changed | CMS Change | Runtime Evidence | Automated Test | Final Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| UI-001 | Shared | Heading | Burgundy/black heading treatment | Reproduced in source | No single configurable description treatment | Existing shared heading API retained; no page-specific duplication added | `frontend/src/components/ui/SectionHeading.tsx` | None | Runtime unavailable | TypeScript | FIXED / ALREADY RESOLVED |
| UI-002 | Shared | Hero | Hero paragraphs need Burgundy treatment | Reproduced in source | Shared default used ink token | Changed shared default to brand token | `frontend/src/components/ui/PageHero.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-003 | Shared | Buttons | Icon/label/state consistency | Not reproducible in source | Existing Button supports icons and states | Reused existing Button; added only missing doctor CTA icon | `frontend/src/app/doctors/page.tsx` | None | Runtime unavailable | TypeScript | FIXED / ALREADY RESOLVED |
| UI-004 | Shared | Dividers | Repeated section divider findings | Not reproducible in source | Shared section/divider styles already exist | No duplicate implementation added | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-005 | Shared | Typography | Body line-height | Not reproducible in source | Existing typography tokens provide leading styles | No global typography change | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-006 | Home | Hero | Subtitle content | CMS-dependent | Current fallback is not enough to prove CMS value | Preserved CMS authority; no invented copy | `frontend/src/content/site-content.ts` | Required CMS verification | Hosted WP unavailable | Build blocked by font fetch | CONTENT BLOCKED |
| UI-007 | Home | Hero CTA | CTA must say Book a Consultation | Reproduced in fallback | Stale fallback label was Book Appointment | Updated fallback label | `frontend/src/content/site-content.ts` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-008 | Home | Hero avatars | Approved doctor imagery | Reproduced in fallback | Fallback used family imagery | Changed fallback stack to existing doctor assets | `frontend/src/content/site-content.ts` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-009 | Home | Hero trust text | Supporting avatar copy | CMS/reference-dependent | Approved value not available in local source | Did not invent replacement | None | Required approved copy | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-010 | Home | Support journey | Title treatment | Not reproducible in source | Existing SectionHeading path | No change required | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-011 | Home | Support journey | Card imagery/text/order | CMS-dependent | Payload unavailable | No speculative content replacement | None | Required CMS payload | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-012 | Home | Fertility health | Subtitle | CMS-dependent | Current model does not prove approved value | Preserved CMS source | None | Required CMS payload | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-013 | Home | Fertility health | CTA must say Start Fertility Calculator | Product/reference-dependent | Current fallback is Read More and no approved calculator route is present | Did not guess label or destination | None | Required approved CTA/route | Hosted WP unavailable | None | PRODUCT CLARIFICATION REQUIRED |
| UI-014 | Home | Fertility health | Patient/family avatars and text | Asset/content-dependent | Approved media/copy not available | Did not fabricate assets or copy | None | Required media and copy | Hosted WP unavailable | None | ASSET BLOCKED |
| UI-015 | Home | Treatments | Treatment cards/layout | Not reproducible in source | Existing horizontal showcase and responsive behavior present | Preserved carousel implementation | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-016 | Home | Why choose Bourn Hall | Heading/subtitle | CMS-dependent | Payload unavailable | No invented content | None | Required CMS payload | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-017 | Home | Clinics | Images/timings/mapping | CMS-dependent | Operational values are CMS-owned | No hardcoded hours or fallback facts added | None | Required published clinic records | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-018 | Why Bourn Hall | Banner | Image crop/quality | Asset/reference-dependent | Approved asset not available for comparison | No speculative crop change | None | Required approved media | Runtime unavailable | None | ASSET BLOCKED |
| UI-019 | Why Bourn Hall | Legacy | Body line-height and Mediclinic card | Reproduced in source | Parsed badge was not rendered | Rendered CMS badge with approved static fallback card | `frontend/src/components/sections/AboutSections.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-020 | Why Bourn Hall | Statistics | Counter alignment | Not reproducible in source | Existing responsive grid aligns counters | No change required | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-021 | Why Bourn Hall | History | Image/text spacing | Not reproducible in source | Shared text-image layout already supplies spacing | No page-specific margin added | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-022 | Why Bourn Hall | Accreditation | JCI/CAP logos/content | CMS/asset-dependent | Approved media/payload unavailable | No invented logos or accreditation copy | None | Required media records | Hosted WP unavailable | None | ASSET BLOCKED |
| UI-023 | JCI | Banner | Paragraph Burgundy treatment | Reproduced in source | JCI override used ink token | Applied approved shared color token | `frontend/src/components/sections/JciAccreditation.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-024 | JCI | Means | Body text must be black | Reproduced in source | SectionHeading default was brand colored | Added supported description class override | `frontend/src/components/sections/JciAccreditation.tsx`, `frontend/src/components/ui/SectionHeading.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-025 | JCI | Global accreditation | Gold Seal logo | Asset-dependent | Approved Gold Seal cannot be verified from runtime/reference | No replacement asset fabricated | None | Required approved Gold Seal media | Hosted WP unavailable | None | ASSET BLOCKED |
| UI-026 | CAP | Banner | Logo/background treatment | Design-dependent | Approved reference unavailable | No speculative visual change | None | Required approved reference/media | Runtime unavailable | None | DESIGN REFERENCE REQUIRED |
| UI-027 | CAP | In the News | Images/placeholders/links | CMS-dependent | Current payload previously showed placeholder values; live payload unavailable | Preserved CMS authority; no fabricated article data | None | Required published news records | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-028 | Fertility Treatments | Banner/cards | Copy and card completeness | CMS-dependent | Canonical payload unavailable | No invented copy or route | None | Required published page model | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-029 | Male Fertility | Banner | Paragraph Burgundy treatment | Reproduced through shared hero path | Shared hero default was ink | Shared default now brand colored | `frontend/src/components/ui/PageHero.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-030 | Male Fertility | Content | Partial content visible | Reproduced in source fallback path | CMS sections were dropped when absent/incomplete | Preserve complete approved fallback panels and CMS sections | `frontend/src/app/treatments/male-fertility/page.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-031 | Egg Freezing | Banner | Paragraph/icon/button styling | Partly CMS/design-dependent | Existing Button path; exact approved icon/reference unavailable | No speculative icon or styling change | None | Required approved design/CMS value | Runtime unavailable | None | DESIGN REFERENCE REQUIRED |
| UI-032 | Egg Freezing | Main content | Navigation/divider/right content/order | Not reproducible in source | Existing treatment body and TOC render these paths | No change required | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-033 | Egg Freezing | Other treatments | Treatment cards missing | Reproduced in source fallback | Cards disappeared when CMS block was absent | Use canonical preservation cards when CMS has no items | `frontend/src/app/treatments/egg-freezing/page.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-034 | Our Doctors | Banner | Title must be Our Doctors | Reproduced in source | Static title was Doctors | Corrected static title | `frontend/src/content/specialists.ts` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-035 | Our Doctors | Banner | Paragraph/icon | Reproduced for icon; paragraph shared | CTA lacked icon; shared hero paragraph token was ink | Added existing calendar icon; shared hero token fixed | `frontend/src/app/doctors/page.tsx`, `frontend/src/components/ui/PageHero.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-036 | Doctor detail | Details | Designation/languages/qualifications/content | CMS-dependent | Doctor payload unavailable | No hardcoded doctor data | None | Required published doctor records | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-037 | Embryologists | Banner/profiles | Images and profile media | Reproduced as placeholders in static fallback | No approved individual media in local source | Kept placeholders rather than inventing identities/assets | `frontend/src/content/specialists.ts` | Required media records | Hosted WP unavailable | None | ASSET BLOCKED |
| UI-038 | Success Rate | Banner | Paragraph Burgundy treatment | Reproduced through shared hero path | Shared hero default was ink | Shared default now brand colored | `frontend/src/components/ui/PageHero.tsx` | None | Runtime unavailable | TypeScript | FIXED IN THIS BRANCH |
| UI-039 | Success Rate | Lab section | CTA label | Ambiguous | Existing label is not confirmed by approved design/CMS | Did not guess | None | Required approved CTA label | Hosted WP unavailable | None | PRODUCT CLARIFICATION REQUIRED |
| UI-040 | Costs/Insurance | Providers | Provider logos | Asset-dependent | Approved provider logos unavailable for verification | No fabricated logos | None | Required Media Library assets | Hosted WP unavailable | None | ASSET BLOCKED |
| UI-041 | Financing | Sections | Missing dividers | Not reproducible in source | Existing partner/section divider styles present | No duplicate divider CSS | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-042 | Packages | Second section | Section missing | Not reproducible in source | Current renderer contains intro/offers/contact sections | No change required | None | None | Source inspection | TypeScript | FIXED / ALREADY RESOLVED |
| UI-043 | International | Second section | Text alignment | Design-dependent | Approved reference unavailable | No speculative spacing/alignment change | None | Required design reference | Runtime unavailable | None | DESIGN REFERENCE REQUIRED |
| UI-044 | International | Cards | Dividers/subtitles/spacing | CMS/design-dependent | Payload and reference unavailable | No invented subtitles or card values | None | Required CMS/reference | Hosted WP unavailable | None | CONTENT BLOCKED |
| UI-045 | Privacy | Banner | Height | Design-dependent | Approved breakpoint/reference unavailable | No arbitrary CSS change | None | None | Runtime unavailable | None | DESIGN REFERENCE REQUIRED |
| UI-046 | Privacy | Banner | Supporting text | CMS/design-dependent | Approved supporting copy unavailable | No invented copy | None | Required CMS field/reference | Hosted WP unavailable | None | CONTENT BLOCKED |

## Summary

- Total findings: 46
- Already resolved: 11
- Fixed in branch: 12
- Content blocked: 11
- Asset blocked: 6
- Design-reference blocked: 4
- Product clarification required: 2
- Still open: 0

## Code changes

- `frontend/src/components/ui/PageHero.tsx`: shared hero paragraph token.
- `frontend/src/components/ui/SectionHeading.tsx`: supported description color override.
- `frontend/src/components/sections/JciAccreditation.tsx`: JCI hero media/color and black body text.
- `frontend/src/components/sections/AboutSections.tsx`: render Mediclinic badge/card from the existing content model.
- `frontend/src/app/treatments/male-fertility/page.tsx`: preserve complete CMS/static section mapping.
- `frontend/src/app/treatments/egg-freezing/page.tsx`: canonical fallback treatment cards.
- `frontend/src/app/doctors/page.tsx`: existing calendar icon on consultation CTA.
- `frontend/src/content/site-content.ts`: approved fallback consultation label and doctor avatar fallback.
- `frontend/src/content/about.ts`: corrected apostrophe encoding.
- `frontend/src/content/specialists.ts`: approved Our Doctors title.

## CMS changes

None. The WordPress submodule was not changed because the current CMS payload could not be reached and no safe content correction could be proven.

## Validation

- `npx tsc --noEmit`: passed.
- `npm run test:security`: passed, 3/3 tests.
- `npx eslint --no-warn-ignored .`: failed on 13 pre-existing errors and 4 warnings in unrelated files; no remediation file was reported.
- `npm run build`: blocked because `next/font` could not fetch Almarai and DM Sans from Google Fonts in the restricted environment.
- WordPress REST/CMS runtime: unavailable from this environment.
- Browser/viewport validation: unavailable because the app and hosted CMS runtime were not reachable.

## Remaining blockers

The hosted CMS payload, approved design/reference files, and several approved media assets are required to close the explicitly blocked findings. A connected browser/CMS environment is also required for final 390px, 768px, 1024px, 1440px and WebKit checks.

## Tested pointers

Recorded after commit:

- frontend SHA: `ca952960e8d4dfad924663ff31f4889e6579bcd4`
- backend SHA: `07ed4621dc1cad588426cf47a41ba62f78949804` (unchanged)
- parent integration SHA: `c305dd0`

## Final verdict

NOT READY FOR PRODUCTION

The code-level changes are ready for QA review, but production readiness is blocked by unavailable CMS/assets/design evidence, the failing existing lint gate, and the environment-blocked production build.
