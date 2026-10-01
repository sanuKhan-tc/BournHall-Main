# Bourn Hall Content Source Map

## Authority

The supplied DOCX files are the editorial source for this content-alignment
pass. WordPress remains the runtime editorial authority after approved content
is migrated. Next.js remains the rendering and routing authority.

| Source | Scope | Treatment |
| --- | --- | --- |
| `Bourn-Hall-Website-Content-Document.docx` | English sitewide copy, page hierarchy, page copy, entities, forms and footer | Publish only exact source copy; retain documented placeholders and under-construction states |
| `Bourn-Hall-Arabic-Website-Content-Organized 2.docx` | Arabic copy, parallel routes, terminology, client decisions, developer notes and DHA review | Publish only approved Arabic copy; exclude reference English, developer notes and DHA commentary |
| Existing WordPress page/entity contracts | Runtime storage and API shape | Extend existing fields and seeders; do not replace with a new CMS model |
| Existing Next.js content/mappers | Presentation view models and fallbacks | Preserve visual components and use server-side CMS access only |

## Source classification

The Arabic document contains four non-publishable classes that are excluded
from seed payloads:

- Reference-only English shown beside translations.
- `ملاحظة لفريق التطوير` and Section 13 implementation notes.
- Section 14 DHA review commentary and proposed alternatives.
- Items explicitly marked as requiring client confirmation or missing verbatim copy.

## Publishable source areas

The English document has 12 main areas and the Arabic document has 12 public
areas plus a separate patient-referral area. The public areas are sitewide,
homepage, Why Bourn Hall, team, treatments, success-rate placeholder, CAP,
costs, consultation, international patients, contact and footer. The Arabic
parallel set uses `/ar/` routes and `_ar` WordPress page/entity slugs where the
existing contract requires them.

## Approved decisions captured

- ICSI start year is **1983**.
- Dr. Mufeed Shawa is excluded from future published doctor lists and related
  booking/referral selectors; existing records must not be destructively deleted
  by the migration.
- Dr. Heba Hashem uses the approved specialty wording from the Arabic source.
- Arabic public content must not contain developer notes, DHA notes or English
  reference copy.
- Placeholder, coming-soon and under-construction copy remains unchanged unless
  the source provides approved replacement copy.

## Media policy

The documents contain descriptive `IMAGE PLACEHOLDER` entries, not approved
media files. They are inventory requirements only. No placeholder description is
seeded as an image URL. Existing WordPress attachments are resolved by stable
media key or approved filename when available; unresolved media remains an
explicit migration warning.

## Current contract map

| Area | Current storage/API | Current frontend boundary |
| --- | --- | --- |
| Pages | Native `page`, `_brounhall_page_data`, REST page parser | `src/lib/wordpress/pages/*` -> existing section components |
| Treatments | `service` with legacy `bh_treatment` compatibility, `_brounhall_entity_data`, REST `/wp-json/brounhall/v1/treatments` | `src/lib/wordpress/treatments.ts` -> treatment view model/components |
| Doctors | `doctor` with legacy `bh_doctor`, entity data and `locales.ar` | `src/lib/wordpress/doctors.ts` -> directory/profile components |
| Clinics | `location` with legacy `bh_clinic`, directory REST | `src/lib/wordpress/clinics.ts` -> location components |
| FAQs | `faq`, REST `/wp-json/brounhall/v1/faqs/faq` | `src/lib/wordpress/faqs.ts` -> FAQ components |
| Navigation | Native menus, GraphQL fragments/queries, controlled URLs | Header/footer navigation components |
| SEO | ACF `seo`, GraphQL fragments, Next metadata mapper | `src/lib/seo.ts` and route metadata |
| Global settings | `brounhall_global_settings`, GraphQL `brounhallGlobalSettings` | global statistics and site chrome loaders |

